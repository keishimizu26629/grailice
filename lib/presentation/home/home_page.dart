import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/game/game_controller.dart';

/// ホーム画面の状態を管理するプロバイダー
final homePageControllerProvider = FutureProvider<bool>((ref) async {
  final gameController = ref.watch(gameControllerProvider);
  return await gameController.hasSavedGame();
});

/// ホーム画面
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 保存されたゲームがあるかどうかを取得
    final hasSavedGameAsync = ref.watch(homePageControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GRAILICE'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GRAILICE',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'サイコロとカードを使った飲み会ゲーム',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                context.goNamed('player-setup');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('新しいゲームを始める'),
            ),
            const SizedBox(height: 16),

            // 保存されたゲームがある場合は「続きからプレイ」ボタンを表示
            hasSavedGameAsync.when(
              data: (hasSavedGame) => hasSavedGame
                  ? ElevatedButton(
                      onPressed: () => _continueGame(context, ref),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('続きからプレイ'),
                    )
                  : const SizedBox.shrink(),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: ルール説明画面に遷移
              },
              child: const Text('ルールを見る'),
            ),
          ],
        ),
      ),
    );
  }

  /// 保存されたゲームを読み込んで続きからプレイ
  Future<void> _continueGame(BuildContext context, WidgetRef ref) async {
    final gameController = ref.read(gameControllerProvider);

    // ローディング表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 保存されたゲームを読み込み
      final success = await gameController.loadSavedGame();

      // ダイアログを閉じる
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // ゲーム画面に遷移
      if (success && context.mounted) {
        context.goNamed('game');
      } else if (context.mounted) {
        // 読み込みに失敗した場合
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ゲームの読み込みに失敗しました')),
        );
      }
    } catch (e) {
      // エラーが発生した場合
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }
}
