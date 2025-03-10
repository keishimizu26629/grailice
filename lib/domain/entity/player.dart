import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'card.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// プレイヤーエンティティ
@freezed
class Player with _$Player {
  const factory Player({
    /// プレイヤーID
    required String id,

    /// プレイヤー名
    required String name,

    /// 獲得したカード
    @Default([]) List<GameCard> cards,

    /// 現在のターンかどうか
    @Default(false) bool isCurrentTurn,

    /// アウトになった回数
    @Default(0) int outCount,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
