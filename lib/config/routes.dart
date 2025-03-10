import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/home/home_page.dart';
import '../presentation/player_setup/player_setup_page.dart';
import '../presentation/game/game_page.dart';

/// ルーター設定のプロバイダー
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // ホーム画面
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // プレイヤー設定画面
      GoRoute(
        path: '/player-setup',
        name: 'player-setup',
        builder: (context, state) => const PlayerSetupPage(),
      ),

      // ゲーム画面
      GoRoute(
        path: '/game',
        name: 'game',
        builder: (context, state) => const GamePage(),
      ),
    ],

    // エラー画面
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('エラー')),
      body: Center(
        child: Text('ページが見つかりません: ${state.uri}'),
      ),
    ),
  );
});
