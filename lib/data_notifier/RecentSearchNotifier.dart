import 'dart:core';

import 'package:autohub/components/CustomProject.dart';
import 'package:autohub/operation/CacheOperation.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../db_references/Members.dart';

class RecentSearchNotifier {
  static final RecentSearchNotifier instance = RecentSearchNotifier.internal();

  factory RecentSearchNotifier() => instance;

  RecentSearchNotifier.internal();

  WidgetStateNotifier<List<String>> state = WidgetStateNotifier();

  final Map<String, String> _data = {};

  void loadRecentSearches() async {
    final saved = await CacheOperation()
        .getCacheKeys(dbReference(Members.recent_searches));

    for (var saveKey in saved) {
      final data = await CacheOperation()
          .getCacheData(dbReference(Members.recent_searches), saveKey);
      _data[saveKey] = data;
    }
    state.sendNewState(_data.values.toList());
  }

  void saveRecent(String recentText) async {
    String key = recentText.toLowerCase();
    await CacheOperation()
        .saveCacheData(dbReference(Members.recent_searches), key, recentText);
  }

  Future<void> deleteRecent(String recentText) async {
    String key = recentText.toLowerCase();
    await CacheOperation()
        .deleteCacheData(dbReference(Members.recent_searches), key);
    _data.remove(key);
    state.sendNewState(_data.values.toList());
  }

  void clearRecents() {
    _data.forEach((key, value) async {
      await CacheOperation()
          .deleteCacheData(dbReference(Members.recent_searches), key);
    });
    _data.clear();
    state.sendNewState(_data.values.toList());
  }

  void useRecentSearch(String finalResult) {
    String key = finalResult.toLowerCase();
    _data.remove(key);
    state.sendNewState(_data.values.toList());
  }
}
