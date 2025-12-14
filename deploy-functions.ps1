# Firebase Cloud Functions Deployment Script
# Run this script to deploy your notification functions to Firebase

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  Firebase Cloud Functions Deployment" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Check if Firebase CLI is installed
Write-Host "Checking Firebase CLI installation..." -ForegroundColor Yellow
$firebaseCli = Get-Command firebase -ErrorAction SilentlyContinue

if (-not $firebaseCli) {
    Write-Host "❌ Firebase CLI not found!" -ForegroundColor Red
    Write-Host "`nPlease install Firebase CLI first:" -ForegroundColor Yellow
    Write-Host "  npm install -g firebase-tools`n" -ForegroundColor White
    exit 1
}

Write-Host "✅ Firebase CLI found: $($firebaseCli.Version)" -ForegroundColor Green

# Check if logged in to Firebase
Write-Host "`nChecking Firebase login status..." -ForegroundColor Yellow
$loginCheck = firebase login:list 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not logged in to Firebase!" -ForegroundColor Red
    Write-Host "`nPlease login first:" -ForegroundColor Yellow
    Write-Host "  firebase login`n" -ForegroundColor White
    
    $loginNow = Read-Host "Would you like to login now? (y/n)"
    if ($loginNow -eq 'y' -or $loginNow -eq 'Y') {
        firebase login
    } else {
        exit 1
    }
}

Write-Host "✅ Logged in to Firebase" -ForegroundColor Green

# Install dependencies
Write-Host "`nInstalling dependencies..." -ForegroundColor Yellow
Push-Location functions

if (-not (Test-Path "node_modules")) {
    Write-Host "Running npm install..." -ForegroundColor Cyan
    npm install
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install dependencies!" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    Write-Host "✅ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✅ Dependencies already installed" -ForegroundColor Green
}

Pop-Location

# Deploy functions
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  Deploying Cloud Functions..." -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

firebase deploy --only functions

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Deployment successful!" -ForegroundColor Green
    Write-Host "`nYour notification functions are now live!" -ForegroundColor Cyan
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "  1. Create a test job as admin" -ForegroundColor White
    Write-Host "  2. Check if users receive notifications" -ForegroundColor White
    Write-Host "  3. View logs: firebase functions:log`n" -ForegroundColor White
} else {
    Write-Host "`n❌ Deployment failed!" -ForegroundColor Red
    Write-Host "`nPlease check the error messages above and try again.`n" -ForegroundColor Yellow
}
