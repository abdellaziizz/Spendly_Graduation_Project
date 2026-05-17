$projectUrl = 'https://bajjqhcqfmvsniszytsf.supabase.co'
$anon = 'sb_publishable_i6MceD8i9QPiYviUu37dCg__O5B9Mzd'

# Sign up test user
$ts = Get-Date -UFormat "%s"
$email = "debug.user.$ts@example.com"
$pw = "TestPassw0rd!"
$body = @{email=$email; password=$pw} | ConvertTo-Json
$headers = @{apikey=$anon; 'Content-Type'='application/json'}
Write-Output "Signing up user $email"
$resp = Invoke-RestMethod -Uri "$projectUrl/auth/v1/signup" -Method Post -Body $body -Headers $headers
$access_token = $resp.access_token
$user_id = $resp.user.id
Write-Output "Got user id: $user_id"

# Create a category
$catBody = @{users_id = $user_id; name = "DebugCategory-$ts"; icon = 'category_rounded'} | ConvertTo-Json
$headers2 = @{apikey=$anon; Authorization = "Bearer $access_token"; 'Content-Type'='application/json'; Prefer='return=representation'}
Write-Output "Creating category"
$cat = Invoke-RestMethod -Uri "$projectUrl/rest/v1/categories" -Method Post -Body $catBody -Headers $headers2
$category_id = $cat[0].id
Write-Output "Category id: $category_id"

# Prepare category_limit payload
$now = Get-Date
$monthStr = $now.ToString('yyyy-MM-01')
$limitBody = @{users_id = $user_id; category_id = $category_id; limit_month = $monthStr; amount = 250.0}
Write-Output "Attempting to insert category_limits payload:"
Write-Output (ConvertTo-Json $limitBody -Depth 5)

try{
  $limit = Invoke-RestMethod -Uri "$projectUrl/rest/v1/category_limits" -Method Post -Body (ConvertTo-Json $limitBody) -Headers $headers2 -ContentType 'application/json' -ErrorAction Stop
  Write-Output "Insert succeeded:"
  Write-Output (ConvertTo-Json $limit -Depth 5)
} catch {
  Write-Output "Insert FAILED. Capturing full error response body and details..."
  $ex = $_.Exception
  if($ex -and $ex.Response){
    $rsp = $ex.Response
    $stream = $rsp.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $bodyText = $reader.ReadToEnd()
    Write-Output "HTTP Status: $($rsp.StatusCode) $($rsp.StatusDescription)"
    Write-Output "Response body:\n$bodyText"
  } else {
    Write-Output "No response available in exception: $_"
  }
  exit 1
}

Write-Output "Done."
