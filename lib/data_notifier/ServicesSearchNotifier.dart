import 'package:autohub/data/ServicesData.dart';
import 'package:autohub/data_notifier/SearchSuggestionNotifier.dart';
import 'package:autohub/data_notifier/SearchedPageNotifier.dart';
import 'package:autohub/data_notifier/ServicesNotifier.dart';
import 'package:autohub/db_references/NotifierType.dart';
import 'package:autohub/operation/ServicesOperation.dart';

import '../components/CustomProject.dart';
import '../db_references/Services.dart';

class ServicesSearchNotifier {
  static final ServicesSearchNotifier instance =
      ServicesSearchNotifier.internal();

  factory ServicesSearchNotifier() => instance;

  ServicesSearchNotifier.internal();

  List<ServicesData> _data = [];

  bool started = false;
  Map<String, ServicesNotifier> _servicesNotifiers = {};

  ServicesNotifier? getServiceNotifier(String serviceId) {
    return _servicesNotifiers[serviceId];
  }

  ServicesSearchNotifier startSearch() {
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

  String textSearch = "";

  void handleSearch(SearchTextData searchTextData) {
    if (searchTextData.searchTextDirection == SearchTextDirection.forward ||
        searchTextData.searchTextDirection == SearchTextDirection.changed) {
      _fetchRelatedServicesData(searchTextData.text);
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
    List<ServicesData> search = _data
        .where((element) => element.servicesIdentity
            .toLowerCase()
            .contains(searchTextData.text.toLowerCase()))
        .toList();

    for (var data in search) {
      String key = "services_${keys.length}";
      keys.add(key);
      SearchSuggestionNotifier()
          .addSuggestion(key, data.servicesIdentity, data);
    }

    SearchSuggestionNotifier().sendSuggestionUpdate();
  }

  void _fetchRelatedServicesData(String likeText) {
    ServicesOperation()
        .getServiceDataForSearch(likeText, 10)
        .then((value) async {
      for (var data in value) {
        final id = data[dbReference(Services.id)];
        if (!_servicesNotifiers.containsKey(id)) {
          _servicesNotifiers[id] = ServicesNotifier();
        }
      }

      final check = value.map((e) async {
        return (await _servicesNotifiers[e[dbReference(Services.id)]]
                ?.getPublicServiceData([e], NotifierType.external))
            ?.single;
      });

      List<ServicesData?> getData = await Future.wait(check);
      final partsIds = _data.map((e) => e.servicesId).toList();
      for (var element in getData) {
        if (element != null && !partsIds.contains(element.servicesId)) {
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
