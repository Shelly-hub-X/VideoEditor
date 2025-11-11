# ========================================
# GitHub Actions Build Status Checker
# ========================================

param(
    [switch]$Watch,
    [int]$Interval = 30
)

$owner = "Shelly-hub-X"
$repo = "VideoEditor"

function Get-BuildStatus {
    try {
        # 获取最新的 workflow run
        $runsUrl = "https://api.github.com/repos/$owner/$repo/actions/runs?per_page=1"
        $runsResponse = Invoke-RestMethod -Uri $runsUrl -Method Get
        
        if ($runsResponse.workflow_runs.Count -eq 0) {
            Write-Host "❌ 没有找到构建任务" -ForegroundColor Red
            return $null
        }
        
        $latestRun = $runsResponse.workflow_runs[0]
        
        # 获取任务详情
        $jobsUrl = "https://api.github.com/repos/$owner/$repo/actions/runs/$($latestRun.id)/jobs"
        $jobsResponse = Invoke-RestMethod -Uri $jobsUrl -Method Get
        
        return @{
            Run = $latestRun
            Jobs = $jobsResponse.jobs
        }
    } catch {
        Write-Host "⚠️  API 调用失败: $($_.Exception.Message)" -ForegroundColor Yellow
        return $null
    }
}

function Show-BuildStatus {
    param($BuildInfo)
    
    if (-not $BuildInfo) { return }
    
    $run = $BuildInfo.Run
    $job = $BuildInfo.Jobs[0]
    
    Clear-Host
    
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║          🔨 GitHub Actions 构建状态监控                  ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # 状态图标
    $statusIcon = switch ($run.status) {
        "in_progress" { "🔄" }
        "completed" { 
            if ($run.conclusion -eq "success") { "✅" }
            elseif ($run.conclusion -eq "failure") { "❌" }
            else { "⚠️" }
        }
        "queued" { "⏳" }
        default { "❓" }
    }
    
    # 状态颜色
    $statusColor = switch ($run.status) {
        "in_progress" { "Yellow" }
        "completed" { 
            if ($run.conclusion -eq "success") { "Green" }
            else { "Red" }
        }
        default { "Gray" }
    }
    
    Write-Host "📊 构建信息" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "  状态: " -NoNewline
    Write-Host "$statusIcon $($run.status.ToUpper())" -ForegroundColor $statusColor
    
    if ($run.conclusion) {
        Write-Host "  结果: " -NoNewline
        $conclusionColor = if ($run.conclusion -eq "success") { "Green" } else { "Red" }
        Write-Host "$($run.conclusion.ToUpper())" -ForegroundColor $conclusionColor
    }
    
    Write-Host "  提交: " -NoNewline
    Write-Host "$($run.head_commit.message)" -ForegroundColor White
    
    Write-Host "  分支: " -NoNewline
    Write-Host "$($run.head_branch)" -ForegroundColor White
    
    Write-Host "  开始时间: " -NoNewline
    Write-Host "$($run.created_at)" -ForegroundColor White
    
    if ($run.status -eq "completed") {
        Write-Host "  完成时间: " -NoNewline
        Write-Host "$($run.updated_at)" -ForegroundColor White
        
        $duration = [datetime]$run.updated_at - [datetime]$run.created_at
        Write-Host "  耗时: " -NoNewline
        Write-Host "$([math]::Round($duration.TotalMinutes, 1)) 分钟" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "🔗 链接" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "  查看详情: " -NoNewline
    Write-Host "$($run.html_url)" -ForegroundColor Blue
    
    if ($run.status -eq "completed" -and $run.conclusion -eq "success") {
        Write-Host ""
        Write-Host "📦 下载构建产物" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "  1. 访问: $($run.html_url)" -ForegroundColor White
        Write-Host "  2. 滚动到页面底部 'Artifacts' 部分" -ForegroundColor White
        Write-Host "  3. 点击下载 'video-editor-windows.zip'" -ForegroundColor White
        Write-Host ""
        Write-Host "✅ 构建成功完成!" -ForegroundColor Green
    }
    elseif ($run.status -eq "in_progress") {
        Write-Host ""
        Write-Host "⏳ 构建进行中..." -ForegroundColor Yellow
        
        if ($job.started_at) {
            $elapsed = [datetime]::Now - [datetime]$job.started_at
            Write-Host "  已运行: $([math]::Round($elapsed.TotalMinutes, 1)) 分钟" -ForegroundColor Gray
            Write-Host "  预计总时长: 10-15 分钟" -ForegroundColor Gray
            
            # 进度估算
            $estimatedTotal = 12.5 # 平均 12.5 分钟
            $progress = [math]::Min(($elapsed.TotalMinutes / $estimatedTotal) * 100, 99)
            
            Write-Host ""
            Write-Host "  进度估算: " -NoNewline
            $progressBar = "█" * [math]::Floor($progress / 5) + "░" * (20 - [math]::Floor($progress / 5))
            Write-Host "$progressBar $([math]::Round($progress, 0))%" -ForegroundColor Yellow
        }
        
        if ($Watch) {
            Write-Host ""
            Write-Host "🔄 将在 $Interval 秒后刷新..." -ForegroundColor DarkGray
            Write-Host "   (按 Ctrl+C 停止监控)" -ForegroundColor DarkGray
        }
    }
    elseif ($run.status -eq "completed" -and $run.conclusion -eq "failure") {
        Write-Host ""
        Write-Host "❌ 构建失败!" -ForegroundColor Red
        Write-Host "   请访问上述链接查看错误日志" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# 主逻辑
if ($Watch) {
    Write-Host "开始监控构建状态 (每 $Interval 秒刷新一次)..." -ForegroundColor Cyan
    Write-Host "按 Ctrl+C 停止" -ForegroundColor Gray
    Write-Host ""
    
    while ($true) {
        $buildInfo = Get-BuildStatus
        Show-BuildStatus $buildInfo
        
        if ($buildInfo.Run.status -eq "completed") {
            Write-Host "构建已完成,停止监控" -ForegroundColor Green
            break
        }
        
        Start-Sleep -Seconds $Interval
    }
} else {
    $buildInfo = Get-BuildStatus
    Show-BuildStatus $buildInfo
    
    Write-Host ""
    Write-Host "💡 提示: 使用 -Watch 参数可以自动刷新状态" -ForegroundColor DarkGray
    Write-Host "   例如: .\check_build_status.ps1 -Watch" -ForegroundColor DarkGray
    Write-Host ""
}
