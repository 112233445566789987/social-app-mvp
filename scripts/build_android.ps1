# Social App MVP - Android 构建脚本
# 用法: 右键 -> 使用 PowerShell 运行
param(
    [ValidateSet("debug", "release")]
    [string]$BuildType = "debug",
    [string]$OutputDir = "build\app\outputs\flutter-apk"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "  Social App - Android 构建脚本" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Flutter
Write-Host "[1/4] 检查 Flutter 环境..." -ForegroundColor Yellow
try {
    $flutterVer = & flutter --version 2>&1 | Select-Object -First 1
    Write-Host "✅ Flutter: $flutterVer" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter 未安装或不在 PATH 中" -ForegroundColor Red
    Write-Host "请先安装 Flutter SDK: https://flutter.cn/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

# 检查 Android SDK
Write-Host "[2/4] 检查 Android SDK..." -ForegroundColor Yellow
$androidSdk = $env:ANDROID_HOME
if (-not $androidSdk) {
    $androidSdk = $env:ANDROID_SDK_ROOT
}
if ($androidSdk) {
    Write-Host "✅ ANDROID_HOME: $androidSdk" -ForegroundColor Green
} else {
    Write-Host "⚠️  未设置 ANDROID_HOME，请确保 Android Studio 已安装" -ForegroundColor Yellow
}

# 清理 + 获取依赖
Write-Host "[3/4] 清理并安装依赖..." -ForegroundColor Yellow
Push-Location $ProjectRoot
try {
    flutter clean 2>&1 | Out-Null
    flutter pub get 2>&1 | Out-Null
    Write-Host "✅ 依赖安装完成" -ForegroundColor Green
} catch {
    Write-Host "❌ 依赖安装失败: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

# 构建
Write-Host "[4/4] 开始构建 $BuildType APK..." -ForegroundColor Yellow
$flag = if ($BuildType -eq "release") { "--release" } else { "--debug" }
$buildCmd = "flutter build apk $flag"

Write-Host "执行: $buildCmd" -ForegroundColor Cyan
& flutter build apk $flag 2>&1 | ForEach-Object { Write-Host $_ }

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Green
    Write-Host "  ✅ 构建成功！" -ForegroundColor Green
    Write-Host "  输出目录: $ProjectRoot\$OutputDir" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green

    # 列出输出文件
    if (Test-Path "$ProjectRoot\$OutputDir") {
        Get-ChildItem "$ProjectRoot\$OutputDir\*.apk" | ForEach-Object {
            Write-Host "  📦 $($_.Name) ($([math]::Round($_.Length / 1MB, 1)) MB)" -ForegroundColor White
        }
    }
} else {
    Write-Host "❌ 构建失败，退出码: $LASTEXITCODE" -ForegroundColor Red
}

Pop-Location
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
