# OrangeFox Recovery — Redmi Turbo 4 Pro (onyx)

通过 GitHub Actions 自动构建 Redmi Turbo 4 Pro 的 OrangeFox R12.1 Recovery。

## 设备信息

| 项目 | 值 |
|------|-----|
| 设备 | Redmi Turbo 4 Pro |
| 代号 | onyx (fox_onyx) |
| SOC | Qualcomm SM8735 (Snapdragon 8s Gen 3) |
| 平台 | xiaomi_sm8735 |
| 架构 | arm64-v8a (with 32-bit compat) |
| 内核 | 6.6.77-android15-8 (prebuilt from device) |
| 屏幕 | 1080×2400 |
| A/B | Virtual A/B, 独立 recovery 分区 |
| 文件系统 | EROFS (system/vendor) + F2FS (data) + EXT4 (cache) |
| 动态分区 | Super 分区 (11 GB) |
| ROM | HyperOS (Android 15, SDK 34) |
| Recovery | OrangeFox R12.1 (99.87.36) |

## 仓库结构

```
.
├── .github/workflows/
│   └── build-orangefox.yml    # GitHub Actions 构建工作流
├── device/xiaomi/onyx/
│   ├── AndroidProducts.mk      # 产品声明
│   ├── BoardConfig.mk          # 板级配置 (分区/内核/文件系统)
│   ├── omni_onyx.mk            # 产品定义 (指纹/属性/屏幕)
│   ├── vendorsetup.sh          # OrangeFox 构建环境变量
│   ├── prebuilt/
│   │   ├── kernel              # 预编译内核 (6.6.77, ~35 MB)
│   │   └── dtbo.img            # DTBO 镜像 (~24 MB)
│   ├── recovery/root/
│   │   ├── fstab.onyx          # Recovery 挂载表
│   │   └── init.recovery.qcom.rc  # Recovery init 脚本
│   └── sepolicy/               # SELinux 策略 (预留)
├── vendor/xiaomi/onyx/
│   └── BoardConfigVendor.mk    # Vendor 配置 (加密/QCOM FBE)
├── device-config.yml           # 从设备 ADB 提取的完整配置记录
├── scripts/
│   ├── extract-blobs.ps1       # Windows 端 blob 提取脚本
│   └── unpack_boot.py          # boot.img 解包工具
└── README.md
```

## 工作原理

GitHub Actions 工作流 (`build-orangefox.yml`) 执行以下步骤：

1. **检出仓库** — 获取设备树和 vendor 配置
2. **清理磁盘** — 使用 slimhub_actions 释放 ~50 GB
3. **添加 Swap** — 16 GB swap 防止 OOM
4. **安装依赖** — 通过 OrangeFox 官方脚本安装构建依赖 + ccache
5. **同步源码** — 执行 `orangefox_sync.sh --branch 12.1` 获取 OrangeFox + TWRP 源码 (~45 GB)
6. **安装设备树** — 将本仓库的 `device/xiaomi/onyx` 复制到源码树
7. **编译** — `lunch twrp_onyx-eng && mka recoveryimage`
8. **上传产物** — `recovery.img`、`OrangeFox-*.zip` 作为 GitHub Artifact 保存 30 天

## 触发构建

### 自动触发

推送到 main 分支且修改了以下路径之一时自动触发：
- `device/**`
- `vendor/**`
- `.github/workflows/build-orangefox.yml`

### 手动触发

1. 打开 [Actions 页面](https://github.com/YJDDGT/orangefox-onyx-build/actions)
2. 选择 **"Build OrangeFox Recovery - onyx"**
3. 点击 **Run workflow**
4. (可选) 勾选 `Clean build` 进行全新编译

> 首次构建需要 45–90 分钟（源码同步 ~30 分钟 + 编译 ~30 分钟）。后续增量构建约 15–30 分钟。

## 下载产物

构建完成后：

1. 进入对应 workflow run 页面
2. 底部 **Artifacts** 区域下载 `OrangeFox-onyx-R12.1`
3. 解压得到 `recovery.img` 和/或 `OrangeFox-*.zip`

产物自动保留 **30 天**。

## 刷入 Recovery

```bash
# 方法一: Fastboot 刷入 (recommended)
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img

# 方法二: 临时启动测试
fastboot boot recovery.img

# 方法三: 从已有 Recovery 刷入 zip
# 将 OrangeFox-*.zip 放入 SD 卡, 在 recovery 中 Install
```

⚠️ 刷机有风险，操作前请备份数据。

## 修改与维护

### 更新内核

当系统更新后内核变化时需要替换 `device/xiaomi/onyx/prebuilt/kernel`：

```bash
# 从已连接的设备提取
adb pull /dev/block/bootdevice/by-name/boot_a boot.img
python3 scripts/unpack_boot.py boot.img boot_extracted/
cp boot_extracted/kernel device/xiaomi/onyx/prebuilt/kernel
```

### 修改构建配置

- **分区 / 加密 / 内核参数**: 编辑 `device/xiaomi/onyx/BoardConfig.mk`
- **OrangeFox 功能开关 / 屏幕**: 编辑 `device/xiaomi/onyx/vendorsetup.sh`
- **产品属性 / 指纹**: 编辑 `device/xiaomi/onyx/omni_onyx.mk`
- **挂载表**: 编辑 `device/xiaomi/onyx/recovery/root/fstab.onyx`

### 更新 DTBO

```bash
adb pull /dev/block/bootdevice/by-name/dtbo_a dtbo.img
cp dtbo.img device/xiaomi/onyx/prebuilt/dtbo.img
```

## 常见问题

### 构建失败: repo sync 网络超时

OrangeFox 源码约 45 GB，网络波动可能导致 `repo sync` 失败。**重新触发 workflow** 即可 — 已下载的部分会复用，不会重新下载。

### 构建失败: 磁盘空间不足

如果出现 `No space left on device`：
- 在 workflow_dispatch 中勾选 `Clean build` 后再跑
- 如果持续不足，可以考虑减少 `-j` 并行数

### 构建失败: OOM (内存不足)

已配置 16 GB swap 应对。如果仍然 OOM，可减少编译并行数：

```yaml
# 在 build-orangefox.yml 中修改
mka adbd recoveryimage -j$(nproc --all)
# 改为
mka adbd recoveryimage -j4
```

### 产物中没有 recovery.img

检查构建日志中 `lunch` 和 `mka` 的输出。常见原因：
- 设备树路径不匹配 → 确认 `device/xiaomi/onyx/` 存在
- vendor/twrp 源码未同步 → 确认 sync 步骤成功
- prebuilt kernel 缺失 → 确认 `device/xiaomi/onyx/prebuilt/kernel` 存在

## 参考来源

- 本 Recovery 原始构建者: ireddragonicy
- OrangeFox 官方: https://gitlab.com/OrangeFox
- OrangeFox sync 工具: https://gitlab.com/OrangeFox/sync
- 构建参考: 社区 OrangeFox-Recovery-Builder 项目

## License

设备树配置文件按 OrangeFox 项目协议发布。预编译内核 (kernel/dtbo) 提取自原厂设备，版权归 Xiaomi/Qualcomm 所有。
