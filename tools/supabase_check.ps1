$projectUrl = 'https://bajjqhcqfmvsniszytsf.supabase.co'
$anon = 'sb_publishable_i6MceD8i9QPiYviUu37dCg__O5B9Mzd'

# Replace these with the values from the previous run (update if different)
$userEmail = ''
$userPw = 'TestPassw0rd!'
$txId = ''
$categoryId = ''

if($userEmail -eq ''){ Write-Output 'Please set $userEmail and ids in file supabase_check.ps1 and rerun'; exit 1 }

# Sign in user to get access token
$body = "grant_type=password&email=$userEmail&password=$userPw"
$headers = @{apikey=$anon; 'Content-Type'='application/x-www-form-urlencoded'}
$resp = Invoke-RestMethod -Uri "$projectUrl/auth/v1/token" -Method Post -Body $body -Headers $headers
Write-Output "SIGNIN_RESPONSE:"
Write-Output (ConvertTo-Json $resp -Depth 5)
$token = $resp.access_token
$hdr = @{apikey=$anon; Authorization = "Bearer $token"}

# Fetch transaction
if($txId -ne ''){
  $tx = Invoke-RestMethod -Uri "$projectUrl/rest/v1/transactions?id=eq.$txId&select=*" -Method Get -Headers $hdr
  Write-Output "TRANSACTION:"; Write-Output (ConvertTo-Json $tx -Depth 5)
}
# Fetch category
if($categoryId -ne ''){
  $cat = Invoke-RestMethod -Uri "$projectUrl/rest/v1/categories?id=eq.$categoryId&select=*" -Method Get -Headers $hdr
  Write-Output "CATEGORY:"; Write-Output (ConvertTo-Json $cat -Depth 5)
}
# Fetch category_limits (current month)
$now = Get-Date
$monthStr = "{0:yyyy}-{1:D2}-01" -f $now.Year, $now.Month
$limits = Invoke-RestMethod -Uri "$projectUrl/rest/v1/category_limits?users_id=eq.$($resp.user.id)&limit_month=eq.$monthStr&select=*" -Method Get -Headers $hdr
Write-Output "LIMITS:"; Write-Output (ConvertTo-Json $limits -Depth 5)
