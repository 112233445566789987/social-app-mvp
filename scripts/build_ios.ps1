# Social App MVP - iOS 构建脚本（仅 macOS）
# 用法: 在 macOS 终端运行: chmod +x build_ios.sh && ./build_ios.sh
param(
    [ValidateSet("simulator", "release")]
    [string]$BuildType = "simulator"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "  Social App - iOS 构建脚本" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "⚠️  注意：iOS 构建必须在 macOS + Xcode 环境下运行" -ForegroundColor Yellow
Write-Host ""

# 检查 Flutter
Write-Host "[1/4] 检查 Flutter..." -ForegroundColor Yellow
try {
    $flutterVer = & flutter --version 2>&1 | Select-Object -First 1
    Write-Host "✅ Flutter: $flutterVer" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter 未安装" -ForegroundColor Red
    exit 1
}

# 检查 Xcode（仅 macOS）
$IsMacOS = $PSVersionTable.Platform -eq "Unix" -or $IsMacOS
if ($IsMacOS) {
    Write-Host "[2/4] 检查 Xcode..." -ForegroundColor Yellow
    try {
        $xcodeVer = & xcodebuild -version 2>&1 | Select-Object -First 1
        Write-Host "✅ Xcode: $xcodeVer" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Xcode 未安装，请从 App Store 安装" -ForegroundColor Yellow
    }
}

# 安装依赖
Write-Host "[3/4] 安装依赖..." -ForegroundColor Yellow
Push-Location $ProjectRoot
flutter pub get 2>&1 | Out-Null

# 构建
Write-Host "[4/4] 开始构建..." -ForegroundColor Yellow
if ($BuildType -eq "simulator") {
    Write-Host "目标: iOS 模拟器" -ForegroundColor Cyan
    & flutter build ios --simulator --no-codesign 2>&1
} else {
    Write-Host "目标: iOS 真机 / App Store" -ForegroundColor Cyan
    Write-Host "⚠️  release 构建需要 Xcode 签名证书配置" -ForegroundColor Yellow
    & flutter build ios --release 2>&1
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ 构建成功！" -ForegroundColor Green
    if ($BuildType -eq "simulator") {
        Write-Host "运行: flutter run -d <模拟器ID>" -ForegroundColor White
    }
} else {
    Write-Host "❌ 构建失败" -ForegroundColor Red
}

Pop-Location
