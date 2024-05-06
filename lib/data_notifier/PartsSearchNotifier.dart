import 'package:autohub/components/CustomProject.dart';
import 'package:autohub/data/PartsData.dart';
import 'package:autohub/data_notifier/PartsNotifier.dart';
import 'package:autohub/data_notifier/SearchSuggestionNotifier.dart';
import 'package:autohub/data_notifier/SearchedPageNotifier.dart';
import 'package:autohub/db_references/NotifierType.dart';
import 'package:autohub/operation/PartsOperation.dart';

import '../db_references/Parts.dart';

class PartsSearchNotifier {
  static final PartsSearchNotifier instance = PartsSearchNotifier.internal();

  factory PartsSearchNotifier() => instance;

  PartsSearchNotifier.internal();

  List<PartsData> _data = [];

  bool started = false;

  Map<String, PartsNotifier> _partsNotifiers = {};

  PartsNotifier? getPartsNotifiers(String partsId) {
    return _partsNotifiers[partsId];
  }

  PartsSearchNotifier startSearch() {
    if (!started) {
      started = true;
      SearchedPageNotifier().searchTextNotifier.stream.listen((event) {
        if (event != null) {
          handleSearch(event);
        }
      });
    }
    return this;
  }

  List<String> keys = [];

  void handleSearch(SearchTextData searchTextData) {
    if (searchTextData.searchTextDirection == SearchTextDirection.forward ||
        searchTextData.searchTextDirection == SearchTextDirection.changed) {
      _fetchRelatedPartsData(searchTextData.text);
    }
    for (var key in keys) {
      SearchSuggestionNotifier().removeKey(key);
    }
    keys.clear();
    if (searchTextData.searchTextDirection == SearchTextDirection.end) {
      _data.clear();
      SearchSuggestionNotifier().sendSuggestionUpdate();
      return;
    }
    List<PartsData> search = _data
        .where((element) => element.partsIdentity
            .toLowerCase()
            .contains(searchTextData.text.toLowerCase()))
        .toList();

    for (var data in search) {
      String key = "parts_${keys.length}";
      keys.add(key);
      SearchSuggestionNotifier().addSuggestion(key, data.partsIdentity, data);
    }

    SearchSuggestionNotifier().sendSuggestionUpdate();
  }

  void _fetchRelatedPartsData(String likeText) {
    PartsOperation().getPartDataForSearch(likeText, 10).then((value) async {
      for (var data in value) {
        final id = data[dbReference(Parts.id)];
        if (!_partsNotifiers.containsKey(id)) {
          _partsNotifiers[id] = PartsNotifier();
        }
      }

      final check = value.map((e) async {
        return (await _partsNotifiers[e[dbReference(Parts.id)]]
                ?.getPublicPartData([e], NotifierType.external))
            ?.single;
      });

      List<PartsData?> getData = await Future.wait(check);
      final partsIds = _data.map((e) => e.partsId).toList();
      for (var element in getData) {
        if (element != null && !partsIds.contains(element.partsId)) {
          _data.add(element);
        }
      }
      final latestSearchData =
          SearchedPageNotifier().searchTextNotifier.currentValue;
      if (latestSearchData != null &&
          latestSearchData.searchTextDirection != SearchTextDirection.end) {
        handleSearch(
            SearchTextData(SearchTextDirection.stagnat, latestSearchData.text));
      }
    });
  }
}
