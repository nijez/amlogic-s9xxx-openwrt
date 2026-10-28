此目录为占位说明，不是完整可覆盖的 LuCI theme。

阶段0：用 stage0/branding/www/login.html 作为登录形象参考；
设备日常入口为 :81「金维组网」状态页（stage0/device-ui）。

阶段1 ImageBuilder：
1. 将 branding/files/ 与 firmware/files/ 合并进 FILES=
2. 若目标镜像主题为 bootstrap / material，再按该版 LuCI 的 view 路径
   覆盖 header.htm / sysauth.htm，把标题改成「金维组网」，去掉 Powered by 类文案。
3. 或安装自有 theme 包 luci-theme-jinwei（未做，阶段1 任务）。

切勿把含密钥的文件放进本树。
