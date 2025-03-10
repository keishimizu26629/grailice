import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'player.dart';
import 'card.dart';
import 'dice.dart';

part 'game_session.freezed.dart';
part 'game_session.g.dart';

/// ゲームの状態を表す列挙型
enum GameStatus {
  /// 準備中
  preparing,

  /// プレイ中
  playing,

  /// 一時停止中
  paused,

  /// 終了
  finished
}

/// DicePairをJSONに変換するためのコンバーター
class DicePairConverter
    implements JsonConverter<DicePair?, Map<String, dynamic>?> {
  const DicePairConverter();

  @override
  DicePair? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return DicePair.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(DicePair? dicePair) {
    if (dicePair == null) return null;
    return dicePair.toJson();
  }
}

/// ゲームセッションエンティティ
@freezed
class GameSession with _$GameSession {
  const factory GameSession({
    /// セッションID
    required String id,

    /// プレイヤーリスト
    @Default([]) List<Player> players,

    /// カードリスト
    @Default([]) List<GameCard> cards,

    /// サイコロペア
    @DicePairConverter() DicePair? dicePair,

    /// 現在のプレイヤーのインデックス
    @Default(0) int currentPlayerIndex,

    /// ゲームの状態
    @Default(GameStatus.preparing) GameStatus status,

    /// ゲーム開始時間
    DateTime? startedAt,

    /// ゲーム終了時間
    DateTime? finishedAt,

    /// 現在のターンでサイコロを振ったかどうか
    @Default(false) bool hasRolledDice,
  }) = _GameSession;

  factory GameSession.fromJson(Map<String, dynamic> json) =>
      _$GameSessionFromJson(json);
}
