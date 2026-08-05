import 'package:flutter/material.dart';
import 'package:card_management/core/theme/gold_theme_extension.dart';

import '../../../../core/theme/app_colors.dart';

/// 隐私与数据共建声明弹窗（应用商店合规透出）。
///
/// ## 为什么必须有这个页面
///
/// App 具备「公共图鉴共建」能力：用户保存卡牌后，后台会异步把该卡的**公开元数据**
/// 上报到共享图鉴库。这属于 App Store《App 隐私》与 Google Play《数据安全表单》
/// 强制要求披露的「数据收集与共享」行为。若仅在后台静默执行而不在应用内明示，
/// 极易在审核环节被判定为「未披露的数据收集」而拒审。
///
/// ## 披露原则
///
/// 逐条对齐两大商店的表单口径，讲清四件事：
/// 1. **收集什么** —— 仅卡牌客观描述信息，逐项列举，不含个人信息；
/// 2. **不收集什么** —— 明确划出价格 / 持仓 / 账本等敏感资产数据的红线；
/// 3. **为什么与怎么做** —— 用途、异步静默的执行方式、补充而非覆盖的写入策略；
/// 4. **用户的控制权** —— 设备标识可重置、未配置凭证即纯本地零上传。
///
/// 文案与实际实现严格一致（见 `MasterCatalogSyncService` 的上报字段白名单与
/// `runSilently` 的静默护栏），避免「声明与行为不符」这一更严重的合规风险。
class ProfilePrivacyDialog extends StatelessWidget {
  const ProfilePrivacyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.gold.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.goldBorder, width: 0.5),
      ),
      title: Row(
        children: <Widget>[
          const Icon(Icons.privacy_tip_outlined,
              color: AppColors.goldPrimary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '隐私与数据共建说明',
              style: TextStyle(
                color: context.gold.textWhite,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: const SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _PrivacySection(
                icon: Icons.phone_android_outlined,
                title: '本地优先，离线可用',
                body: '你的收藏数据默认只保存在本机。所有卡牌记录首先写入设备本地数据库，'
                    'App 在完全离线的状态下功能完整，不依赖任何云端服务。',
              ),
              _PrivacySection(
                icon: Icons.cloud_upload_outlined,
                title: '会异步共建的内容',
                body: '为共建公共卡牌图鉴，保存卡牌后 App 会在后台异步上传该卡的公开元数据：'
                    '所属分类、系列名称、卡号、卡牌名称、评级机构与分数，以及你主动添加的卡面图片。'
                    '这些均为卡牌本身的客观描述信息，不包含任何个人身份信息。',
              ),
              _PrivacySection(
                icon: Icons.lock_outline,
                title: '永不离开本机的内容',
                body: '以下数据仅存本地，绝不上传至公共图鉴：购入价格与购入日期、持有数量、'
                    '心愿单与目标价、账本与收益统计、个人备注。'
                    'App 不收集通讯录、位置、相册全量索引，也不使用广告标识符。',
              ),
              _PrivacySection(
                icon: Icons.fingerprint_outlined,
                title: '设备标识',
                body: '为避免多设备间数据互相覆盖，App 在首次启动时生成一个随机设备编号（UUID）。'
                    '它不关联你的真实身份、手机号或任何账号，不用于广告追踪，'
                    '卸载重装即可重置。',
              ),
              _PrivacySection(
                icon: Icons.sync_outlined,
                title: '执行方式',
                body: '共建上传全程在后台异步执行：不阻塞界面、不弹窗打扰、'
                    '失败时自动静默降级且保留本地数据。'
                    '公共图鉴采用「补充而非覆盖」策略，仅填补缺失字段，'
                    '不会修改已由官方验证的条目。',
              ),
              _PrivacySection(
                icon: Icons.tune_outlined,
                title: '你的选择',
                body: '未配置云端服务凭证时，App 以纯本地模式运行，不产生任何网络上传。',
                isLast: true,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            '我已知悉',
            style: TextStyle(color: AppColors.goldPrimary, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

/// 声明正文的单个条目：金色图标 + 小标题 + 正文段落。
///
/// 抽成独立组件而非在主体里重复 [Column]，是为了让六段声明的排版完全一致，
/// 后续增删条目时不必手工对齐间距。
class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.icon,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String body;

  /// 末条不再追加底部间距，避免弹窗底部出现多余留白。
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: AppColors.goldPrimary, size: 15),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.gold.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color: context.gold.textMuted,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
