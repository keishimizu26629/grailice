import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

/// カードの状態を表す列挙型
enum CardStatus {
  /// 場にある
  onTable,

  /// プレイヤーが持っている
  withPlayer,

  /// 山札にある
  inDeck
}

/// ゲームカードエンティティ
@freezed
class GameCard with _$GameCard {
  const factory GameCard({
    /// カードID
    required String id,

    /// カードの数字（2〜12）
    required int number,

    /// カードの状態
    @Default(CardStatus.inDeck) CardStatus status,

    /// カードを持っているプレイヤーのID（nullの場合は誰も持っていない）
    String? ownerId,
  }) = _GameCard;

  factory GameCard.fromJson(Map<String, dynamic> json) =>
      _$GameCardFromJson(json);
}
