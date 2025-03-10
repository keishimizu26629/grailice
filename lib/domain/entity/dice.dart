import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'dice.freezed.dart';
part 'dice.g.dart';

/// サイコロエンティティ
@freezed
class Dice with _$Dice {
  const factory Dice({
    /// サイコロID
    required String id,

    /// サイコロの目（1〜6）
    @Default(1) int value,

    /// サイコロが振られたかどうか
    @Default(false) bool isRolled,
  }) = _Dice;

  factory Dice.fromJson(Map<String, dynamic> json) => _$DiceFromJson(json);
}

/// サイコロのペアを表すエンティティ
@freezed
class DicePair with _$DicePair {
  const DicePair._(); // プライベートコンストラクタを追加

  const factory DicePair({
    /// 1つ目のサイコロ
    required Dice dice1,

    /// 2つ目のサイコロ
    required Dice dice2,

    /// サイコロが振られた時間
    DateTime? rolledAt,
  }) = _DicePair;

  /// サイコロの目の合計を取得
  int get total => dice1.value + dice2.value;

  factory DicePair.fromJson(Map<String, dynamic> json) =>
      _$DicePairFromJson(json);
}
