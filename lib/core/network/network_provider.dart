import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_service.dart';

/// 全局网络服务 Provider，业务层可直接 `ref.read(networkServiceProvider)` 调用。
final Provider<NetworkService> networkServiceProvider =
    Provider<NetworkService>((ref) => NetworkService());
