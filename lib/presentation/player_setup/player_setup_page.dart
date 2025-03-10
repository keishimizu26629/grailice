import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/game/game_controller.dart';

/// プレイヤー設定画面
class PlayerSetupPage extends ConsumerStatefulWidget {
  const PlayerSetupPage({super.key});

  @override
  ConsumerState<PlayerSetupPage> createState() => _PlayerSetupPageState();
}

class _PlayerSetupPageState extends ConsumerState<PlayerSetupPage> {
  final List<TextEditingController> _controllers = [
    TextEditingController(text: 'プレイヤー1'),
    TextEditingController(text: 'プレイヤー2'),
  ];

  int _playerCount = 2;
  bool _isLoading = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// ゲームを開始
  Future<void> _startGame() async {
    // 入力チェック
    final playerNames = _controllers
        .sublist(0, _playerCount)
        .map((controller) => controller.text.trim())
        .toList();

    // 名前が空のプレイヤーがいる場合
    if (playerNames.any((name) => name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('すべてのプレイヤー名を入力してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ゲームコントローラーを取得
      final gameController = ref.read(gameControllerProvider);

      // 新しいゲームを開始
      await gameController.startNewGame(playerNames);

      // ゲーム画面に遷移
      if (mounted) {
        context.goNamed('game');
      }
    } catch (e) {
      // エラーが発生した場合
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイヤー設定'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'プレイヤー人数',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _playerCount > 2
                      ? () => setState(() => _playerCount--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$_playerCount人',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  onPressed: _playerCount < 4
                      ? () {
                          setState(() {
                            _playerCount++;
                            if (_controllers.length < _playerCount) {
                              _controllers.add(TextEditingController(
                                text: 'プレイヤー${_playerCount}',
                              ));
                            }
                          });
                        }
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'プレイヤー名',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _playerCount,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _controllers[index],
                      decoration: InputDecoration(
                        labelText: 'プレイヤー ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('ゲームを開始'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
