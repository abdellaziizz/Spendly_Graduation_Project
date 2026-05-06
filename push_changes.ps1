Set-Location 'C:\Users\DELL\Desktop\tspendly\tspendly'
Write-Output "Remote(s):"
git remote -v
Write-Output "Current branch:"
git branch --show-current
Write-Output "Status (porcelain):"
git status --porcelain
Write-Output "Adding changes..."
git add -A
Write-Output "Attempting commit..."
try {
  git commit -m 'Apply chat enhancements and backend wiring' -q
  Write-Output "Committed changes."
} catch {
  Write-Output 'No new commit or commit failed.'
}
$b = git rev-parse --abbrev-ref HEAD
Write-Output "Pushing branch: $b"
git push origin $b
