import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hiveの初期化
  await Hive.initFlutter();

  runApp(
    // Riverpodプロバイダーでアプリをラップ
    const ProviderScope(
      child: GrailiceApp(),
    ),
  );
}

class GrailiceApp extends ConsumerWidget {
  const GrailiceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ルーターの取得
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'GRAILICE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
