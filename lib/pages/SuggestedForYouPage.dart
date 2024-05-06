import 'package:autohub/components/CustomProject.dart';
import 'package:autohub/data/PartsData.dart';
import 'package:autohub/data/ServicesData.dart';
import 'package:autohub/data_notifier/PartsNotifier.dart';
import 'package:autohub/data_notifier/PartsSearchNotifier.dart';
import 'package:autohub/data_notifier/SearchSuggestionNotifier.dart';
import 'package:autohub/data_notifier/ServicesNotifier.dart';
import 'package:autohub/data_notifier/ServicesSearchNotifier.dart';
import 'package:autohub/handler/MediaHandler.dart';
import 'package:flutter/material.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../data_notifier/RecentSearchNotifier.dart';
import '../data_notifier/SearchedPageNotifier.dart';
import '../data_notifier/UserProfileNotifier.dart';
import '../db_references/NotifierType.dart';
import 'PartExtendedPage.dart';
import 'ServiceExtendedPage.dart';

class SuggestedForYouPage extends StatefulWidget {
  final WidgetStateNotifier<Map> searchResultNotifier;
  final WidgetStateNotifier<SearchTextData> searchTextNotifier;

  const SuggestedForYouPage(
      {super.key,
      required this.searchTextNotifier,
      required this.searchResultNotifier});

  @override
  State<SuggestedForYouPage> createState() => _SuggestedForYouPageState();
}

class _SuggestedForYouPageState extends State<SuggestedForYouPage> {
  void onTapServiceData(
      ServicesData servicesData, ServicesNotifier servicesNotifier) {
    UserProfileNotifier? userAddedProfileNotifier =
        servicesNotifier.getPostProfileNotifier(
            servicesData.servicesAddedBy, NotifierType.external);
    UserProfileNotifier? userEditedProfileNotifier =
        servicesNotifier.getPostProfileNotifier(
            servicesData.servicesEditedBy ?? '', NotifierType.external);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ServiceExtendedPage(
                  servicesData: servicesData,
                  userAddedProfileNotifier: userAddedProfileNotifier,
                  userEditedProfileNotifier: userEditedProfileNotifier,
                )));
  }

  void onTapPartData(PartsData partsData, PartsNotifier partsNotifier) {
    UserProfileNotifier? userAddedProfileNotifier = partsNotifier
        .getPostProfileNotifier(partsData.partsAddedBy, NotifierType.external);
    UserProfileNotifier? userEditedProfileNotifier =
        partsNotifier.getPostProfileNotifier(
            partsData.partsEditedBy ?? '', NotifierType.external);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PartExtendedPage(
                  partsData: partsData,
                  userAddedProfileNotifier: userAddedProfileNotifier,
                  userEditedProfileNotifier: userEditedProfileNotifier,
                )));
  }

  Widget getSuggestionView(SearchSuggestionData suggestion) {
    if (suggestion.data is PartsData) {
      PartsData partsData = suggestion.data as PartsData;
      return GestureDetector(
          onTap: () {
            RecentSearchNotifier().saveRecent(partsData.partsIdentity);
            SearchedPageNotifier()
                .handleSearchTextClick(partsData.partsIdentity);
            PartsNotifier? partsNotifier =
                PartsSearchNotifier().getPartsNotifiers(partsData.partsId);
            if (partsNotifier != null) {
              onTapPartData(partsData, partsNotifier);
            } else {
              showToastMobile(msg: "An error has occurred");
            }
          },
          child: Row(
            children: [
              Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  height: 50,
                  width: 50,
                  child: (partsData.partsMedia.firstOrNull != null)
                      ? MediaHandler(media: partsData.partsMedia.first)
                      : Icon(
                          Icons.shopping_cart_sharp,
                          color: Colors.black.withOpacity(0.7),
                          size: 35,
                        )),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    partsData.partsIdentity,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              const Text(
                "- parts",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              )
            ],
          ));
    }
    if (suggestion.data is ServicesData) {
      ServicesData servicesData = suggestion.data as ServicesData;
      return GestureDetector(
          onTap: () {
            RecentSearchNotifier().saveRecent(servicesData.servicesIdentity);
            SearchedPageNotifier()
                .handleSearchTextClick(servicesData.servicesIdentity);
            ServicesNotifier? servicesNotifier = ServicesSearchNotifier()
                .getServiceNotifier(servicesData.servicesId);
            if (servicesNotifier != null) {
              onTapServiceData(servicesData, servicesNotifier);
            } else {
              showToastMobile(msg: "An error has occurred");
            }
          },
          child: Row(
            children: [
              Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  height: 50,
                  width: 50,
                  child: (servicesData.servicesMedia.firstOrNull != null)
                      ? MediaHandler(media: servicesData.servicesMedia.first)
                      : Icon(
                          Icons.miscellaneous_services_outlined,
                          color: Colors.black.withOpacity(0.7),
                          size: 35,
                        )),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    servicesData.servicesIdentity,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              const Text(
                "- services",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              )
            ],
          ));
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetStateConsumer(
        widgetStateNotifier: widget.searchResultNotifier,
        widgetStateBuilder: (context, result) {
          return WidgetStateConsumer(
              widgetStateNotifier: widget.searchTextNotifier,
              widgetStateBuilder: (context, text) {
                return WidgetStateConsumer(
                    widgetStateNotifier: SearchSuggestionNotifier().state,
                    widgetStateBuilder: (context, suggestions) {
                      List<Widget> suggestionViews = suggestions
                              ?.asMap()
                              .map((key, value) {
                                return MapEntry(key, getSuggestionView(value));
                              })
                              .values
                              .toList() ??
                          [];

                      List<Widget> displayedSuggestion =
                          suggestionViews.sublist(
                              0,
                              suggestionViews.length > 15
                                  ? 15
                                  : suggestionViews.length);

                      if (displayedSuggestion.isEmpty) return const SizedBox();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                "Suggested for you",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          for (int index = 0;
                              index < displayedSuggestion.length;
                              index++)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: displayedSuggestion[index],
                            ),
                        ],
                      );
                    });
              });
        });
  }
}
