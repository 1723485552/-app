import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// 进程内唯一的 [AppDatabase] 实例。
///
/// SQLite 单文件不允许被同一进程重复打开多个写连接，因此这里以懒加载单例持有；
/// 首次访问时才真正打开 `card_collector.sqlite`（[LazyDatabase] 内部再延迟一层），
/// 保证 App 启动路径零额外 IO 开销。
AppDatabase? _instance;

/// 全局数据库访问入口（仅原生平台使用；Web 走内存数据源）。
AppDatabase get appDatabase => _instance ??= AppDatabase();

/// Riverpod 注入口，便于测试期以内存库替换实现。
final Provider<AppDatabase> appDatabaseProvider =
    Provider<AppDatabase>((ref) => appDatabase);
