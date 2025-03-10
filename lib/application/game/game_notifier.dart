import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entity/game_session.dart';
import '../../domain/entity/player.dart';
import '../../domain/entity/card.dart';
import '../../domain/entity/dice.dart';

/// ゲーム状態を管理するプロバイダー
final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, GameSession?>((ref) {
  return GameNotifier();
});

/// ゲームメッセージを管理するプロバイダー
final gameMessageProvider = StateProvider<String?>((ref) => null);

/// ゲーム状態を管理するNotifier
class GameNotifier extends StateNotifier<GameSession?> {
  GameNotifier() : super(null);

  final _random = Random();
  final _uuid = const Uuid();

  /// 新しいゲームを開始
  void startNewGame(List<String> playerNames) {
    // プレイヤーの作成
    final players = playerNames
        .map((name) => Player(
              id: _uuid.v4(),
              name: name,
            ))
        .toList();

    // 最初のプレイヤーをランダムに選択
    final firstPlayerIndex = _random.nextInt(players.length);
    players[firstPlayerIndex] =
        players[firstPlayerIndex].copyWith(isCurrentTurn: true);

    // カードの作成（2〜12の数字カード）
    final cards = List.generate(
        11,
        (index) => GameCard(
              id: _uuid.v4(),
              number: index + 2,
              status: CardStatus.onTable, // 最初は全てのカードが場に置かれている
            ));

    // サイコロの作成
    final dice1 = Dice(id: _uuid.v4());
    final dice2 = Dice(id: _uuid.v4());
    final dicePair = DicePair(dice1: dice1, dice2: dice2);

    // ゲームセッションの作成
    state = GameSession(
      id: _uuid.v4(),
      players: players,
      cards: cards,
      dicePair: dicePair,
      currentPlayerIndex: firstPlayerIndex,
      status: GameStatus.playing,
      startedAt: DateTime.now(),
      hasRolledDice: false,
    );
  }

  /// サイコロを振る
  String rollDice() {
    if (state == null) return "ゲームが開始されていません";

    // すでにサイコロを振っている場合は処理しない
    if (state!.hasRolledDice) {
      return "すでにサイコロを振っています。次のプレイヤーに交代してください。";
    }

    // 1〜6のランダムな値を生成
    final value1 = _random.nextInt(6) + 1;
    final value2 = _random.nextInt(6) + 1;

    // サイコロの値を更新
    final dice1 = state!.dicePair!.dice1.copyWith(
      value: value1,
      isRolled: true,
    );
    final dice2 = state!.dicePair!.dice2.copyWith(
      value: value2,
      isRolled: true,
    );

    // サイコロペアを更新
    final dicePair = DicePair(
      dice1: dice1,
      dice2: dice2,
      rolledAt: DateTime.now(),
    );

    // ゲーム状態を更新（サイコロを振ったフラグをtrueに）
    state = state!.copyWith(
      dicePair: dicePair,
      hasRolledDice: true,
    );

    // サイコロの目に応じたゲームロジックの実行
    return _processCardByDiceValue(dicePair.total);
  }

  /// サイコロの目に応じたカード処理
  String _processCardByDiceValue(int diceValue) {
    if (state == null) return "ゲームが開始されていません";

    // 現在のプレイヤーを取得
    final currentPlayerIndex = state!.currentPlayerIndex;
    final currentPlayer = state!.players[currentPlayerIndex];

    // サイコロの目に対応するカードを探す
    final targetCard = state!.cards.firstWhere(
      (card) => card.number == diceValue,
      orElse: () => GameCard(id: "", number: diceValue), // カードが見つからない場合のダミー
    );

    // カードが見つからない場合（ありえないはずだが念のため）
    if (targetCard.id.isEmpty) {
      return "エラー: ${diceValue}の数字のカードが見つかりません";
    }

    // カードの状態に応じた処理
    switch (targetCard.status) {
      case CardStatus.onTable:
        // 場にあるカードを獲得
        return _acquireCardFromTable(targetCard.id);

      case CardStatus.withPlayer:
        // カードを持っているプレイヤーを特定
        final ownerPlayer = state!.players.firstWhere(
          (player) => player.id == targetCard.ownerId,
          orElse: () => Player(id: "", name: "不明"),
        );

        if (ownerPlayer.id.isEmpty) {
          return "エラー: カードの所有者が見つかりません";
        }

        // 自分が持っているカードの場合
        if (targetCard.ownerId == currentPlayer.id) {
          // セーフの場合、カードを前のプレイヤーに渡す
          return _passCardToPreviousPlayer(targetCard.id);
        } else {
          // 他のプレイヤーが持っているカード → そのプレイヤーがアウト（アウト回数を増やす）
          return _incrementPlayerOutCount(ownerPlayer.id, targetCard.number);
        }

      case CardStatus.inDeck:
        // 山札にあるカード（このゲームでは使用しない）
        return "エラー: カードが山札にあります";
    }
  }

  /// プレイヤーのアウト回数を増やす
  String _incrementPlayerOutCount(String playerId, int cardNumber) {
    if (state == null) return "ゲームが開始されていません";

    // プレイヤーを特定
    final playerIndex =
        state!.players.indexWhere((player) => player.id == playerId);
    if (playerIndex == -1) {
      return "エラー: プレイヤーが見つかりません";
    }

    final player = state!.players[playerIndex];

    // アウト回数を増やす
    final updatedPlayers = [...state!.players];
    updatedPlayers[playerIndex] = player.copyWith(
      outCount: player.outCount + 1,
    );

    // ゲーム状態を更新
    state = state!.copyWith(
      players: updatedPlayers,
    );

    return "${player.name}がアウトです！${cardNumber}の数字のカードを持っています";
  }

