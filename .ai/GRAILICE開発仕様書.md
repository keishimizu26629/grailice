# GRAILICE（GRAILICE）アプリ開発仕様書

## プロジェクト概要

「GRAILICE」は、2 つのサイコロと 2〜12 のトランプカードを使用する飲み会ゲームのデジタル版です。本アプリでは、Unity を使用して UI を実装し、Flutter をアプリの内部処理に使用、広告表示には Admob を採用します。

## 技術スタック

- **UI/グラフィック**: Unity
- **アプリケーションロジック**: Flutter
- **広告**: Admob
- **ローカルストレージ**: SharedPreferences / Hive
- **プラットフォーム**: iOS/Android

## 開発アプローチ

本プロジェクトでは「Flutter ファースト」の開発アプローチを採用します。

### Flutter ファーストアプローチの概要

1. **第 1 段階**: Flutter でゲームロジックと簡易 UI を実装

   - ゲームの基本ロジック（プレイヤー管理、カード管理、サイコロ機能など）
   - 簡易的な UI（2D のサイコロ表示など）
   - 状態管理とデータ永続化

2. **第 2 段階**: Unity でサイコロの物理演算と視覚効果を実装

   - 3D サイコロモデルの作成
   - 物理演算の実装
   - アニメーションと視覚効果

3. **第 3 段階**: Flutter と Unity の統合

   - flutter_unity_widget を使用した連携
   - メッセージングシステムの実装
   - イベント処理の連携

4. **第 4 段階**: 最終調整とリリース準備
   - パフォーマンス最適化
   - 広告実装
   - ストア公開準備

### Flutter ファーストアプローチの利点

- 早い段階で機能するプロトタイプを作成できる
- ゲームロジックと UI を分離して開発できる
- 段階的に高度な視覚効果を追加できる
- Unity 部分が動作しない場合のフォールバック UI が用意できる

## ゲームルール

### 基本ルール

1. プレイヤーは 2〜4 人で遊びます
2. 場には 2〜12 の数字カードが置かれています
3. プレイヤーは順番にサイコロを 2 つ振ります
4. サイコロの目の合計に対応する数字のカードを処理します
5. 全てのカードがプレイヤーの手に渡るか、一定のターン数が経過したらゲーム終了です

### 詳細ルール

1. **サイコロ**:

   - 各プレイヤーは 1 ターンにサイコロを振れる回数は 1 回のみです
   - サイコロの目の合計（2〜12）に対応するカードを処理します

2. **カード処理**:

   - サイコロを振った後、対応する数字のカードは自動的に処理されます
   - カードの状態によって以下の処理が行われます:
     - **場にある場合**: プレイヤーがカードを獲得し、「プレイヤー〇〇が〇〇の数字を手に入れました」と表示
     - **他のプレイヤーが持っている場合**: サイコロを振ったプレイヤーがアウトとなり、「プレイヤー〇〇がアウトです」と表示
     - **自分が持っている場合**: セーフとなり、「セーフ！〇〇の数字のカードがプレイヤー〇〇に渡ります」と表示

3. **カードの意味**:

   - カードはネガティブな意味を持ちます（罰ゲームや罰金など）
   - 多くのカードを持つことはデメリットとなります

4. **ゲーム終了**:
   - すべてのカードがプレイヤーの手に渡った時点でゲーム終了
   - または、設定した最大ターン数に達した時点でゲーム終了
   - 最もカードが少ないプレイヤーが勝者となります

## 機能要件

### 1. ゲーム機能

#### 1.1 サイコロ機能

- Unity を使用して 3D の酒どんぶりに 2 つのサイコロを投げ入れるアニメーション
- 物理エンジンによるリアルなサイコロの動き
- ユーザーの振る動作（スマホを振る、または画面タップ）によるサイコロ投げ
- サイコロの目の合計を自動計算して表示

#### 1.2 トランプ表示

- 2〜12 の数字カードをデジタルトランプとして表示
- 各カードのステータス表示（場にある、プレイヤー A が持っている、など）
- カード獲得時のアニメーション効果
- カードのやり取りを視覚的に表現

#### 1.3 プレイヤー管理

- 最大 4 人までのプレイヤー登録機能（名前入力のみ）
- プレイヤーのターン管理
- プレイヤーごとの獲得カード表示

