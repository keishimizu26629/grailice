import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entity/game_session.dart';

/// ゲームリポジトリのプロバイダー
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository();
});

/// ゲーム状態を保存・読み込みするリポジトリ
class GameRepository {
  static const _gameSessionKey = 'game_session';
  static const _hasGameKey = 'has_game';

  /// ゲーム状態を保存
  Future<void> saveGameSession(GameSession gameSession) async {
    final prefs = await SharedPreferences.getInstance();
    final gameJson = jsonEncode(gameSession.toJson());

    await prefs.setString(_gameSessionKey, gameJson);
    await prefs.setBool(_hasGameKey, true);
  }

  /// ゲーム状態を読み込み
  Future<GameSession?> loadGameSession() async {
    final prefs = await SharedPreferences.getInstance();
    final hasGame = prefs.getBool(_hasGameKey) ?? false;

    if (!hasGame) return null;

    final gameJson = prefs.getString(_gameSessionKey);
    if (gameJson == null) return null;

    try {
      final gameSession = GameSession.fromJson(jsonDecode(gameJson));
      return gameSession;
    } catch (e) {
      // エラーが発生した場合はnullを返す
      return null;
    }
  }

  /// ゲーム状態を削除
  Future<void> clearGameSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameSessionKey);
    await prefs.setBool(_hasGameKey, false);
  }

  /// 保存済みのゲームがあるかどうか
  Future<bool> hasSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasGameKey) ?? false;
  }
}
