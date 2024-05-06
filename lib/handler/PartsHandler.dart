import 'package:autohub/pages/PartExtendedPage.dart';
import 'package:flutter/material.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../components/PartWidget.dart';
import '../data/PartsData.dart';
import '../data_notifier/PartsNotifier.dart';
import '../data_notifier/UserProfileNotifier.dart';
import '../db_references/NotifierType.dart';
import '../operation/CategoryOperation.dart';
import '../pages/ViewPartsPage.dart';

class PartsHandler extends StatelessWidget {
  final String category;
  final PartsNotifier partsNotifier;
  final WidgetStateNotifier<List<PartsData>> partsDataStateNotifier;

  const PartsHandler({
    super.key,
    required this.category,
    required this.partsDataStateNotifier,
    required this.partsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    void onTapPartData(PartsData partsData) {
      UserProfileNotifier? userAddedProfileNotifier = partsNotifier
          .getPostProfileNotifier(partsData.partsAddedBy, NotifierType.normal);
      UserProfileNotifier? userEditedProfileNotifier =
          partsNotifier.getPostProfileNotifier(
              partsData.partsEditedBy ?? '', NotifierType.normal);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PartExtendedPage(
                    partsData: partsData,
                    userAddedProfileNotifier: userAddedProfileNotifier,
                    userEditedProfileNotifier: userEditedProfileNotifier,
                  )));
    }

    void onViewAllParts() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewPartsPage(
                    partsNotifier: partsNotifier,
                  )));
    }

    return WidgetStateConsumer(
        widgetStateNotifier: partsDataStateNotifier,
        widgetStateBuilder: (context, partsData) {
          if (partsData == null) return const SizedBox();
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CategoryOperation().displayTheCategory(category),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (partsData.length > 10)
                      TextButton(
                        onPressed: onViewAllParts,
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 240, // Set a fixed height for the horizontal list
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: partsData.length > 10 ? 10 : partsData.length,
                    itemBuilder: (BuildContext context, int index) {
                      UserProfileNotifier? userAddedProfileNotifier =
                          partsNotifier.getPostProfileNotifier(
                              partsData[index].partsAddedBy,
                              NotifierType.normal);
                      UserProfileNotifier? userEditedProfileNotifier =
                          partsNotifier.getPostProfileNotifier(
                              partsData[index].partsEditedBy ?? '',
                              NotifierType.normal);

                      return SizedBox(
                        width: 200, // Set a fixed width for each card
                        child: PartWidget(
                          partData: partsData[index],
                          onTap: () {
                            onTapPartData(partsData[index]);
                          },
                          userAddedProfileNotifier: userAddedProfileNotifier,
                          userEditedProfileNotifier: userEditedProfileNotifier,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