  /// セーフの場合、カードを前のプレイヤーに渡す
  String _passCardToPreviousPlayer(String cardId) {
    if (state == null) return "ゲームが開始されていません";

    // 現在のプレイヤーを取得
    final currentPlayerIndex = state!.currentPlayerIndex;
    final currentPlayer = state!.players[currentPlayerIndex];

    // 前のプレイヤーのインデックスを計算（循環させる）
    final previousPlayerIndex =
        (currentPlayerIndex - 1 + state!.players.length) %
            state!.players.length;
    final previousPlayer = state!.players[previousPlayerIndex];

    // 対象のカードを取得
    final targetCard = state!.cards.firstWhere((card) => card.id == cardId);

    // カードの所有者を変更
    final updatedCards = state!.cards.map((card) {
      if (card.id == cardId) {
        return card.copyWith(
          ownerId: previousPlayer.id,
        );
      }
      return card;
    }).toList();

    // プレイヤーのカードリストを更新
    final updatedPlayers = state!.players.map((player) {
      if (player.id == currentPlayer.id) {
        // 現在のプレイヤーからカードを削除
        return player.copyWith(
          cards: player.cards.where((card) => card.id != cardId).toList(),
        );
      } else if (player.id == previousPlayer.id) {
        // 前のプレイヤーにカードを追加
        return player.copyWith(
          cards: [...player.cards, targetCard.copyWith(ownerId: player.id)],
        );
      }
      return player;
    }).toList();

    // ゲーム状態を更新
    state = state!.copyWith(
      cards: updatedCards,
      players: updatedPlayers,
    );

    return "セーフ！${currentPlayer.name}の${targetCard.number}の数字のカードが${previousPlayer.name}に渡りました";
  }

  /// 場にあるカードを獲得
  String _acquireCardFromTable(String cardId) {
    if (state == null) return "ゲームが開始されていません";

    // 現在のプレイヤーを取得
    final currentPlayerIndex = state!.currentPlayerIndex;
    final currentPlayer = state!.players[currentPlayerIndex];

    // カードを更新
    final updatedCards = state!.cards.map((card) {
      if (card.id == cardId) {
        return card.copyWith(
          status: CardStatus.withPlayer,
          ownerId: currentPlayer.id,
        );
      }
      return card;
    }).toList();

    // プレイヤーを更新
    final acquiredCard = updatedCards.firstWhere((card) => card.id == cardId);
    final updatedPlayers = state!.players.map((player) {
      if (player.id == currentPlayer.id) {
        return player.copyWith(
          cards: [...player.cards, acquiredCard],
        );
      }
      return player;
    }).toList();

    // ゲーム状態を更新
    state = state!.copyWith(
      cards: updatedCards,
      players: updatedPlayers,
    );

    return "${currentPlayer.name}が${acquiredCard.number}の数字を手に入れました";
  }

  /// 次のプレイヤーに交代
  void nextPlayer() {
    if (state == null) return;

    // 現在のプレイヤーのターンを終了
    final currentPlayerIndex = state!.currentPlayerIndex;
    final updatedPlayers = [...state!.players];
    updatedPlayers[currentPlayerIndex] =
        updatedPlayers[currentPlayerIndex].copyWith(
      isCurrentTurn: false,
    );

    // 次のプレイヤーのインデックスを計算
    final nextPlayerIndex = (currentPlayerIndex + 1) % updatedPlayers.length;
    updatedPlayers[nextPlayerIndex] = updatedPlayers[nextPlayerIndex].copyWith(
      isCurrentTurn: true,
    );

    // ゲーム状態を更新（サイコロを振ったフラグをfalseにリセット）
    state = state!.copyWith(
      players: updatedPlayers,
      currentPlayerIndex: nextPlayerIndex,
      hasRolledDice: false,
    );
  }

  /// ゲームが終了したかどうかをチェック
  bool isGameFinished() {
    if (state == null) return false;

    // 場にカードが残っているかチェック
    final hasCardsOnTable =
        state!.cards.any((card) => card.status == CardStatus.onTable);

    return !hasCardsOnTable;
  }

  /// 全プレイヤーのアウト回数情報を取得
  String getOutCountSummary() {
    if (state == null) return "ゲームが開始されていません";

    final summary = StringBuffer("ゲーム終了！\n\n各プレイヤーのアウト回数:\n");

    // アウト回数の少ない順にソート
    final sortedPlayers = [...state!.players];
    sortedPlayers.sort((a, b) => a.outCount.compareTo(b.outCount));

    for (final player in sortedPlayers) {
      summary.write("${player.name}: ${player.outCount}回\n");
    }

    return summary.toString();
  }

  /// ゲームを終了
  void endGame() {
    if (state == null) return;

    // ゲーム状態を更新
    state = state!.copyWith(
      status: GameStatus.finished,
      finishedAt: DateTime.now(),
    );
  }

  /// ゲームをリセット
  void resetGame() {
    state = null;
  }
}
