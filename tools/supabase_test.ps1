$projectUrl = 'https://bajjqhcqfmvsniszytsf.supabase.co'
$anon = 'sb_publishable_i6MceD8i9QPiYviUu37dCg__O5B9Mzd'

# 1) Sign up a temporary test user
$ts = Get-Date -UFormat "%s"
$email = "test.user.$ts@example.com"
$pw = "TestPassw0rd!"
$body = @{email=$email; password=$pw} | ConvertTo-Json
$headers = @{apikey=$anon; 'Content-Type'='application/json'}
Write-Output "Signing up user $email"
try{
  $resp = Invoke-RestMethod -Uri "$projectUrl/auth/v1/signup" -Method Post -Body $body -Headers $headers -ErrorAction Stop
  Write-Output "SIGNUP_RESPONSE:"
  Write-Output (ConvertTo-Json $resp -Depth 5)
}catch{
  Write-Output "SIGNUP FAILED: $_"
  exit 1
}

$access_token = $resp.access_token
$user_id = $resp.user.id
Write-Output "Got user id: $user_id"

# 2) Insert a category
$catBody = @{users_id = $user_id; name = "TestCategory-$ts"; icon = 'category_rounded'} | ConvertTo-Json
$headers2 = @{apikey=$anon; Authorization = "Bearer $access_token"; 'Content-Type'='application/json'; Prefer='return=representation'}
Write-Output "Creating category"
$cat = Invoke-RestMethod -Uri "$projectUrl/rest/v1/categories" -Method Post -Body $catBody -Headers $headers2 -ErrorAction Stop
$category_id = $cat[0].id
Write-Output "Category id: $category_id"

# 3) Insert category_limit for current month
$now = Get-Date
$monthStr = $now.ToString('yyyy-MM-01')
$limitBody = @{users_id = $user_id; category_id = $category_id; limit_month = $monthStr; amount = 250.0} | ConvertTo-Json
Write-Output "Inserting category_limit for $monthStr"
$limit = Invoke-RestMethod -Uri "$projectUrl/rest/v1/category_limits" -Method Post -Body $limitBody -Headers $headers2 -ErrorAction Stop

# 4) Insert a transaction linked to the category
$txBody = @{users_id = $user_id; type='expense'; amount=45.5; title='Test Lunch'; description='API inserted test'; category_id=$category_id; input_method='manual'; transaction_date = $now.ToString('yyyy-MM-dd')} | ConvertTo-Json
Write-Output "Inserting transaction"
$tx = Invoke-RestMethod -Uri "$projectUrl/rest/v1/transactions" -Method Post -Body $txBody -Headers $headers2 -ErrorAction Stop
$txid = $tx[0].id
Write-Output "Transaction id: $txid"

# 5) Read back transactions and categories for payload
$transactions = Invoke-RestMethod -Uri "$projectUrl/rest/v1/transactions?users_id=eq.$user_id&select=id,type,amount,title,description,transaction_date,category_id" -Method Get -Headers $headers2 -ErrorAction Stop
$categories = Invoke-RestMethod -Uri "$projectUrl/rest/v1/categories?users_id=eq.$user_id&select=id,name" -Method Get -Headers $headers2 -ErrorAction Stop

# Map category id -> name
$catMap = @{}
foreach($c in $categories){ $catMap[$c.id] = $c.name }

$expenses = @()
foreach($t in $transactions){
  if($t.type -ne 'income'){
    $expenses += @{date = [DateTime]::Parse($t.transaction_date).ToString('s'); amount = [double]$t.amount; category = $catMap[$t.category_id]; description = $t.description}
  }
}

$currentSpending = @{ }
foreach($pair in $catMap.GetEnumerator()){
  # Sum expenses per category
  $sum = ($expenses | Where-Object { $_.category -eq $pair.Value } | Measure-Object -Property amount -Sum).Sum
  $currentSpending[$pair.Value.ToLower()] = [double]($sum)
}

$budgets = @{}
# fetch category_limits for month
$limits = Invoke-RestMethod -Uri "$projectUrl/rest/v1/category_limits?users_id=eq.$user_id&limit_month=eq.$monthStr&select=category_id,amount" -Method Get -Headers $headers2 -ErrorAction Stop
foreach($l in $limits){ $budgets[$catMap[$l.category_id].ToLower()] = [double]$l.amount }

$payload = @{ userId = $user_id; expenses = $expenses; budgets = $budgets; currentSpending = $currentSpending; historicalMonthly = @(300.0,320.0,280.0); daysInMonth = ([DateTime]::DaysInMonth($now.Year,$now.Month)); currentDay = $now.Day } | ConvertTo-Json -Depth 10

Write-Output "Calling backend generate-report"
$report = Invoke-RestMethod -Uri 'http://127.0.0.1:5001/api/predictions/generate-report' -Method Post -Body $payload -ContentType 'application/json' -ErrorAction Stop

Write-Output "REPORT OUTPUT:"
Write-Output (ConvertTo-Json $report -Depth 10)

# output ids so user can inspect or clean up
Write-Output "TEST_ENTITIES: userId=$user_id, categoryId=$category_id, txId=$txid"