### 2. システム機能

#### 2.1 ゲーム設定

- 基本的なゲームルール設定
- 罰ゲームの種類設定（お酒、罰金、タスクなど）
- ゲーム時間の設定

#### 2.2 広告表示

- ゲーム開始時のバナー広告
- ゲーム終了時のインタースティシャル広告
- 非侵入的な広告表示

#### 2.3 ゲーム状態の保存

- アプリが予期せず終了した場合でもゲーム状態を保持
- 次回起動時に前回のゲーム状態から再開可能
- ローカルストレージを使用した軽量なデータ保存

## スモールスタート実装内容

### フェーズ 1: 最小実装（MVP）

以下の機能に絞ってシンプルな実装を行います：

1. **シンプルなゲーム開始フロー**

   - アプリ起動後、直接プレイヤー人数と名前を入力
   - ユーザー認証なし
   - ローカルストレージによる最小限のデータ保持（ゲーム状態のみ）

2. **基本ゲーム機能**

   - サイコロ機能（基本的な物理演算）
   - シンプルなカード表示と管理
   - 基本的なターン管理

3. **最小限の UI**

   - 必要最低限の画面構成
   - シンプルなアニメーション
   - 基本的な操作性の確保

4. **Admob 広告**

   - バナー広告の実装
   - 最小限のインタースティシャル広告

5. **ゲーム状態の保存**
   - SharedPreferences を使用した軽量なゲーム状態保存
   - アプリ再起動時のゲーム復元機能

### フェーズ 2 以降の拡張機能（将来対応）

- 高度なアニメーションとエフェクト
- カスタマイズ可能なルール設定
- より高度なローカルデータ保存（ハイスコアなど）
- 追加のゲームモード

## 技術実装詳細

### 1. プロジェクト構成（クリーンアーキテクチャ）

#### 1.1 プロジェクトルート構成

```
GRAILICE/
├── .ai/                      # AI関連ドキュメント
├── .dart_tool/               # Dartツール関連ファイル
├── .dev-document/            # 開発ドキュメント
├── .github/                  # GitHub Actions設定
├── .vscode/                  # VSCode設定
├── android/                  # Androidプラットフォーム固有コード
├── assets/                   # 画像、フォント等の静的リソース
├── build/                    # ビルド成果物
├── ios/                      # iOSプラットフォーム固有コード
├── lib/                      # Dartソースコード（メイン）
├── test/                     # ユニットテスト
├── unity/                    # Unityプロジェクト
├── pubspec.yaml              # 依存関係定義
└── README.md                 # プロジェクト説明
```

#### 1.2 lib ディレクトリ構成（シンプル化）

```
lib/
├── application/              # ユースケース層
│   ├── game/                 # ゲーム管理
│   ├── player/               # プレイヤー管理
│   ├── dice/                 # サイコロ機能
│   ├── card/                 # カード管理
│   ├── storage/              # ストレージ管理
│   └── providers/            # プロバイダー定義
│
├── domain/                   # ドメイン層
│   ├── entity/               # エンティティ
│   │   ├── player.dart
│   │   ├── game_session.dart
│   │   ├── dice.dart
│   │   └── card.dart
│   └── value/                # 値オブジェクト
│
├── infrastructure/           # インフラストラクチャ層
│   ├── admob/                # Admob広告実装
│   ├── unity/                # Unity連携実装
│   ├── storage/              # ローカルストレージ実装
│   │   ├── shared_preferences_service.dart
│   │   └── game_state_repository.dart
│   └── providers.dart        # 依存性注入
│
├── presentation/             # プレゼンテーション層
│   ├── game/                 # ゲーム画面
│   │   ├── dice_view.dart
│   │   ├── card_view.dart
│   │   └── player_view.dart
│   ├── home/                 # ホーム画面
│   ├── player_setup/         # プレイヤー設定画面
│   ├── widgets/              # 共通ウィジェット
│   └── presentation_provider.dart
│
├── common/                   # 共通ユーティリティ
│
├── config/                   # 設定
│   ├── routes.dart           # ルート定義
│   └── theme.dart            # テーマ定義
│
├── utils/                    # ユーティリティ関数
│
└── main.dart                 # アプリケーションエントリーポイント
```

### 2. Unity 実装 (UI/グラフィックス)

