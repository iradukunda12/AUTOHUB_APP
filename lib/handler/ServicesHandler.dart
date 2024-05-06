import 'package:autohub/components/ServiceWidget.dart';
import 'package:autohub/data/ServicesData.dart';
import 'package:autohub/data_notifier/ServicesNotifier.dart';
import 'package:flutter/material.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../data_notifier/UserProfileNotifier.dart';
import '../db_references/NotifierType.dart';
import '../operation/CategoryOperation.dart';
import '../pages/ServiceExtendedPage.dart';
import '../pages/ViewServicesPage.dart';

class ServicesHandler extends StatelessWidget {
  final String category;
  final ServicesNotifier servicesNotifier;
  final WidgetStateNotifier<List<ServicesData>> servicesDataStateNotifier;

  const ServicesHandler({
    super.key,
    required this.category,
    required this.servicesDataStateNotifier,
    required this.servicesNotifier,
  });

  @override
  Widget build(BuildContext context) {
    void onTapServiceData(ServicesData servicesData) {
      UserProfileNotifier? userAddedProfileNotifier =
          servicesNotifier.getPostProfileNotifier(
              servicesData.servicesAddedBy, NotifierType.normal);
      UserProfileNotifier? userEditedProfileNotifier =
          servicesNotifier.getPostProfileNotifier(
              servicesData.servicesEditedBy ?? '', NotifierType.normal);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ServiceExtendedPage(
                    servicesData: servicesData,
                    userAddedProfileNotifier: userAddedProfileNotifier,
                    userEditedProfileNotifier: userEditedProfileNotifier,
                  )));
    }

    void onViewAllService() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewServicesPage(
                    servicesNotifier: servicesNotifier,
                  )));
    }

    return WidgetStateConsumer(
        widgetStateNotifier: servicesDataStateNotifier,
        widgetStateBuilder: (context, servicesData) {
          if (servicesData == null) return const SizedBox();
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
                    if (servicesData.length > 10)
                      TextButton(
                        onPressed: onViewAllService,
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
                    itemCount:
                        servicesData.length > 10 ? 10 : servicesData.length,
                    itemBuilder: (BuildContext context, int index) {
                      UserProfileNotifier? userAddedProfileNotifier =
                          servicesNotifier.getPostProfileNotifier(
                              servicesData[index].servicesAddedBy,
                              NotifierType.normal);
                      UserProfileNotifier? userEditedProfileNotifier =
                          servicesNotifier.getPostProfileNotifier(
                              servicesData[index].servicesEditedBy ?? '',
                              NotifierType.normal);

                      return SizedBox(
                        width: 200, // Set a fixed width for each card
                        child: ServiceWidget(
                          serviceData: servicesData[index],
                          onTap: () {
                            onTapServiceData(servicesData[index]);
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
