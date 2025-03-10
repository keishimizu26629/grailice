import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/game/game_controller.dart';
import '../../application/game/game_notifier.dart';
import '../../domain/entity/card.dart';
import '../../domain/entity/game_session.dart';

/// ゲーム画面
class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ゲーム状態を監視
    final gameSessionAsync = ref.watch(gameNotifierProvider);

    // ゲームメッセージを監視
    final gameMessage = ref.watch(gameMessageProvider);

    // ゲームコントローラーを取得
    final gameController = ref.read(gameControllerProvider);

    // ゲーム状態がない場合はローディング表示
    if (gameSessionAsync == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ゲーム状態を取得
    final gameSession = gameSessionAsync;
    final currentPlayerIndex = gameSession.currentPlayerIndex;
    final players = gameSession.players;
    final cards = gameSession.cards;
    final dicePair = gameSession.dicePair;

    // 現在のプレイヤーを取得
    final currentPlayer = players[currentPlayerIndex];

    // ゲームが終了しているかどうか
    final isGameFinished = gameSession.status == GameStatus.finished;

    // 現在のターンでサイコロを振ったかどうか
    final hasRolledDice = gameSession.hasRolledDice;

    // ゲーム終了時にダイアログを表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isGameFinished &&
          gameMessage != null &&
          gameMessage.contains("ゲーム終了！")) {
        _showGameResultDialog(context, ref, gameMessage);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentPlayer.name}のターン'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              _showGameMenu(context, ref);
            },
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: Column(
        children: [
          // ゲームメッセージ表示エリア
          if (gameMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              color: Colors.amber.shade100,
              child: isGameFinished
                  ? SingleChildScrollView(
                      child: Text(
                        gameMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Text(
                      gameMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),

          // プレイヤー情報表示エリア
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: players.map((player) {
                return _buildPlayerInfo(
                  player.name,
                  player.isCurrentTurn,
                  player.cards.length,
                  player.outCount,
                );
              }).toList(),
            ),
          ),

          // メインゲームエリア
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // サイコロ表示エリア
                  Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey.shade300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'サイコロ表示エリア',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _DiceView(value: dicePair?.dice1.value ?? 1),
                              const SizedBox(width: 16),
                              _DiceView(value: dicePair?.dice2.value ?? 1),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '合計: ${dicePair?.total ?? 2}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // サイコロを振るボタン
                  ElevatedButton(
                    onPressed: (isGameFinished || hasRolledDice)
                        ? null // ゲーム終了またはサイコロを振った後は無効化
                        : () async {
                            await gameController.rollDice();
                          },
                    child: const Text('サイコロを振る'),
                  ),

                  const SizedBox(height: 16),

                  // 次のプレイヤーに交代するボタン
                  ElevatedButton(
                    onPressed: isGameFinished
                        ? null
                        : () async {
                            await gameController.nextPlayer();
                          },
                    child: const Text('次のプレイヤー'),
                  ),
                ],
              ),
            ),
          ),

          // カード表示エリア
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            color: Colors.grey.shade200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return GestureDetector(
                  onTap: () {
                    _showCardInfoDialog(context, players, card);
                  },
                  child: _buildCard(
                    card.number,
                    card.status,
                    card.ownerId != null
                        ? players.firstWhere((p) => p.id == card.ownerId).name
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// プレイヤー情報ウィジェットを構築
  Widget _buildPlayerInfo(
      String name, bool isCurrentTurn, int cardCount, int outCount) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isCurrentTurn ? Colors.blue.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isCurrentTurn ? Colors.blue : Colors.grey,
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text('罰カード: $cardCount枚'),
          Text('アウト: $outCount回'),
        ],
      ),
    );
  }

  /// カードウィジェットを構築
  Widget _buildCard(int number, CardStatus status, String? ownerName) {
    Color cardColor;
    switch (status) {
      case CardStatus.onTable:
        cardColor = Colors.white;
        break;
      case CardStatus.withPlayer:
        cardColor = Colors.red.shade100;
        break;
      case CardStatus.inDeck:
        cardColor = Colors.grey.shade300;
        break;
    }

    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$number',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (ownerName != null)
            Text(
              ownerName,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  /// カード情報ダイアログを表示
  void _showCardInfoDialog(
      BuildContext context, List<dynamic> players, GameCard card) {
    String message;

    switch (card.status) {
      case CardStatus.onTable:
        message = "このカードは場にあります";
        break;
      case CardStatus.withPlayer:
        final ownerName = players.firstWhere((p) => p.id == card.ownerId).name;
        message = "このカードは${ownerName}が持っています";
        break;
      case CardStatus.inDeck:
        message = "このカードは山札にあります";
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('カード ${card.number}'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// ゲームメニューを表示
  void _showGameMenu(BuildContext context, WidgetRef ref) {
    final gameController = ref.read(gameControllerProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ゲームメニュー'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('ゲームを保存'),
              onTap: () async {
                Navigator.of(context).pop();
                // ゲームは自動保存されるので、成功メッセージだけ表示
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ゲームを保存しました')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('新しいゲームを開始'),
              onTap: () {
                Navigator.of(context).pop();
                _showNewGameConfirmDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('ホームに戻る'),
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed('home');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 新しいゲーム確認ダイアログを表示
  void _showNewGameConfirmDialog(BuildContext context, WidgetRef ref) {
    final gameController = ref.read(gameControllerProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいゲームを開始'),
        content: const Text('現在のゲームを終了して、新しいゲームを開始しますか？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await gameController.resetGame();
              if (context.mounted) {
                Navigator.of(context).pop();
                context.goNamed('player-setup');
              }
            },
            child: const Text('新しいゲームを開始'),
          ),
        ],
      ),
    );
  }

  /// ゲーム結果ダイアログを表示
  void _showGameResultDialog(
      BuildContext context, WidgetRef ref, String resultMessage) {
    final gameController = ref.read(gameControllerProvider);

    // 既に表示されているダイアログがあれば表示しない
    if (ModalRoute.of(context)?.isCurrent != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('ゲーム終了'),
        content: SingleChildScrollView(
          child: Text(resultMessage),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await gameController.resetGame();
              if (context.mounted) {
                context.goNamed('player-setup');
              }
            },
            child: const Text('新しいゲームを開始'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('結果を確認'),
          ),
        ],
      ),
    );
  }
}

/// サイコロ表示ウィジェット
class _DiceView extends StatelessWidget {
  final int value;

  const _DiceView({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Center(
        child: Text(
          '$value',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
