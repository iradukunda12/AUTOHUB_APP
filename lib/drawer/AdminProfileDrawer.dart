import 'dart:async';

import 'package:autohub/data_notifier/CategoryNotifier.dart';
import 'package:autohub/pages/ViewCategoryPage.dart';
import 'package:flutter/material.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../../components/CustomProject.dart';
import '../../main.dart';
import '../collections/common_collection/ProfileImage.dart';
import '../components/CustomOnClickContainer.dart';
import '../data/UserData.dart';
import '../data_notifier/ProfileNotifier.dart';
import '../db_references/Category.dart';
import '../operation/MembersOperation.dart';
import '../pages/SettingsPage.dart';
import '../pages/ViewCategoryDataPage.dart';

class AdminProfileDrawer extends StatelessWidget {
  const AdminProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    void goToSetting() {
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SettingsPage()));
      });
    }

    void viewCategory() {
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewCategoryPage(
                      categoryNotifier: CategoryNotifier().state,
                    )));
      });
    }

    void viewAllParts() {
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewCategoryDataPage(
                      categoryNotifier: CategoryNotifier().state,
                      categoryFor: Category.parts,
                    )));
      });
    }

    void viewAllServices() {
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewCategoryDataPage(
                      categoryNotifier: CategoryNotifier().state,
                      categoryFor: Category.services,
                    )));
      });
    }

    return Drawer(
        backgroundColor: Colors.white,
        width: getScreenWidth(context) - (getScreenWidth(context) * 0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomOnClickContainer(
                    onTap: goToSetting,
                    defaultColor: Colors.transparent,
                    clickedColor: Colors.grey.shade200,
                    child: const Icon(
                      Icons.settings,
                      color: Color(getDarkGreyColor),
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              WidgetStateConsumer(
                  widgetStateNotifier: ProfileNotifier().state,
                  widgetStateBuilder: (context, snapshot) {
                    return ProfileImage(
                      fullName: snapshot?.fullName ?? '',
                      iconSize: 45,
                      imageUri: MembersOperation().getMemberProfileBucketPath(
                          snapshot?.userId ?? '', snapshot?.profileIndex),
                      imageUrl: (imageAddress) {},
                    );
                  }),
              const SizedBox(
                height: 8,
              ),
              StreamBuilder(
                  initialData: ProfileNotifier().state.currentValue,
                  stream: ProfileNotifier().state.stream,
                  builder: (context, snapshot) {
                    UserData? userData = snapshot.data;
                    String fullname = "${userData?.fullName}";
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                fullname,
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.9),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [Expanded(child: Divider())],
              ),
              SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomOnClickContainer(
                        onTap: viewCategory,
                        defaultColor: Colors.white70,
                        clickedColor: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        child: Row(
                          children: [
                            Icon(
                              Icons.category,
                              color: Colors.black.withOpacity(0.8),
                              size: 30,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "View Category",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomOnClickContainer(
                        onTap: viewAllParts,
                        defaultColor: Colors.white70,
                        clickedColor: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        child: Row(
                          children: [
                            Icon(
                              Icons.car_repair_outlined,
                              color: Colors.black.withOpacity(0.8),
                              size: 30,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "View Parts",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomOnClickContainer(
                        onTap: viewAllServices,
                        defaultColor: Colors.white70,
                        clickedColor: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        child: Row(
                          children: [
                            Icon(
                              Icons.miscellaneous_services,
                              color: Colors.black.withOpacity(0.8),
                              size: 30,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "View Services",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
