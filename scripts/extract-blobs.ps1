# ============================================================
# extract-blobs.ps1 - 从已连接设备提取 proprietary blobs
# 用法: 在 Recovery 模式下运行此脚本
# ============================================================
param(
    [string]$AdbPath = "C:\Users\yjind\Desktop\platform-tools\adb.exe",
    [string]$OutputDir = ".\vendor-blobs\onyx"
)

$ErrorActionPreference = "Stop"

Write-Host "=== 从 onyx (Redmi Turbo 4 Pro) 提取 proprietary blobs ===" -ForegroundColor Cyan

# 检查 ADB 连接
Write-Host "`n[1/5] 检查设备连接..." -ForegroundColor Yellow
$devices = & $AdbPath devices 2>&1
if ($devices -notmatch "recovery") {
    Write-Host "错误: 未检测到 Recovery 模式的设备!" -ForegroundColor Red
    Write-Host "请确保设备已进入 Recovery 并连接到 USB。" -ForegroundColor Red
    exit 1
}
Write-Host "  OK: 设备已连接" -ForegroundColor Green

# 创建输出目录
Write-Host "`n[2/5] 创建输出目录..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
Write-Host "  输出目录: $OutputDir" -ForegroundColor Green

# 提取分区列表
Write-Host "`n[3/5] 获取分区信息..." -ForegroundColor Yellow
& $AdbPath shell "ls -l /dev/block/bootdevice/by-name/" > "$OutputDir\partition-map.txt"
Write-Host "  分区映射已保存到 partition-map.txt" -ForegroundColor Green

# 读取 build.prop
Write-Host "`n[4/5] 提取 build 属性..." -ForegroundColor Yellow
& $AdbPath shell "cat /default.prop" > "$OutputDir\default.prop"
& $AdbPath shell "cat /system/build.prop" > "$OutputDir\system-build.prop" 2>$null
& $AdbPath shell "cat /vendor/build.prop" > "$OutputDir\vendor-build.prop" 2>$null
Write-Host "  build.prop 文件已提取" -ForegroundColor Green

# 提取关键分区镜像
Write-Host "`n[5/5] 提取关键分区镜像..." -ForegroundColor Yellow

# recovery_a 和 recovery_b 各 100MB
$partitions = @{
    "boot_a"    = "boot.img"
    "boot_b"    = "boot_b.img"
    "dtbo_a"    = "dtbo.img"
    "dtbo_b"    = "dtbo_b.img"
    "vbmeta_a"  = "vbmeta.img"
    "vbmeta_b"  = "vbmeta_b.img"
    "vendor_boot_a" = "vendor_boot.img"
    "vendor_boot_b" = "vendor_boot_b.img"
    "init_boot_a"  = "init_boot.img"
    "init_boot_b"  = "init_boot_b.img"
}

# 注意: recovery 镜像 100MB，拉取时间较长
Write-Host "  提示: recovery 分区每个 100MB，拉取需要一些时间..." -ForegroundColor Yellow

foreach ($part in $partitions.Keys) {
    $outFile = Join-Path $OutputDir $partitions[$part]
    Write-Host "  拉取 $part -> $outFile ..." -ForegroundColor Gray
    try {
        & $AdbPath pull "/dev/block/bootdevice/by-name/$part" $outFile 2>&1 | Out-Null
        $size = (Get-Item $outFile).Length
        Write-Host "    OK: $([math]::Round($size/1MB, 2)) MB" -ForegroundColor Green
    } catch {
        Write-Host "    失败: $_" -ForegroundColor Red
    }
}

# 生成提取报告
Write-Host "`n=== 提取完成 ===" -ForegroundColor Cyan
Write-Host "文件位置: $(Resolve-Path $OutputDir)" -ForegroundColor White
Write-Host ""
Write-Host "下一步:" -ForegroundColor Yellow
Write-Host "1. 将这些文件上传到你的 vendor 仓库" -ForegroundColor White
Write-Host "2. 在 GitHub 上创建 secrets 或配置 workflow 使用此 vendor 仓库" -ForegroundColor White
Write-Host "3. 运行 GitHub Actions workflow 构建 Recovery" -ForegroundColor White
