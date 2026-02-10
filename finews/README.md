# 金融日报监控系统 v3

## 概述

自动抓取金融新闻，每日三次生成 Markdown 报告。

## 当前状态 (v3 测试结果)

### ✅ 工作正常

| 来源 | 类型 | 状态 | 条目 |
|------|------|------|------|
| BBC Business | RSS | ✅ 完美 | 8条 |
| CNBC Tech | RSS | ⚠️ 空 | 0条 |
| Yahoo Finance | RSS | ❌ 429 | 失败 |

### 🔍 中国源

| 来源 | 方式 | 状态 |
|------|------|------|
| 财新金融 | 浏览器快照 | ✅ 内容丰富 |
| Reuters 中国 | 浏览器快照 | ✅ 内容丰富 |
| 华尔街见闻 | 浏览器快照 | 待测试 |

## 文件结构

```
~/docsvault/financial-monitor/
├── 金融日报-2026-02-10.md
├── latest.md
└── README.md
```

## Cron 调度

| 任务 | 时间 | 脚本 |
|------|------|------|
| 早间 | 08:00 | v3 |
| 午间 | 12:00 | v3 |
| 晚间 | 20:00 | v3 |

## 运行

```bash
node /Users/mbot/clawd/scripts/financial-monitor-v3.js
```

## 输出示例

```markdown
# 金融日报 - 2026-02-10

## 📊 今日概览
| 市场 | 指数 | 点位 | 涨跌 |
| A股 | 上证指数 | 4,127.77 | +0.11% |

## 🌍 国际市场 (RSS)
- BBC headlines...

## 🇨🇳 中国市场 (快照)
- 财新金融 headlines...
- Reuters 中国 headlines...

## 📈 市场数据
表格展示 A股/港股/美股/大宗商品/外汇
```

## 问题与解决方案

### 问题：HTTP 抓取中国网站失败

**原因**：财新、新浪等使用 JavaScript 渲染，simple HTTP 无法获取

**方案**：
1. 使用浏览器快照（当前方案）
2. 集成 OpenClaw browser API（未来改进）

### 问题：RSS 源受限

- BBC ✅ 完美
- CNBC ⚠️ 空内容
- Yahoo ❌ 429

**方案**：
1. 添加更多可靠 RSS
2. 使用代理

## 未来改进

1. **浏览器自动化**
   ```javascript
   // 集成 OpenClaw browser 工具
   await browser.open(url);
   await browser.snapshot();
   ```

2. **行情 API**
   - FRED (美联储数据)
   - Yahoo Finance API
   - A股/港股实时行情

3. **去重机制**
   - 按标题相似度去重
   - 按来源聚类
