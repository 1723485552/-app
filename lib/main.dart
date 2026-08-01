import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/backup/services/auto_backup_service.dart';
import 'features/card_management/data/datasources/card_local_datasource.dart';
import 'features/card_management/domain/repositories/card_repository.dart';
import 'core/theme/theme_provider.dart';
import 'features/card_management/presentation/pages/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // 原生平台打开 Isar；Web 端仅初始化内存存储（详见 datasource）。
    // 首次进入保持本地库为空，不注入任何 Mock 数据（发布初始化要求）。
    await initCardDatabase();
  } catch (e, stack) {
    // 初始化兜底：数据库 schema 冲突等致命错误时不再直接黑屏崩溃，
    // 而是展示可读的错误页，提示用户卸载重装以重建本地库。
    debugPrint('初始化失败: $e\n$stack');
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '初始化失败，请卸载后重装：\n$e',
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
    return;
  }
  runApp(const ProviderScope(child: CardManagementApp()));
}

/// 应用根组件：接通全局三态主题（跟随系统 / 暗黑黑金 / 明亮香槟金）。
///
/// - [themeProvider] 驱动 [MaterialApp.themeMode]，主题切换由 Flutter 自动重建
///   主题子树（含 [GoldThemeExtension]），子 Widget 经 `context.gold` 响应式取色，
///   实现原生级零毁树无缝换肤；
/// - 接入 [WidgetsBindingObserver]，在「跟随系统」模式下监听系统昼夜切换。
class CardManagementApp extends ConsumerStatefulWidget {
  const CardManagementApp({super.key});

  @override
  ConsumerState<CardManagementApp> createState() => _CardManagementAppState();
}

class _CardManagementAppState extends ConsumerState<CardManagementApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 静默本地自动备份：启动后择机执行（24h 节流在内部处理，失败不影响主流程）。
    unawaited(AutoBackupService.backupIfDue(ref.read(cardRepositoryProvider)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // 跟随系统模式下，系统昼夜切换需让 MaterialApp 重建以应用新亮度主题。
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ThemeMode themeMode = ref.watch(themeProvider);
    return MaterialApp(
      title: '卡牌资产',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const MainScreen(),
    );
  }
}