#### 2.1 Unity プロジェクト構成（シンプル化）

```
unity/
└── Assets/
    ├── Scenes/
    │   ├── MainGame.unity
    │   └── DiceRoll.unity
    ├── Prefabs/
    │   ├── Dice.prefab
    │   ├── Bowl.prefab
    │   └── Card.prefab
    ├── Scripts/
    │   ├── Bridge/
    │   │   ├── FlutterBridge.cs      # Flutter連携
    │   │   └── MessageHandler.cs     # メッセージハンドリング
    │   ├── Game/
    │   │   ├── DiceController.cs     # サイコロ制御
    │   │   ├── BowlController.cs     # どんぶり制御
    │   │   └── CardManager.cs        # カード管理
    │   └── UI/
    │       └── GameUIManager.cs      # UI管理
    ├── Materials/
    ├── Textures/
    └── Animations/
```

#### 2.2 サイコロ物理実装

- Unity Physics Engine を使用してリアルなサイコロの動きを実装
- サイコロの目の検出アルゴリズム
- どんぶりの中でのサイコロの衝突検出と挙動制御
- サイコロ振りのジェスチャー検出

#### 2.3 カードビジュアル

- 2D スプライトによるシンプルなカード表現
- 基本的なカード移動アニメーション

### 3. Flutter-Unity 連携

#### 3.1 Unity-Flutter 連携アーキテクチャ

```
lib/
├── infrastructure/
│   └── unity/
│       ├── unity_widget.dart         # Unityビューをホストするウィジェット
│       ├── unity_message_handler.dart # Unity-Flutter間メッセージング
│       └── unity_controller.dart     # Unityコントロール
│
└── application/
    └── game/
        └── unity_bridge_service.dart # Unity-Flutterブリッジサービス
```

#### 3.2 データフロー

- **ユーザー操作** → **Presentation 層** → **Application 層** → **Domain 層** → **Infrastructure 層** → **Unity**
- **Unity** ⟷ **Flutter** (Unity-Flutter 間の双方向通信)
  - Flutter 側: `UnityMessageHandler`を通じて Unity にメッセージを送信
  - Unity 側: `FlutterBridge`を通じて Flutter にメッセージを送信

#### 3.3 メッセージパッシング

- JSON 形式でのデータ交換
- イベント駆動型の通信モデル
- ゲームステートの同期

### 4. ローカルストレージ実装

#### 4.1 ゲーム状態の保存

```dart
// game_state_repository.dart
class GameStateRepository {
  final SharedPreferencesService _prefsService;

  GameStateRepository(this._prefsService);

  Future<void> saveGameState(GameSession gameSession) async {
    final gameStateJson = jsonEncode(gameSession.toJson());
    await _prefsService.setString('current_game_state', gameStateJson);
    await _prefsService.setBool('has_saved_game', true);
  }

  Future<GameSession?> loadGameState() async {
    final hasSavedGame = await _prefsService.getBool('has_saved_game') ?? false;
    if (!hasSavedGame) return null;

    final gameStateJson = await _prefsService.getString('current_game_state');
    if (gameStateJson == null) return null;

    try {
      final gameState = GameSession.fromJson(jsonDecode(gameStateJson));
      return gameState;
    } catch (e) {
      // エラーハンドリング
      return null;
    }
  }

  Future<void> clearGameState() async {
    await _prefsService.remove('current_game_state');
    await _prefsService.setBool('has_saved_game', false);
  }
}
```

#### 4.2 自動保存メカニズム

```dart
// game_controller.dart
class GameController extends ChangeNotifier {
  final GameStateRepository _gameStateRepository;
  GameSession? _currentGame;

  GameController(this._gameStateRepository) {
    _loadSavedGame();
  }

  Future<void> _loadSavedGame() async {
    _currentGame = await _gameStateRepository.loadGameState();
    notifyListeners();
  }

  // ゲーム状態が変更されるたびに呼び出される
  Future<void> updateGameState(GameSession updatedGame) async {
    _currentGame = updatedGame;
    await _gameStateRepository.saveGameState(updatedGame);
    notifyListeners();
  }

  // アプリのライフサイクルイベントと連携
  void onAppPause() {
    if (_currentGame != null) {
      _gameStateRepository.saveGameState(_currentGame!);
    }
  }
}
```

