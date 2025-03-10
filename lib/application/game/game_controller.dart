import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/game_session.dart';
import '../../domain/entity/player.dart';
import '../../infrastructure/storage/game_repository.dart';
import 'game_notifier.dart';

/// ゲームコントローラーのプロバイダー
final gameControllerProvider = Provider<GameController>((ref) {
  final gameRepository = ref.watch(gameRepositoryProvider);
  final gameNotifier = ref.watch(gameNotifierProvider.notifier);
  final messageNotifier = ref.watch(gameMessageProvider.notifier);
  return GameController(gameRepository, gameNotifier, messageNotifier);
});

/// ゲームの状態管理とローカルストレージを連携させるコントローラー
class GameController {
  final GameRepository _gameRepository;
  final GameNotifier _gameNotifier;
  final StateController<String?> _messageNotifier;

  GameController(
      this._gameRepository, this._gameNotifier, this._messageNotifier);

  /// 新しいゲームを開始
  Future<void> startNewGame(List<String> playerNames) async {
    // 既存のゲームがあれば削除
    await _gameRepository.clearGameSession();

    // 新しいゲームを開始
    _gameNotifier.startNewGame(playerNames);

    // メッセージを設定
    _messageNotifier.state = "ゲームを開始しました！";

    // ゲーム状態を保存
    final gameSession = _gameNotifier.state;
    if (gameSession != null) {
      await _gameRepository.saveGameSession(gameSession);
    }
  }

  /// 保存されたゲームを読み込み
  Future<bool> loadSavedGame() async {
    final gameSession = await _gameRepository.loadGameSession();
    if (gameSession != null) {
      // ゲーム状態を復元
      _gameNotifier.state = gameSession;
      _messageNotifier.state = "ゲームを再開しました！";
      return true;
    }
    return false;
  }

  /// サイコロを振る
  Future<void> rollDice() async {
    // サイコロを振る
    final message = _gameNotifier.rollDice();

    // メッセージを設定
    _messageNotifier.state = message;

    // ゲーム状態を保存
    final gameSession = _gameNotifier.state;
    if (gameSession != null) {
      await _gameRepository.saveGameSession(gameSession);
    }

    // ゲーム終了チェック
    if (_gameNotifier.isGameFinished()) {
      // アウト回数の情報を表示
      final outCountSummary = _gameNotifier.getOutCountSummary();
      _messageNotifier.state = outCountSummary;
      _gameNotifier.endGame();
    }
  }

  /// 次のプレイヤーに交代
  Future<void> nextPlayer() async {
    _gameNotifier.nextPlayer();

    // 現在のプレイヤーを取得
    final gameSession = _gameNotifier.state;
    if (gameSession != null) {
      final currentPlayer = gameSession.players[gameSession.currentPlayerIndex];
      _messageNotifier.state = "${currentPlayer.name}のターンです";

      // ゲーム状態を保存
      await _gameRepository.saveGameSession(gameSession);
    }
  }

  /// ゲームを終了
  Future<void> endGame() async {
    _gameNotifier.endGame();

    // アウト回数の情報を表示
    final outCountSummary = _gameNotifier.getOutCountSummary();
    _messageNotifier.state = outCountSummary;

    // ゲーム状態を保存
    final gameSession = _gameNotifier.state;
    if (gameSession != null) {
      await _gameRepository.saveGameSession(gameSession);
    }
  }

  /// ゲームをリセット
  Future<void> resetGame() async {
    _gameNotifier.resetGame();
    _messageNotifier.state = null;
    await _gameRepository.clearGameSession();
  }

  /// 保存済みのゲームがあるかどうか
  Future<bool> hasSavedGame() async {
    return await _gameRepository.hasSavedGame();
  }

  /// 現在のゲームメッセージを取得
  String? getCurrentMessage() {
    return _messageNotifier.state;
  }

  /// 現在のプレイヤーを取得
  Player? getCurrentPlayer() {
    final gameSession = _gameNotifier.state;
    if (gameSession == null) return null;

    return gameSession.players[gameSession.currentPlayerIndex];
  }
}
