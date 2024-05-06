import 'package:autohub/collections/common_collection/ResourceCollection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/CustomProject.dart';
import '../components/CustomOnClickContainer.dart';
import '../data_notifier/CategoryNotifier.dart';
import '../db_references/Category.dart';
import '../operation/AuthenticationOperation.dart';
import '../pages/ViewCategoryDataPage.dart';

class UserProfileDrawer extends StatelessWidget {
  const UserProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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

    void onLogUserOut() {
      AuthenticationOperation().signOut(context);
    }

    return Drawer(
        backgroundColor: Colors.white,
        width: getScreenWidth(context) - (getScreenWidth(context) * 0.2),
        child: SafeArea(
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
                      onTap: onLogUserOut,
                      defaultColor: Colors.transparent,
                      clickedColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          ResourceCollection.autoHubImage,
                          height: 50,
                        )),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "AUTOHUB",
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.anton(color: Colors.black, fontSize: 36),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [Expanded(child: Divider())],
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
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
          ),
        ));
  }
}
