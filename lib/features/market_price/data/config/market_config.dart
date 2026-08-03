/// 行情模块运行配置。
///
/// 与图鉴模块一致的「示例数据」策略：默认下发明确标注的样本，经真实适配器
/// 接口 / Provider 管线下发；UI 展示「示例数据」角标，绝不伪装为真实成交。
///
/// 接入真实数据源（集换社 API / 闲鱼抓取 / eBay Completed / 130point / TCGplayer）
/// 时置 false 并配置对应 Key / 抓取服务，[IPriceAdapter] 中已预留端点说明。
const bool useSampleData = true;

/// 静态演示汇率：1 USD = 7.2 CNY（与 [CurrencyFormatter] 应用默认档位一致）。
const double demoUsdToCny = 7.2;
