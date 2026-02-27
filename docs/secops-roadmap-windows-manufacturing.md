# 安全运维 → 安全运营（SOC/SecOps）转型路线
## Windows 终端 × 制造业场景 · 12 周系统学习计划

> **适用对象**：已具备安全运维基础、目标转型为 SOC/SecOps 工程师  
> **行业侧重**：制造业（OT/IT 混合环境）  
> **平台重点**：Windows 终端、Active Directory、Windows Event Log、Sysmon  
> **每日投入**：8 小时（上午 4 h 理论/实验 + 下午 4 h 实操/产出）  
> **文档版本**：v1.0 · 2026-02

---

## 目录

1. [总体路线图](#总体路线图)
2. [第 1–2 周：SOC 基础与告警分级体系](#第-12-周soc-基础与告警分级体系)
3. [第 3–4 周：Windows 日志与 Sysmon 深度实战](#第-34-周windows-日志与-sysmon-深度实战)
4. [第 5–6 周：SIEM 查询语言与检测用例（KQL）](#第-56-周siem-查询语言与检测用例kql)
5. [第 7–8 周：AD 攻击链研判与 EDR 深度使用](#第-78-周ad-攻击链研判与-edr-深度使用)
6. [第 9–10 周：制造业 OT/IT 边界与业务影响评估](#第-910-周制造业-otit-边界与业务影响评估)
7. [第 11–12 周：自动化工程化与综合演练](#第-1112-周自动化工程化与综合演练)
8. [SOC 日常能力清单（常驻参考）](#soc-日常能力清单常驻参考)
9. [KQL 检测用例库（12 条）](#kql-检测用例库12-条)
10. [自动化小工具任务书](#自动化小工具任务书)
11. [参考资料（与周次绑定）](#参考资料与周次绑定)
12. [验收标准总表](#验收标准总表)

---

## 总体路线图

```
Week 1-2   Week 3-4   Week 5-6   Week 7-8   Week 9-10  Week 11-12
────────── ────────── ────────── ────────── ────────── ──────────
SOC基础    Windows    SIEM/KQL   AD攻击链   OT/IT边界  自动化+
告警分级   日志体系   检测用例   EDR研判    制造业场景  综合演练
SOP框架    Sysmon     10+规则    横向/持久  业务影响    成果输出
```

**每周产出物一览**

| 周次 | 核心产出物 |
|------|-----------|
| W1   | SOC 告警分级标准 v1、升级矩阵 |
| W2   | 告警研判 SOP × 3、复盘模板 |
| W3   | Windows 日志采集清单、Sysmon 配置文件 |
| W4   | 10 条高价值事件 ID 速查卡 |
| W5   | KQL 检测规则 ≥ 10 条（含误报说明） |
| W6   | SIEM 仪表板截图/导出 + 误报降噪方案 |
| W7   | AD 攻击链思维导图、Pass-the-Hash 研判手册 |
| W8   | EDR 研判 Runbook × 3 |
| W9   | OT 资产台账模板、OT/IT 边界防控清单 |
| W10  | 制造业勒索/供应链应急剧本 |
| W11  | Python/PowerShell 工具 × 3（可运行） |
| W12  | 综合演练报告 + 个人能力画像 |

---

## 第 1–2 周：SOC 基础与告警分级体系

### 学习目标

- 理解 SOC 岗位职责与与安全运维的区别
- 掌握告警生命周期：接收 → 研判 → 分级 → 处置 → 关闭
- 输出可落地的分级标准和升级条件

### W1 每日安排

| 天 | 上午（理论/实验，4 h） | 下午（实操/产出，4 h） |
|---|---|---|
| Day 1 | 阅读：NIST SP 800-61r2 §2–§3（事件响应生命周期）| 整理：将 800-61r2 生命周期翻译成中文流程图（draw.io 或纸质） |
| Day 2 | 阅读：SANS FOR508 课程简介 + 公开版 SOC 职责说明 | 产出：起草"告警分级标准 v1"（P1/P2/P3/P4 定义，含制造业示例） |
| Day 3 | 研究：MITRE ATT&CK 导航器，熟悉战术/技术/子技术层级 | 实操：在 ATT&CK Navigator 中标记制造业常见技术（勒索/横向） |
| Day 4 | 阅读：告警疲劳（Alert Fatigue）白皮书（Elastic/Palo Alto 公开版） | 产出：制定"误报率控制目标"（如 P1 误报 < 5%）并写入分级标准 |
| Day 5 | 复习 W1 所有内容 | 产出：**告警分级标准 v1（最终版）** + 升级矩阵（升级条件、联系人） |

**W1 输出检查清单**

- [ ] 告警分级标准 v1（含 P1–P4 定义、响应时限、制造业举例）
- [ ] 升级矩阵（何种条件升级、升给谁、如何通知）
- [ ] MITRE ATT&CK 制造业标注导航图（截图保存）

### W2 每日安排

| 天 | 上午 | 下午 |
|---|---|---|
| Day 6 | 学习：告警研判方法论（Pyramid of Pain、Kill Chain 与 ATT&CK 对应）| 搭建：本地 Windows 10 虚拟机 + 开启所有审计策略（auditpol /get /category:*） |
| Day 7 | 阅读：证据保全原则（RFC 3227）；学习数字取证链 | 产出：**证据保全 SOP**（截图→哈希→归档路径→保管人） |
| Day 8 | 学习：告警研判 SOP 框架（5W1H：Who/What/When/Where/Why/How）| 产出：**告警研判 SOP × 1**（以钓鱼邮件为例） |
| Day 9 | 学习：复盘方法（Blameless Post-Mortem）| 产出：**告警研判 SOP × 2**（以暴力破解为例）+ **复盘模板 v1** |
| Day 10 | 综合练习：用自建虚拟机模拟一次登录失败告警 | 产出：完整走完一次告警生命周期，填写复盘模板；**告警研判 SOP × 3**（以异常进程为例） |

**W2 输出检查清单**

- [ ] 证据保全 SOP（含哈希验证步骤）
- [ ] 告警研判 SOP × 3（钓鱼/暴力破解/异常进程）
- [ ] 复盘模板 v1（时间线、根因、改进项三栏）
- [ ] 本地测试虚拟机就绪，审计策略已全开

---

## 第 3–4 周：Windows 日志与 Sysmon 深度实战

### 学习目标

- 熟悉 Windows 核心日志通道及高价值事件 ID
- 部署并调优 Sysmon，理解每个事件类型的安全意义
- 能在 Event Viewer / PowerShell 中快速定位可疑事件

### 关键日志通道速查

| 日志通道 | 路径 | 重点事件 ID |
|---------|------|------------|
| Security | `%SystemRoot%\System32\winevt\Logs\Security.evtx` | 4624/4625/4648/4688/4698/4720/4732/4776 |
| System | `…\System.evtx` | 7045（新服务）、104（日志清除）、1102 |
| PowerShell Operational | `Microsoft-Windows-PowerShell/Operational` | 4103/4104（Script Block）、4105/4106 |
| Task Scheduler | `Microsoft-Windows-TaskScheduler/Operational` | 106（任务注册）、200/201（执行/完成） |
| WMI Activity | `Microsoft-Windows-WMI-Activity/Operational` | 5857/5858/5859/5860（WMI 持久化） |
| Sysmon | `Microsoft-Windows-Sysmon/Operational` | 1/3/7/8/10/11/12/13/15/17/18/22/23 |

### W3 每日安排

| 天 | 上午 | 下午 |
|---|---|---|
| Day 11 | 阅读：Windows Security Auditing 官方文档；理解 Logon Type 说明表 | 实操：在 VM 上手动触发 4624/4625/4648，用 PowerShell 提取并分析 |
| Day 12 | 学习：进程创建（4688）与命令行审计开启（需 GPO）| 产出：GPO 配置截图 + 提取 4688 事件并过滤 PowerShell/cmd 的 PowerShell 脚本 |
| Day 13 | 学习：账户管理事件（4720/4732/4756 组成员变更）| 实操：创建/删除账户并观察日志；写 PowerShell 查询"过去 24h 新增账户" |
| Day 14 | 学习：计划任务（4698/4699/4700）与服务安装（7045）| 产出：计划任务创建告警查询脚本 + 速查卡（纸质/Markdown） |
| Day 15 | 复习 W3 + 练习：模拟攻击者清除日志（1102）并用脚本检测 | 产出：**Windows 十大高价值事件 ID 速查卡**（Markdown 格式） |

**W3 输出检查清单**

- [ ] PowerShell 提取 4624/4625 事件脚本（可运行）
- [ ] GPO 截图（已开启命令行审计）
- [ ] "过去 24h 新增账户"查询脚本
- [ ] 计划任务创建告警查询脚本

### W4 每日安排

| 天 | 上午 | 下午 |
|---|---|---|
| Day 16 | 学习：Sysmon 架构与 SwiftOnSecurity 配置文件解析 | 实操：在 VM 安装 Sysmon + 部署 SwiftOnSecurity 配置，验证 Event 1 输出 |
| Day 17 | 深入：Sysmon Event 3（网络连接）+ Event 22（DNS 查询）| 实操：模拟 DNS 隧道（nslookup 大量子域名），用 Sysmon 捕获并分析 |
| Day 18 | 深入：Sysmon Event 7（Image Load/DLL）+ Event 8（CreateRemoteThread）| 实操：用 Process Hacker 触发 CreateRemoteThread，观察 Event 8；写过滤查询 |
| Day 19 | 深入：Sysmon Event 10（ProcessAccess/LSASS dump）+ Event 11（文件创建）| 实操：用 ProcDump 对 lsass dump，捕获 Event 10；写 LSASS 保护规则 |
| Day 20 | 综合：调优 Sysmon 配置文件，减少噪声（排除已知白名单进程）| 产出：**定制化 Sysmon 配置文件 v1**（含注释说明每条规则意图） |

**W4 输出检查清单**

- [ ] Sysmon 安装部署 SOP
- [ ] 定制化 Sysmon 配置文件 v1（含 5+ 自定义规则）
- [ ] LSASS 访问检测查询（PowerShell/Event Viewer 过滤器）
- [ ] 10 大高价值 Sysmon 事件速查卡

---

## 第 5–6 周：SIEM 查询语言与检测用例（KQL）

> **选定语言**：KQL（Kusto Query Language），适用于 Microsoft Sentinel / Microsoft Defender XDR / Azure Monitor。  
> 若企业使用 Splunk，可将以下 KQL 用例对照 SPL 语法翻译。

### W5 每日安排

| 天 | 上午 | 下午 |
|---|---|---|
| Day 21 | KQL 基础：`where`/`project`/`summarize`/`extend`/`join`；官方 KQL 速查手册 | 实操：在 Azure Log Analytics Demo 工作区运行 10 条基础查询 |
| Day 22 | KQL 进阶：`mv-expand`、`parse`、`parse_json`、`bag_unpack`；时间函数 | 实操：解析 Security 事件日志中的 CommandLine 字段，提取可疑参数 |
| Day 23 | 检测规则编写方法论：TTP → 数据源 → 查询逻辑 → 误报处理 | 产出：检测规则 × 3（暴力破解/横向 SMB/异常 DNS）草稿 |
| Day 24 | 学习：阈值告警 vs 行为基线告警；Entity Behavior Analytics | 产出：检测规则 × 3（LSASS 访问/可疑 PowerShell/计划任务创建）草稿 |
| Day 25 | 复习 + 完善规则；为每条规则补充"误报场景"和"降噪方案" | 产出：**KQL 检测规则 ≥ 6 条**（带误报说明，格式化 Markdown） |

### W6 每日安排

| 天 | 上午 | 下午 |
|---|---|---|
| Day 26 | 学习：Sentinel 分析规则部署（Scheduled Query/NRT）；告警→事件关联 | 实操：在 Sentinel Demo/试用实例部署 W5 中的 3 条规则 |
| Day 27 | 学习：Watchlist、Threat Intelligence（TI）集成、IP/域名信誉查询 | 实操：创建 Watchlist（制造业关键资产 IP）并关联告警规则 |
| Day 28 | 学习：Workbook（仪表板）设计；运营指标（MTTD/MTTR）可视化 | 产出：SOC 日常仪表板（至少含：告警趋势/Top 攻击源/账户异常活动）截图 |
| Day 29 | 学习：误报管理流程；调优规则（排除域名白名单/IP 白名单）| 产出：误报降噪方案文档（针对每条规则的 2–3 个降噪策略） |
| Day 30 | 综合：再写 4 条制造业专属检测规则（OT 资产异常访问/远程运维通道异常）| 产出：**KQL 检测规则总计 ≥ 10 条**（最终版，提交至规则库） |

**W5–W6 输出检查清单**

- [ ] KQL 语法速查卡（个人版）
- [ ] KQL 检测规则 ≥ 10 条（含误报说明，见[检测用例库](#kql-检测用例库10-条)）
- [ ] Sentinel 规则部署截图（至少 3 条在线运行）
- [ ] SOC 仪表板截图（3 个关键指标面板）
- [ ] 误报降噪方案文档

---

## 第 7–8 周：AD 攻击链研判与 EDR 深度使用

### 学习目标

- 理解 AD 核心概念（域、DC、Kerberos、LDAP、GPO）
- 掌握凭据窃取、横向移动、持久化三大攻击阶段的检测要点
- 能用 EDR 控制台完成端点调查、进程树分析、隔离操作

### AD 常见攻击链速查

```
凭据窃取                横向移动                持久化
──────────────         ──────────────         ──────────────
LSASS Dump             Pass-the-Hash           计划任务
DCSync                 Pass-the-Ticket         注册表 Run Key
Kerberoasting          WMI/WinRM 横向          WMI 订阅
AS-REP Roasting        PsExec/SMB 横向         DLL 劫持
NTLM Relay             RDP 横向                账户后门（新管理员）
```

### W7 每日安排

| 天 | 上午 | 下午 |
|---|---|---|
| Day 31 | 阅读：AD 攻击与防御（《The Hacker Playbook 3》AD 章节） + Kerberos 认证流程图 | 实操：在 Windows Server 2019 VM 搭建单域环境（DC + 1 工作站） |
| Day 32 | 学习：Pass-the-Hash（PtH）原理 + 检测方法（Event 4648/4624 Logon Type 3）| 实操：用 Mimikatz 执行 PtH，在 DC 日志中定位告警事件，写研判手册草稿 |
| Day 33 | 学习：Kerberoasting 原理 + 检测（Event 4769 加密类型 0x17）| 实操：执行 Kerberoasting，写 KQL/PowerShell 检测查询 |
| Day 34 | 学习：DCSync 原理 + 检测（Event 4662 + Directory Replication 权限）| 实操：用 Mimikatz dcsync，在日志中确认并写研判规则 |
| Day 35 | 综合：绘制 AD 攻击链思维导图（从初始访问到域控沦陷）| 产出：**AD 攻击链思维导图** + **Pass-the-Hash 研判手册 v1** |

**W7 输出检查清单**

- [ ] 单域 AD 实验环境（可截图验证）
- [ ] AD 攻击链思维导图（含事件 ID 标注）
- [ ] Pass-the-Hash 研判手册（5W1H + KQL 查询 + 处置步骤）
- [ ] Kerberoasting 检测 KQL 查询（可运行）
- [ ] DCSync 检测规则草稿

### W8 每日安排

| 天 | 上午 | 下午 |
|---|---|---|
| Day 36 | 学习：EDR 核心功能（进程树/时间轴/网络连接/文件操作/注册表）；以 Microsoft Defender for Endpoint（MDE）为例 | 实操：在 MDE 或 Wazuh（开源替代）中查看端点事件时间轴 |
| Day 37 | 学习：MDE 告警等级与 ATT&CK 技术映射；调查图（Investigation Graph）| 实操：复现横向移动场景，在 EDR 中追踪进程树并截图 |
| Day 38 | 学习：EDR 隔离操作、取证采集（实时响应）、IOC 封堵 | 产出：**EDR 端点隔离 Runbook**（包含前置确认、隔离命令、业务影响评估、恢复步骤） |
| Day 39 | 学习：EDR 调优（误报排除、白名单管理、检测规则订阅）| 产出：**EDR 误报处理 Runbook** + 白名单申请流程 |
| Day 40 | 综合演练：给定一个 EDR 告警截图，完整输出研判报告 | 产出：**EDR 研判报告模板**（含：告警摘要/调查发现/研判结论/处置建议） |

**W8 输出检查清单**

- [ ] EDR 端点隔离 Runbook
- [ ] EDR 误报处理 Runbook
- [ ] EDR 研判报告模板
- [ ] 横向移动场景进程树截图（实验截图）

---

## 第 9–10 周：制造业 OT/IT 边界与业务影响评估

### 学习目标

- 理解 OT 环境特殊性（Purdue 模型、协议差异、变更窗口极窄）
- 掌握制造业常见威胁的处置优先级和业务影响评估方法
- 输出可落地的制造业专属应急剧本

### 制造业威胁场景速查

| 威胁类型 | 典型 IoC | 业务影响 | 处置优先级 |
|---------|---------|---------|----------|
| 勒索软件 | 大量文件加密（.locked/.enc）、横向 SMB 扫描 | 生产线停机、数据不可用 | P1（最高） |
| 供应链攻击 | 第三方软件更新异常、异常签名证书 | 隐蔽后门、长期潜伏 | P1 |
| 远程运维通道滥用 | TeamViewer/AnyDesk 异常会话、非工作时间连接 | 横向入侵跳板 | P2 |
| 弱口令 & 资产暴露 | 默认凭据登录、互联网直连 OT 设备 | 初始访问入口 | P2 |
| OT 协议滥用 | 异常 Modbus/DNP3/S7comm 读写 | 设备操控、安全事故 | P1 |
| 内部威胁 | 离职员工账户活动、大量数据导出 | 知识产权泄露 | P2 |

### W9 每日安排

| 天 | 上午 | 下午 |
|---|---|---|
| Day 41 | 学习：Purdue 模型（L0–L4）；IT 与 OT 安全差异；IEC 62443 标准概览 | 产出：绘制本厂 OT/IT 边界示意图（匿名化）；识别 IT/OT 跨界资产 |
| Day 42 | 学习：OT 常见协议（Modbus/Profinet/OPC-UA）及其安全缺陷 | 实操：使用 Wireshark 捕获模拟 Modbus 流量；识别读写命令 |
| Day 43 | 学习：TRITON/TRISIS 事件分析（ICS 攻击典型案例）；Dragos Year in Review | 产出：**OT 资产台账模板**（资产名称/IP/协议/业务功能/变更窗口/负责人） |
| Day 44 | 学习：远程运维通道安全（合法 vs 非法 RDP/VPN/TeamViewer）；"跳板机"管控 | 产出：**OT/IT 边界防控清单**（防火墙规则建议/会话审计/MFA 要求） |
| Day 45 | 综合：制造业业务影响评估方法（生产损失/安全风险/合规代价）| 产出：**业务影响评估模板**（含：停产损失/h、法规罚款、声誉损失三维） |

**W9 输出检查清单**

- [ ] OT/IT 边界示意图
- [ ] OT 资产台账模板（≥ 10 字段）
- [ ] OT/IT 边界防控清单
- [ ] 业务影响评估模板

### W10 每日安排

| 天 | 上午 | 下午 |
|---|---|---|
| Day 46 | 学习：制造业勒索软件典型路径（邮件→IT→横向→OT）；CISA 勒索软件指南 | 产出：**制造业勒索应急剧本 v1**（检测→遏制→隔离→通知→恢复，含工厂场景决策树） |
| Day 47 | 学习：供应链攻击案例（SolarWinds/3CX）；软件供应链安全检查项 | 产出：供应链应急处置检查清单（软件来源验证/签名校验/异常更新响应步骤） |
| Day 48 | 学习：弱口令与资产暴露处置；制造业 IT 资产扫描与暴露面收敛 | 实操：用 PowerShell 枚举本地管理员账户；编写弱口令检测脚本框架 |
| Day 49 | 学习：分级处置与业务影响决策树（是否停线/隔离设备/通知管理层）| 产出：**安全事件分级处置决策树**（含制造业停线决策节点） |
| Day 50 | 综合：把 W9–W10 所有产出整合为"制造业安全运营手册" | 产出：**制造业安全运营手册（草稿）**（封面/目录/OT 场景/应急剧本/联系人矩阵） |

**W10 输出检查清单**

- [ ] 制造业勒索应急剧本 v1（含决策树）
- [ ] 供应链应急处置检查清单
- [ ] 安全事件分级处置决策树
- [ ] 制造业安全运营手册草稿

---

## 第 11–12 周：自动化工程化与综合演练

### 学习目标

- 用 Python/PowerShell 实现 3–5 个可落地的安全运营小工具
- 完成一次完整的 Tabletop 演练（红蓝对抗模拟）
- 输出个人能力画像和下一步学习规划

### W11 每日安排

| 天 | 上午 | 下午 |
|---|---|---|
| Day 51 | 学习：Python 安全工具开发基础（requests/subprocess/json/logging）| 实操：完成工具 1 – IP 信誉批量查询（见[自动化小工具](#自动化小工具任务书)） |
| Day 52 | 学习：PowerShell 安全脚本最佳实践（参数验证/错误处理/日志输出）| 实操：完成工具 2 – Windows 事件日志批量分析 |
| Day 53 | 学习：API 集成（VirusTotal/Shodan/AbuseIPDB）；速率限制处理 | 实操：完成工具 3 – 告警自动 enrichment 脚本 |
| Day 54 | 学习：PowerShell Remoting 与批量端点检查 | 实操：完成工具 4 – 批量账户异常检测（可选工具 5） |
| Day 55 | 综合：代码审查；写工具使用文档；部署到测试环境验证 | 产出：3–5 个可运行工具 + README + 使用示例截图 |

### W12 每日安排

| 天 | 上午 | 下午 |
|---|---|---|
| Day 56 | 准备 Tabletop 演练场景（选题：制造业勒索软件渗透）；定角色（分析师/管理层/IT）| 执行：Tabletop 演练（2 h）；记录决策节点与耗时 |
| Day 57 | 分析演练结果；识别 SOP 漏洞 | 产出：**Tabletop 演练报告**（场景描述/决策记录/发现缺口/改进项） |
| Day 58 | 复盘 12 周所有产出物；更新每个产出至最终版 | 整理：建立个人产出物归档（Git Repo 或共享盘） |
| Day 59 | 自评：对照 SOC 能力清单打分（见下节）；识别短板 | 产出：**个人能力画像**（雷达图，覆盖 8 个能力维度） |
| Day 60 | 制定下一阶段计划（DFIR / Threat Hunting / Cloud SOC）| 产出：**下一阶段 12 周学习计划草稿** + 证书考取计划（如 GCIH/BTL1/SC-200） |

**W11–W12 输出检查清单**

- [ ] 3–5 个可运行安全工具（含 README）
- [ ] Tabletop 演练报告
- [ ] 个人能力画像（雷达图）
- [ ] 所有产出物归档
- [ ] 下一阶段学习计划

---

## SOC 日常能力清单（常驻参考）

### 告警研判标准操作流程（SOP 模板）

```markdown
## 告警研判 SOP – [告警类型]

**版本**：vX.X  **更新日期**：YYYY-MM-DD  **负责人**：XXX

### 1. 触发条件
- 告警名称：
- 告警来源：（SIEM/EDR/防火墙/邮件网关）
- 严重等级：P1/P2/P3/P4

### 2. 初步判断（5 分钟内）
- [ ] 查询告警上下文（前后 15 分钟日志）
- [ ] 确认涉及资产（IP/主机名/用户名）
- [ ] 检查资产台账（业务功能/重要性/所有者）
- [ ] 比对 IOC（TI 平台/Watchlist）

### 3. 深度调查（P1: 30 min / P2: 2 h / P3: 8 h）
- [ ] 追踪进程树（EDR 调查视图）
- [ ] 检查账户活动（同时段登录/权限变更）
- [ ] 分析网络连接（出站/横向/异常端口）
- [ ] 搜索同源 IOC（同 IP/同 Hash 的其他事件）

### 4. 研判结论
- [ ] 真实威胁（True Positive）→ 执行处置 SOP
- [ ] 误报（False Positive）→ 记录原因，申请规则调优
- [ ] 待确认（Undetermined）→ 升级至 L2/L3

### 5. 处置步骤
（具体见各威胁类型处置 SOP）

### 6. 关闭与记录
- [ ] 填写事件记录（时间/涉及资产/调查发现/处置措施）
- [ ] 更新 SIEM 事件状态
- [ ] 如需复盘，创建复盘任务
```

### 告警分级标准

| 等级 | 定义 | 响应时限 | 升级条件 |
|------|------|---------|---------|
| **P1** 紧急 | 已确认入侵/生产中断/勒索/DC 沦陷 | 15 分钟内 | 立即通知 CISO + 业务负责人 |
| **P2** 高 | 可疑横向移动/凭据泄露/OT 边界突破 | 1 小时内 | 30 min 未遏制升 P1 |
| **P3** 中 | 暴力破解/异常外联/可疑脚本执行 | 4 小时内 | 确认 TP 或发现横向迹象升 P2 |
| **P4** 低 | 扫描/弱口令尝试/信息搜集 | 24 小时内 | 与其他告警关联升 P3 |

### 升级条件矩阵

| 触发情景 | 升级至 | 通知对象 |
|---------|-------|---------|
| OT 设备受到影响 | P1 | 安全总监 + 生产总监 + IT 总监 |
| 域控/核心服务器可能被控 | P1 | 安全总监 + CIO |
| 检测到横向移动 | ≥ P2 | 安全经理 + IT 经理 |
| 数据外传迹象 | ≥ P2 | 安全经理 + 法务（如涉及个人数据） |
| 生产线停机 | P1 | 安全总监 + 生产总监 + CEO |
| 30 min 内未遏制的 P2 | P1 | 安全总监 |

### 证据保全流程

```
1. 立即截图（告警详情/日志原文/时间戳）
2. 导出日志文件（.evtx / .csv / .json）并记录 MD5/SHA256
3. 保存内存镜像（如需：WinPmem / Magnet RAM Capture）
4. 隔离前备份端点快照（VMware 快照 / EDR 实时响应）
5. 所有文件写入只读归档（SHA256 清单 + 签收人 + 时间）
6. 保管链记录（Chain of Custody 表）
```

### 复盘模板

```markdown
## 安全事件复盘报告

**事件编号**：INC-YYYYMMDD-XXX  
**事件等级**：P1/P2/P3  
**复盘时间**：  
**参与人员**：  

### 事件时间线
| 时间 | 事件描述 | 操作者 |
|------|---------|-------|
| … | … | … |

### 根因分析（5 Why）
1. 为什么发生？
2. 为什么没有更早发现？
3. 为什么响应耗时 X 分钟？
4. 为什么遏制措施不够快？
5. 根本原因是？

### 已做对的事
-

### 改进项
| 改进措施 | 责任人 | 截止日期 | 状态 |
|---------|-------|---------|------|
| … | … | … | [ ] |

### 指标
- MTTD（平均检测时间）：X 分钟
- MTTR（平均响应时间）：X 分钟
- 误报率影响：是/否
```

---

## KQL 检测用例库（12 条）

> **使用环境**：Microsoft Sentinel / Azure Log Analytics  
> **数据表**：`SecurityEvent`（Windows Security 日志）、`SysmonEvent`（需自定义解析）、`DeviceProcessEvents`（MDE）

---

### Rule 01 – 暴力破解检测（账户锁定前高频失败）

```kql
// 检测：同一源 IP 在 10 分钟内对同一账户失败登录 ≥ 10 次
// 误报场景：服务账户密码过期；误报降噪：排除已知服务账户 UPN
SecurityEvent
| where EventID == 4625
| where TimeGenerated > ago(10m)
| summarize FailCount = count(), LastAttempt = max(TimeGenerated)
    by TargetAccount, IpAddress, bin(TimeGenerated, 10m)
| where FailCount >= 10
| where TargetAccount !in~ ("svc_backup", "svc_monitor")  // 已知服务账户白名单
| project LastAttempt, TargetAccount, IpAddress, FailCount
| sort by FailCount desc
```

---

### Rule 02 – 异常 Logon Type 3（网络登录来自工作站）

```kql
// 检测：工作站（非服务器）向工作站发起网络登录（横向移动信号）
// 误报场景：管理员 psexec 合法运维；降噪：限定非管理员账户
SecurityEvent
| where EventID == 4624 and LogonType == 3
| where TimeGenerated > ago(1h)
| where Computer !has "SRV" and Computer !has "DC"   // 仅工作站
| where TargetUserName !endswith "$"                  // 排除计算机账户
| where TargetUserName !in~ ("administrator")         // 可加入白名单
| project TimeGenerated, Computer, IpAddress, TargetUserName, LogonType
```

---

### Rule 03 – Pass-the-Hash 特征（Logon Type 3 + NTLM + 无密码）

```kql
// 检测：NTLM 认证 + LogonType 3 + SubjectUserName 为"-"（表示无前置交互会话，PtH 场景之一）
// 注意：SubjectUserName=="-" 仅为辅助信号，应与 NTLM 认证包和高价值目标资产结合判断，避免单条件误报
// 误报场景：旧系统 NTLMv1；降噪：限定敏感账户或 Tier-0 资产
SecurityEvent
| where EventID == 4624
| where LogonType == 3
| where AuthenticationPackageName == "NTLM"
| where SubjectUserName == "-"   // 无前置会话（PtH 特征）
| where Computer !has "DC"
| project TimeGenerated, Computer, TargetUserName, IpAddress, AuthenticationPackageName
```

---

### Rule 04 – Kerberoasting（TGS 请求使用 RC4 加密）

```kql
// 检测：大量使用 0x17（RC4）加密的 TGS 请求，且目标为服务账户
// 误报场景：旧应用强制 RC4；降噪：排除已知旧系统 IP
SecurityEvent
| where EventID == 4769
| where TicketEncryptionType == "0x17"   // RC4-HMAC（弱加密，Kerberoasting 特征）
| where TargetUserName !endswith "$"      // 排除计算机账户
| summarize RequestCount = count(), Services = make_set(ServiceName)
    by CallerIpAddress, TargetUserName, bin(TimeGenerated, 1h)
| where RequestCount >= 3
| sort by RequestCount desc
```

---

### Rule 05 – DCSync 检测（目录复制权限调用）

```kql
// 检测：非域控账户调用目录复制（DS-Replication-Get-Changes-All）
// 误报场景：合法 AD 备份工具（如 Veeam）；降噪：加入备份账户白名单
SecurityEvent
| where EventID == 4662
| where Properties has "1131f6aa-9c07-11d1-f79f-00c04fc2dcd2"   // DS-Replication-Get-Changes-All
| where SubjectUserName !endswith "$"   // 非计算机账户
| where SubjectUserName !in~ ("veeam_backup", "azure_ad_connect")  // 白名单
| project TimeGenerated, Computer, SubjectUserName, Properties
```

---

### Rule 06 – 可疑 PowerShell Script Block（编码/下载命令）

```kql
// 检测：Script Block 包含 Base64 编码、下载器、反射加载等特征
// 误报场景：合法自动化脚本；降噪：与已知脚本哈希白名单比对
Event
| where Source == "Microsoft-Windows-PowerShell"
| where EventID == 4104
| where RenderedDescription has_any (
    "FromBase64String", "IEX", "Invoke-Expression",
    "DownloadString", "WebClient", "Reflection.Assembly",
    "EncodedCommand", "-enc", "bypass"
  )
| project TimeGenerated, Computer, RenderedDescription
| extend CommandSnippet = substring(RenderedDescription, 0, 300)
```

---

### Rule 07 – 计划任务创建（非管理员账户）

```kql
// 检测：非特权账户创建计划任务（持久化信号）
// 误报场景：部署脚本自动创建任务；降噪：白名单已知部署账户
SecurityEvent
| where EventID == 4698   // 计划任务创建
| where SubjectUserName !in~ ("system", "administrator", "deploy_svc")
| project TimeGenerated, Computer, SubjectUserName,
    TaskName = extract(@"TaskName.*?<([^>]+)>", 1, EventData)
```

---

### Rule 08 – 新服务安装（可疑路径）

```kql
// 检测：从 TEMP/公共目录安装服务（常见持久化/横向工具特征）
// 误报场景：合规安装程序；降噪：限定可疑路径
Event
| where Source == "Service Control Manager"
| where EventID == 7045
| where RenderedDescription has_any ("\\Temp\\", "\\AppData\\", "\\Public\\", "C:\\Users\\")
| project TimeGenerated, Computer, RenderedDescription
```

---

### Rule 09 – 远程运维工具异常会话（制造业专属）

```kql
// 检测：TeamViewer/AnyDesk 在非工作时间（22:00–06:00）建立连接
// 误报场景：值班运维工程师；降噪：结合值班人员 Watchlist
DeviceProcessEvents
| where FileName in~ ("TeamViewer.exe", "AnyDesk.exe", "rustdesk.exe")
| where ProcessCommandLine != ""
| extend Hour = hourofday(Timestamp)
| where Hour >= 22 or Hour <= 6   // 非工作时间
| project Timestamp, DeviceName, AccountName, FileName, ProcessCommandLine
```

---

### Rule 10 – OT 资产被 IT 域账户直接访问（OT/IT 越界）

```kql
// 检测：IT 域用户账户直接登录到 OT 设备（Purdue L1/L2 资产）
// 依赖：OT 资产 IP/主机名已维护在 Watchlist "OT_Assets"，SearchKey 列存储主机名
let OTAssets = _GetWatchlist("OT_Assets") | project SearchKey;  // SearchKey 列 = 主机名
SecurityEvent
| where EventID == 4624
| where LogonType in (2, 3, 10)   // 交互式/网络/远程交互
| where Computer in (OTAssets)    // 仅 OT 资产
| where TargetDomainName != ""    // 域账户（非本地账户）
| project TimeGenerated, Computer, TargetUserName, TargetDomainName, IpAddress, LogonType
```

---

### Rule 11 – 大量文件重命名（勒索软件早期信号）

```kql
// 检测：单主机 10 分钟内文件修改事件 ≥ 500 条（勒索加密前兆）
// 误报场景：备份软件/杀毒扫描；降噪：排除已知备份进程
DeviceFileEvents
| where ActionType == "FileModified" or ActionType == "FileRenamed"
| where InitiatingProcessFileName !in~ ("backup.exe", "mssense.exe")
| summarize FileCount = count()
    by DeviceName, InitiatingProcessFileName, bin(Timestamp, 10m)
| where FileCount >= 500
| sort by FileCount desc
```

---

### Rule 12 – LSASS 进程访问（凭据窃取）

```kql
// 检测：非系统进程以高权限访问 lsass.exe（Mimikatz/ProcDump 特征）
// 误报场景：AV/EDR 本身；降噪：加入已知安全软件白名单
DeviceEvents
| where ActionType == "OpenProcessApiCall"
| where FileName =~ "lsass.exe"
| where InitiatingProcessFileName !in~ (
    "MsMpEng.exe", "csrss.exe", "wininit.exe",
    "services.exe", "lsass.exe", "svchost.exe"
  )
| project Timestamp, DeviceName, InitiatingProcessFileName,
    InitiatingProcessCommandLine, GrantedAccess
| where GrantedAccess has_any ("0x1010", "0x1410", "0x143a", "0x1fffff")
```

---

## 自动化小工具任务书

### Tool 1：IP 信誉批量查询工具（Python）

**任务目标**：给定一批 IP 地址（CSV 输入），批量查询 AbuseIPDB / VirusTotal，输出富化后的 CSV 报告。

**文件结构**：

```
tools/ip-enrichment/
├── README.md
├── requirements.txt          # requests, pandas, python-dotenv
├── config.env.example        # API Key 模板
├── ip_enrichment.py          # 主脚本
│   ├── load_ips(csv_path)    # 读取输入 CSV
│   ├── query_abuseipdb(ip)   # 查询 AbuseIPDB API
│   ├── query_virustotal(ip)  # 查询 VT API
│   ├── enrich(ip_list)       # 并发批量查询（ThreadPoolExecutor）
│   └── export_report(df)     # 输出富化 CSV
└── sample_ips.csv            # 示例输入文件
```

**输入**：`ips.csv`（列：`ip,source_alert,timestamp`）  
**输出**：`enriched_YYYYMMDD.csv`（增加：`abuse_score`, `vt_detections`, `country`, `isp`, `verdict`）  
**验收标准**：100 条 IP 在 60 秒内完成查询，误报率字段手动验证 ≥ 5 条

---

### Tool 2：Windows 事件日志批量分析脚本（PowerShell）

**任务目标**：从多台 Windows 主机远程拉取指定时间段的安全事件，输出统计报告。

**文件结构**：

```
tools/evtlog-batch-analyzer/
├── README.md
├── Get-SecurityEvents.ps1    # 主脚本
│   ├── Param block           # -ComputerList, -StartTime, -EndTime, -EventIDs, -OutputPath
│   ├── Get-RemoteEvents()    # Invoke-Command 远程拉取
│   ├── ConvertTo-Report()    # 统计汇总（按 EventID/账户/主机分组）
│   └── Export-CSV()          # 输出 CSV + HTML 报告
├── computers.txt             # 目标主机列表
└── sample_report.html        # 示例输出（截图）
```

**输入**：`computers.txt`（主机名列表）+ 时间范围参数  
**输出**：`EventReport_YYYYMMDD.csv` + `EventReport_YYYYMMDD.html`（含图表）  
**验收标准**：20 台主机 5 分钟内完成采集，HTML 报告含 Top 10 账户失败登录排行

---

### Tool 3：告警自动 Enrichment 脚本（Python）

**任务目标**：接收 SIEM Webhook 告警（JSON），自动查询 TI、资产台账、账户信息，生成研判摘要并发送到钉钉/Teams/Slack。

**文件结构**：

```
tools/alert-enrichment/
├── README.md
├── requirements.txt          # flask, requests, jinja2
├── enrichment_server.py      # Flask Webhook 接收端
│   ├── /webhook POST         # 接收 SIEM 告警
│   ├── enrich_alert(alert)   # 主富化逻辑
│   │   ├── lookup_asset(ip)  # 查资产台账（本地 CSV / CMDB API）
│   │   ├── lookup_user(user) # 查 AD 用户信息
│   │   └── lookup_ti(ioc)    # 查 TI 平台
│   └── send_notification()   # 发送富化摘要到即时通讯
├── templates/
│   └── alert_summary.j2      # Jinja2 通知模板
└── asset_db.csv              # 本地资产台账示例
```

**输入**：SIEM Webhook JSON  
**输出**：钉钉/Teams 卡片消息（含：资产业务功能/TI 命中/账户部门/建议优先级）  
**验收标准**：从告警触发到通知发出 ≤ 30 秒，字段覆盖率 ≥ 70%

---

### Tool 4：批量账户异常检测（PowerShell）

**任务目标**：定时扫描 AD，检测可疑账户状态（新增管理员/密码未过期/长时间未登录/禁用后仍有会话）。

**文件结构**：

```
tools/ad-account-auditor/
├── README.md
├── Invoke-ADAccountAudit.ps1
│   ├── Get-NewAdmins()           # 过去 7 天新加入管理员组的账户
│   ├── Get-NeverExpireAccounts() # 密码永不过期账户
│   ├── Get-StaleAccounts()       # 90 天未登录账户
│   └── Export-AuditReport()      # 输出 HTML 报告 + 邮件发送
└── schedule_task_setup.ps1       # 注册每日定时任务
```

**输入**：无（从 AD 直接查询）  
**输出**：`AD_Audit_YYYYMMDD.html`（含异常账户列表 + 建议处置）  
**验收标准**：在 10 分钟内扫描完毕（≤ 5000 账户域），报告邮件自动发送

---

### Tool 5：制造业资产暴露面扫描框架（Python）

**任务目标**：定期扫描 OT 网段，识别异常开放端口和默认凭据，输出暴露面风险报告。

**文件结构**：

```
tools/ot-exposure-scanner/
├── README.md
├── requirements.txt          # python-nmap, paramiko, shodan
├── ot_scanner.py
│   ├── port_scan(subnet)     # nmap 扫描 OT 常见端口（102/502/4840/20000）
│   ├── check_default_creds() # 检测 Telnet/SSH/Web 默认凭据（仅授权环境）
│   ├── shodan_lookup(ip)     # Shodan API 查询（互联网暴露检查）
│   └── generate_report()     # 输出风险报告 + CVSS 简评
├── ot_ports.yaml             # OT 协议端口配置
└── default_creds.yaml        # 默认凭据字典（仅限授权测试）
```

**输入**：`config.yaml`（扫描目标网段、授权范围声明）  
**输出**：`OT_Exposure_Report_YYYYMMDD.pdf/HTML`  
**验收标准**：识别出 ≥ 3 个高风险端口或默认凭据资产（测试环境）

---

## 参考资料（与周次绑定）

### W1–W2：SOC 基础

| 优先级 | 资源 | 类型 | 备注 |
|--------|------|------|------|
| ⭐⭐⭐ | NIST SP 800-61r2 | 官方文档 | 事件响应生命周期圣经 |
| ⭐⭐⭐ | MITRE ATT&CK 官网 (attack.mitre.org) | 在线平台 | 重点学习 Windows 技术域 |
| ⭐⭐ | 《Blue Team Handbook》 Don Murdoch | 书籍 | SOC 日常参考手册 |
| ⭐⭐ | SANS SEC450 课程大纲（公开版）| 课程 | SOC 能力框架参考 |

### W3–W4：Windows 日志与 Sysmon

| 优先级 | 资源 | 类型 | 备注 |
|--------|------|------|------|
| ⭐⭐⭐ | Microsoft 安全审计事件官方文档 | 官方文档 | 每个事件 ID 的权威说明 |
| ⭐⭐⭐ | SwiftOnSecurity/sysmon-config (GitHub) | 开源配置 | 最流行的 Sysmon 配置模板 |
| ⭐⭐⭐ | olafhartong/sysmon-modular (GitHub) | 开源配置 | 模块化 Sysmon 配置 |
| ⭐⭐ | 《The Practice of Network Security Monitoring》| 书籍 | 日志分析方法论 |
| ⭐⭐ | Sigma Rules (github.com/SigmaHQ/sigma) | 开源规则库 | 可转换为 KQL/SPL 的通用规则 |

### W5–W6：KQL 与 SIEM

| 优先级 | 资源 | 类型 | 备注 |
|--------|------|------|------|
| ⭐⭐⭐ | Microsoft KQL 官方文档 (learn.microsoft.com/en-us/azure/data-explorer/kusto/query/) | 官方文档 | KQL 语法权威参考 |
| ⭐⭐⭐ | Microsoft Sentinel GitHub (github.com/Azure/Azure-Sentinel) | 开源规则库 | 数百条现成 KQL 检测规则 |
| ⭐⭐ | 《Microsoft Sentinel in Action》 Gary Buehler | 书籍 | Sentinel 实战指南 |
| ⭐⭐ | SC-200 微软认证备考 | 认证 | Microsoft Security Operations Analyst |

### W7–W8：AD 攻击链与 EDR

| 优先级 | 资源 | 类型 | 备注 |
|--------|------|------|------|
| ⭐⭐⭐ | 《The Hacker Playbook 3》Peter Kim – AD 章节 | 书籍 | 红队视角理解 AD 攻击 |
| ⭐⭐⭐ | Specterops/BloodHound 文档 | 工具文档 | 理解 AD 攻击路径 |
| ⭐⭐⭐ | MaLDAPtive / LDAPmonitor | 工具 | AD 查询监控 |
| ⭐⭐ | Microsoft Defender for Endpoint 官方文档 | 官方文档 | EDR 功能参考 |
| ⭐⭐ | SANS FOR508：Advanced Incident Response | 课程 | 内存取证 + AD 攻击链 |

### W9–W10：制造业 OT 安全

| 优先级 | 资源 | 类型 | 备注 |
|--------|------|------|------|
| ⭐⭐⭐ | IEC 62443 系列标准（工控系统安全）| 标准 | OT 安全基础标准 |
| ⭐⭐⭐ | CISA ICS-CERT 公告 (cisa.gov/ics) | 官方公告 | 最新工控安全威胁 |
| ⭐⭐⭐ | Dragos Year in Review（最新版）| 行业报告 | 制造业 OT 威胁态势 |
| ⭐⭐ | TRITON/TRISIS 事件分析报告（Dragos/FireEye）| 事件分析 | ICS 攻击最典型案例 |
| ⭐⭐ | MITRE ATT&CK for ICS (attack.mitre.org/matrices/ics/) | 平台 | OT 攻击技术框架 |
| ⭐ | NIST SP 800-82r3（工业控制系统安全指南）| 官方文档 | OT 安全框架 |

### W11–W12：自动化与综合演练

| 优先级 | 资源 | 类型 | 备注 |
|--------|------|------|------|
| ⭐⭐⭐ | CISA Tabletop Exercise Packages (CTEPs) | 官方演练包 | 免费下载，含制造业场景 |
| ⭐⭐ | 《Automating Security with Python》 | 书籍 | 安全自动化实战 |
| ⭐⭐ | PowerShell Gallery – SecurityFever | 开源模块 | 安全相关 PS 模块 |
| ⭐ | Atomic Red Team (github.com/redcanaryco/atomic-red-team) | 开源工具 | 模拟攻击场景，验证检测规则 |

---

## 验收标准总表

| 周次 | 产出物 | 验收标准 | 自评 |
|------|-------|---------|------|
| W1 | 告警分级标准 v1 | 包含 P1–P4 定义 + 响应时限 + 制造业举例 + 升级矩阵 | [ ] |
| W2 | 告警研判 SOP × 3 | 每份 SOP 包含 5W1H + 调查步骤 + 处置选项 + 关闭条件 | [ ] |
| W2 | 复盘模板 v1 | 包含时间线/根因（5 Why）/改进项/MTTD-MTTR 指标 | [ ] |
| W3 | 日志采集清单 | 覆盖 Security/PowerShell/TaskScheduler/WMI 4 个通道 | [ ] |
| W3 | 事件 ID 速查卡 | ≥ 10 个事件 ID，含安全意义说明 | [ ] |
| W4 | Sysmon 配置文件 | 包含 ≥ 5 条自定义规则，含注释 | [ ] |
| W5–W6 | KQL 检测规则 | ≥ 10 条，每条含规则逻辑/误报场景/降噪方案 | [ ] |
| W6 | SIEM 仪表板 | ≥ 3 个面板（趋势/Top 攻击源/账户异常），截图存档 | [ ] |
| W7 | AD 攻击链思维导图 | 覆盖凭据窃取/横向/持久化三阶段，标注事件 ID | [ ] |
| W7 | PtH 研判手册 | 包含检测查询/研判逻辑/处置步骤/时间要求 | [ ] |
| W8 | EDR Runbook × 3 | 端点隔离/误报处理/研判报告，各含操作步骤 | [ ] |
| W9 | OT 资产台账模板 | ≥ 10 个字段，含业务功能和变更窗口 | [ ] |
| W9 | OT/IT 边界防控清单 | ≥ 10 条具体防控措施 | [ ] |
| W10 | 制造业勒索应急剧本 | 含决策树，覆盖停线/不停线两个分支 | [ ] |
| W11 | 自动化工具 × 3 | 每个工具可在测试环境运行，含 README | [ ] |
| W12 | Tabletop 演练报告 | 包含场景/决策记录/缺口发现/改进项 | [ ] |
| W12 | 个人能力画像 | 雷达图 + 8 维度自评（1–5 分） | [ ] |

### 个人能力画像 8 维度

```
1. 告警研判（SIEM/EDR 告警识别与处置）
2. 日志分析（Windows 日志/Sysmon 深度解析）
3. 检测工程（KQL/SPL 规则编写与调优）
4. AD 安全（攻击链识别与防御）
5. OT/制造业安全（OT 协议/Purdue 模型/OT 威胁）
6. 事件响应（调查流程/证据保全/应急剧本）
7. 自动化（Python/PowerShell 工具开发）
8. 沟通报告（向管理层汇报/撰写事件报告）
```

---

*文档维护：请在每次演练或规则更新后同步更新对应章节。建议每季度复审一次，结合最新威胁情报更新制造业场景。*
