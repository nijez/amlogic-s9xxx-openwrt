# 金维组网 · 本 fork 定制说明

本仓库为 [ophub/amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt) 的 fork，用于打出**金维组网**斐讯 N1（`s905d`）刷机包。

## 注入内容

| 路径 | 作用 |
| --- | --- |
| `files/` | 供 system-image（`mv files openwrt/files`）与 packaging `openwrt_files` |
| `config/imagebuilder/files/` | **官方 ImageBuilder** 的 custom FILES（当前出包路径） |
| `jinwei-files-overlay.tar.gz` | 同上内容的打包副本（无密钥） |

含：DHCP 旁路由、SoftAP（默认 PSK `88888888`；**只看上行**：有网关关、断网开）、captive 无 `address=/#/`、`sdwan-agent`（含 softap 上报）、配网页自动绑定文案（无 SoftAP 内 HTTPS 云管理按钮）、`:81` UI。  
`ENROLL_TOKEN` 仅为 `__ENROLL_TOKEN__` 占位；**勿**提交真值。构建可用 Actions secret 注入。

**不含** HDMI 登录界面（尚未设计）。

## 出包（当前）

Actions → **Build OpenWrt using ImageBuilder** → Run workflow：

- `releases_branch` = `immortalwrt:24.10.6`
- `openwrt_board` = `s905d`
- `openwrt_kernel` = `6.1.y_6.12.y`（主交付 k6.1.x，顺带 k6.12）
- `auto_kernel` = true
- `builder_name` = `ophub`

示例成功 run：https://github.com/nijez/amlogic-s9xxx-openwrt/actions/runs/40651845895

成功后在 [Releases](https://github.com/nijez/amlogic-s9xxx-openwrt/releases) 下载 `*s905d*.img.gz`。

```bash
gh run watch <run_id> -R nijez/amlogic-s9xxx-openwrt
gh release list -R nijez/amlogic-s9xxx-openwrt
gh release download -R nijez/amlogic-s9xxx-openwrt <tag> -p '*s905d*k6.1*.img.gz'
```

## 说明

专用「rootfs URL + openwrt_files」workflow 草稿在 factory-sdwan 仓  
`stage0/firmware/.github-workflow-drafts/build-jinwei-n1-packaging.yml`；  
推进 `.github/workflows/` 需要带 `workflow` scope 的 token。
