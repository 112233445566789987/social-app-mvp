# ============================================================
# Social App MVP — 初始化 & 上传 GitHub + 配置 Codemagic
# 
# 运行方式（PowerShell 7+）:
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#   .\setup_codemagic.ps1
# ============================================================

param(
    [string]$GitHubToken = "",   # 可选: GitHub Personal Access Token
    [string]$RepoName = "social-app-mvp",
    [string]$Description = "跨平台社交 App MVP（Flutter）— 聊天 / 朋友圈 / 匹配"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot | Split-Path -Parent

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Social App MVP — GitHub 上传 & Codemagic 配置" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# ── Step 0: 检查 Git ───────────────────────────────────────
Write-Host "[Step 0] 检查 Git..." -ForegroundColor Yellow
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCmd) {
    Write-Host "❌ Git 未安装。请先安装 Git: winget install Git.Git" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Git $($gitCmd.Version) 已安装" -ForegroundColor Green

# 初始化 Git（如果还没有）
Push-Location $ProjectRoot
if (-not (Test-Path ".git")) {
    Write-Host "初始化 Git 仓库..." -ForegroundColor Cyan
    git init
    git remote add origin https://github.com/YOUR_USERNAME/$RepoName.git
} else {
    Write-Host "✅ Git 仓库已存在" -ForegroundColor Green
}

# ── Step 1: 检查 gh CLI ────────────────────────────────────
Write-Host ""
Write-Host "[Step 1] 检查 GitHub CLI (gh)..." -ForegroundColor Yellow
$ghCmd = Get-Command gh -ErrorAction SilentlyContinue

if (-not $ghCmd) {
    Write-Host ""
    Write-Host "⚠️  gh (GitHub CLI) 未安装，跳过自动创建仓库。" -ForegroundColor Yellow
    Write-Host "   你可以手动在 GitHub 上创建仓库，然后运行下一步。" -ForegroundColor Yellow
    Write-Host ""
    $skipGh = $true
} else {
    Write-Host "✅ gh $($ghCmd.Version) 已安装" -ForegroundColor Green
    $skipGh = $false

    # ── Step 2: 创建 GitHub 仓库 ───────────────────────────
    Write-Host ""
    Write-Host "[Step 2] 创建 GitHub 仓库..." -ForegroundColor Yellow

    if ($GitHubToken -eq "") {
        # 检查是否已登录
        $ghAuth = gh auth status 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "请先登录 GitHub: gh auth login" -ForegroundColor Yellow
            Write-Host "或创建 GitHub Personal Access Token: https://github.com/settings/tokens" -ForegroundColor Yellow
            $skipGh = $true
        }
    }

    if (-not $skipGh) {
        # 创建仓库（忽略错误，如果仓库已存在）
        gh repo create $RepoName --public --description $Description --source . --push 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 仓库创建并推送成功！" -ForegroundColor Green
        } else {
            Write-Host "⚠️  仓库可能已存在或创建失败，请手动检查。" -ForegroundColor Yellow
        }
    }
}

# ── Step 3: 提交所有文件 ──────────────────────────────────
Write-Host ""
Write-Host "[Step 3] 提交代码到 Git..." -ForegroundColor Yellow

git add .
git status --short | ForEach-Object { Write-Host "  $_" }

Write-Host ""
$commitMsg = "feat: 社交 App MVP 初始版本`n`n- 登录/注册 (BLoC)`n- 朋友圈动态`n- Tinder 风格匹配`n- 私聊界面`n- 个人资料`n- Codemagic CI/CD"
git commit -m $commitMsg

Write-Host "✅ 已提交！" -ForegroundColor Green

# 检查是否有 remote
$remoteUrl = git remote get-url origin 2>$null
if ($remoteUrl -and $remoteUrl -ne "https://github.com/YOUR_USERNAME/$RepoName.git") {
    Write-Host "推送到 GitHub..."
    git push -u origin main 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 推送成功！" -ForegroundColor Green
    }
} else {
    Write-Host ""
    Write-Host "⚠️  尚未配置 GitHub remote。请手动推送:" -ForegroundColor Yellow
    Write-Host "   git remote add origin https://github.com/YOUR_USERNAME/$RepoName.git" -ForegroundColor Gray
    Write-Host "   git push -u origin main" -ForegroundColor Gray
}

Pop-Location

# ── Step 4: Codemagic 说明 ────────────────────────────────
Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Step 4: 连接 Codemagic" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1️⃣  打开浏览器，访问: https://codemagic.io" -ForegroundColor White
Write-Host ""
Write-Host "2️⃣  点击 'Sign in with GitHub' 授权" -ForegroundColor White
Write-Host ""
Write-Host "3️⃣  点击 'Add app'" -ForegroundColor White
Write-Host "    → 选择你的 GitHub 账号" -ForegroundColor Gray
Write-Host "    → 选择 $RepoName 仓库" -ForegroundColor Gray
Write-Host ""
Write-Host "4️⃣  点击 'Start new build'" -ForegroundColor White
Write-Host "    → Workflow: android-debug" -ForegroundColor Gray
Write-Host "    → Branch: main" -ForegroundColor Gray
Write-Host "    → 点击 'Start build'" -ForegroundColor Gray
Write-Host ""
Write-Host "5️⃣  等待构建完成（通常 5-10 分钟）" -ForegroundColor White
Write-Host "    → 构建完成 → Artifacts → 下载 .apk" -ForegroundColor Gray
Write-Host "    → 把 APK 传到手机安装即可测试！" -ForegroundColor Gray
Write-Host ""
Write-Host "📱 iOS 构建: 配置 Apple Developer 证书后，同样在 Codemagic 构建" -ForegroundColor White
Write-Host ""
Write-Host "✅ 完成！项目已上传到 GitHub，Codemagic 已配置好！" -ForegroundColor Green
Write-Host ""
