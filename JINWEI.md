# 金维组网 · 本 fork 定制说明

本仓库为 [ophub/amlogic-s9xxx-openwrt](https://github.com/ophub/amlogic-s9xxx-openwrt) 的 fork，用于打出**金维组网**斐讯 N1（`s905d`）刷机包。

## 注入内容

| 路径 | 作用 |
| --- | --- |
| `files/` | 供 system-image（`mv files openwrt/files`）与 packaging `openwrt_files` |
| `config/imagebuilder/files/` | **官方 ImageBuilder** 的 custom FILES（当前出包路径） |
| `jinwei-files-overlay.tar.gz` | 同上内容的打包副本（无密钥） |

含：DHCP 旁路由、SoftAP `金维组网-XXXX`、`sdwan-agent`、`:81` UI、setup 页。  
`ENROLL_TOKEN` 仅为 `__ENROLL_TOKEN__` 占位；**勿**提交真值。

## 出包（当前）

Actions → **Build OpenWrt using ImageBuilder** → Run workflow：

- `releases_branch` = `immortalwrt:24.10.6`（或 `immortalwrt:25.12.2`）
- `openwrt_board` = `s905d`
- `builder_name` = `ophub`

示例 run：https://github.com/nijez/amlogic-s9xxx-openwrt/actions/runs/40651845895

成功后在 [Releases](https://github.com/nijez/amlogic-s9xxx-openwrt/releases) 下载 `*s905d*.img.gz`。

```bash
gh run watch <run_id> -R nijez/amlogic-s9xxx-openwrt
gh release list -R nijez/amlogic-s9xxx-openwrt
gh release download -R nijez/amlogic-s9xxx-openwrt <tag> -p '*s905d*.img.gz'
```

## 说明

专用「rootfs URL + openwrt_files」workflow 草稿在 factory-sdwan 仓  
`stage0/firmware/.github-workflow-drafts/build-jinwei-n1-packaging.yml`；  
推进 `.github/workflows/` 需要带 `workflow` scope 的 token。
