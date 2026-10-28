# 金维组网 · 本 fork 定制说明

本仓库为 [ophub/amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt) 的 fork，用于打出**金维组网**斐讯 N1（`s905d`）刷机包。

## 注入内容

| 路径 | 作用 |
| --- | --- |
| `files/` | ophub packaging `openwrt_files`；亦供官方 system-image `mv files openwrt/files` |
| `config/imagebuilder/files/` | 官方 ImageBuilder 路径的 custom FILES |
| `jinwei-files-overlay.tar.gz` | 同上内容的打包副本（无密钥） |
| `.github/workflows/build-jinwei-n1.yml` | 金维一键：下载 ImmortalWrt rootfs → 注入 FILES → 打 `s905d` 镜像 |

**勿**把 enrollment 真值、密码提交进本仓。可选 Actions secret：`JINWEI_ENROLL_TOKEN`。

## 出包

Actions → **Build Jinwei N1 (s905d)** → Run workflow（默认板 `s905d`）。

产物：Artifacts `jinwei-n1-s905d-images`，成功时另有 Release `jinwei-n1-*`。

也可跑官方 **Build OpenWrt using ImageBuilder**（`immortalwrt:*` + board `s905d`），会吃到 `config/imagebuilder/files/`。
