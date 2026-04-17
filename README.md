# v2ray-rules-sync

从 [Loyalsoldier/v2ray-rules-dat](https://github.com/Loyalsoldier/v2ray-rules-dat) 拉取 `geoip.dat` / `geosite.dat`，用 [v2dat](https://github.com/urlesistiana/v2dat) 解包为 mosdns 等工具可用的域名 / IP 列表文本。

## 生成文件

规则文件在分支 **`release`** 根目录；以下为 GitHub Raw 直链（将 `release` 换为标签名如 `sync-2026-04-17` 可固定到某次同步）。

| 文件 | 说明 | 下载 |
|------|------|------|
| `geosite_cn.txt` | geosite 列表 `cn` | [Raw](https://raw.githubusercontent.com/jianghaotian/v2ray-rules-sync/release/geosite_cn.txt) |
| `geosite_geolocation-!cn.txt` | geosite 列表 `geolocation-!cn` | [Raw](https://raw.githubusercontent.com/jianghaotian/v2ray-rules-sync/release/geosite_geolocation-%21cn.txt) |
| `geoip_cn.txt` | geoip 列表 `cn` | [Raw](https://raw.githubusercontent.com/jianghaotian/v2ray-rules-sync/release/geoip_cn.txt) |

## GitHub Actions

工作流：[`.github/workflows/sync-rules.yml`](.github/workflows/sync-rules.yml)

- **定时**：每天 **UTC 14:00**（**北京时间 22:00**）
- **手动**：在仓库 **Actions** 中选择 **Sync v2ray rules** → **Run workflow**
- **分支**：**`release`** 上**仅包含上述三个 txt**（根目录）。**远端尚无 `release` 时**用 orphan 创建（与 `main` 无共同祖先）；**已存在 `release` 时**在现有历史上**追加 commit**，形成按同步时间增长的线性历史。推送为普通 `git push`（快进）。
- **标签**：每次成功同步会打 **`sync-YYYY-MM-DD`**（日期为**北京时间**）；同一天多次同步会移动该标签指向最新提交

**`main`** 保留脚本与文档；**订阅规则请只用 `release` 分支或对应 tag**（例如 Raw、Release 下载等）。

## 本地执行

依赖：`curl` 或 `wget`、[v2dat](https://github.com/urlesistiana/v2dat)（`go install github.com/urlesistiana/v2dat@latest`）

```bash
chmod +x sync-rules.sh
# 默认写入 /opt/mosdns/rules/
sudo ./sync-rules.sh
```

输出目录可通过环境变量 **`RULES_DIR`** 覆盖，例如：

```bash
RULES_DIR="$HOME/mosdns/rules" ./sync-rules.sh
```

服务器定时任务示例（每天 4:15，与脚本注释一致）：

```cron
15 4 * * * /path/to/sync-rules.sh >> /path/to/sync-rules.log 2>&1
```

## 上游与许可

规则数据版权归上游项目；使用前请遵守 [v2ray-rules-dat](https://github.com/Loyalsoldier/v2ray-rules-dat) 及其数据源的许可说明。
