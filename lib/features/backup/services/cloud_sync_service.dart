import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../card_management/data/models/card_item.dart';
import '../../card_management/domain/repositories/card_repository.dart';

/// 云端同步抽象（领域层），预留对接 Supabase 2.0 实时行情 / 云存档。
abstract class CloudSyncService {
  /// 将本地全量卡牌同步到云端，返回云端写入记录数。
  Future<int> syncToCloud(List<CardItem> cards);

  /// 从云端恢复全量卡牌到本地（整体覆盖），返回恢复数量。
  Future<int> restoreFromCloud(CardRepository repo);
}

/// 占位实现：Supabase 2.0 接入前不抛异常，仅返回 0，保证上游不崩溃。
class StubCloudSyncService implements CloudSyncService {
  const StubCloudSyncService();

  @override
  Future<int> syncToCloud(List<CardItem> cards) async {
    // TODO(phase5): 接入 Supabase 2.0 后实现真实上传（buildCardsBackupJson 序列化）。
    return 0;
  }

  @override
  Future<int> restoreFromCloud(CardRepository repo) async {
    // TODO(phase5): 接入 Supabase 2.0 后实现真实下载 + repo.replaceAllCards。
    return 0;
  }
}

/// 云端同步服务单例 Provider（预留 DI 入口，未来可替换为真实实现）。
final Provider<CloudSyncService> cloudSyncServiceProvider =
    Provider<CloudSyncService>((ref) => const StubCloudSyncService());