#### 4.3 SharedPreferences サービス

```dart
// shared_preferences_service.dart
class SharedPreferencesService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
}
```

#### 4.4 アプリライフサイクル管理

```dart
// app_lifecycle_manager.dart
class AppLifecycleManager extends StatefulWidget {
  final Widget child;
  final GameController gameController;

  const AppLifecycleManager({
    Key? key,
    required this.child,
    required this.gameController,
  }) : super(key: key);

  @override
  _AppLifecycleManagerState createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      widget.gameController.onAppPause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
```

### 5. Admob 広告実装

#### 5.1 広告種類

- バナー広告（ゲーム画面下部）
- インタースティシャル広告（ゲーム終了時）

#### 5.2 広告実装

- Admob SDK の統合
- 非侵入的な広告表示
- 広告 ID 管理（開発/本番環境）

### 6. アーキテクチャ設計原則

#### 6.1 状態管理

- **Riverpod**を使用した状態管理
- **ChangeNotifier**または**StateNotifier**による UI 状態の管理

#### 6.2 依存性注入

- **Riverpod**を使用した依存性注入
- テスト容易性のための**インターフェース**と**実装**の分離

#### 6.3 エラーハンドリング

- 基本的なエラーハンドリング
- ユーザーフレンドリーなエラーメッセージ表示

#### 6.4 パフォーマンス最適化

- Unity 側の物理演算の最適化
- Flutter-Unity 間通信の効率化
- 画像リソースの最適化

## 開発フロー

### フェーズ 1: 基本機能実装（MVP）

- プレイヤー設定画面の実装
- Unity でサイコロとどんぶりの基本物理実装
- Flutter でゲーム基本ロジック実装
- UI の基本レイアウト設計
- Admob 広告の基本実装
- ローカルストレージによるゲーム状態保存機能の実装

### フェーズ 2: 機能改善

- アニメーションの洗練
- サウンドエフェクト追加
- ユーザー体験の向上
- 広告表示の最適化
- ゲーム状態保存機能の安定性向上

### フェーズ 3: テストとリリース

- ユーザビリティテスト
- パフォーマンス最適化
- ストアへの公開準備

## AI エージェントへの開発指示例

```
@AIエージェント

タスク: GRAILICEアプリのUnityサイコロ物理実装（MVP版）

優先度: 高
期限: 1週間

詳細:
1. シンプルな3Dモデルの酒どんぶりを作成し、基本的な物理特性を設定してください
2. サイコロ2個の3Dモデルと基本的な物理挙動を実装してください
3. 画面タップでサイコロが投げられる基本機能を実装してください
4. サイコロの目を自動的に検出して合計値を計算する基本アルゴリズムを実装してください
5. モバイルデバイスでの動作を確認してください

技術仕様:
- Unity 2022.3以上を使用
- サイコロはPhysics.Raycastを使用して目の検出を行う
- シンプルな物理演算で実装
- 最小限のアセットで実装

成果物:
- Unityプロジェクトファイル一式
- DiceController.csスクリプト
- BowlController.csスクリプト
- FlutterBridge.csスクリプト
```

## テスト計画

### 単体テスト

- サイコロの物理挙動テスト
- カード移動ロジックテスト
- プレイヤーターン管理テスト
- ゲーム状態保存・復元テスト

### 統合テスト

- Unity-Flutter 連携テスト
- 広告表示テスト
- ゲームフローテスト
- アプリ強制終了時のデータ復元テスト

### ユーザビリティテスト

- 初心者プレイヤーによるテスト
- さまざまなデバイスでのテスト

## リリース計画

- **クローズドベータ**: 限定ユーザーによるテスト
- **フルリリース**: App Store 及び Google Play での公開

## マネタイズ戦略

- **広告収益**: Admob バナー広告とインタースティシャル広告
- **将来的な拡張**: プレミアム版（広告なし）の検討

## 今後の展望（優先度低）

- より高度なローカルデータ保存機能
- カスタマイズ可能なルール設定
- 追加のゲームモード
- UI/UX の改善

---

本仕様書は「GRAILICE（GRAILICE）」アプリ開発プロジェクトのスモールスタート計画を示すものです。MVP を優先し、最小限の機能で迅速にリリースすることを目指します。
