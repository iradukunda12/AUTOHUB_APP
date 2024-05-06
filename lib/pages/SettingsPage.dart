import 'package:flutter/material.dart';

import '../../collections/common_collection/GeneralSettingCollection.dart';
import '../../collections/common_collection/NotificationSettingCollection.dart';
import '../../collections/common_collection/SocialSettingCollection.dart';
import '../../components/CustomCircularButton.dart';
import '../../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  void performBackPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Builder(builder: (context) {
          return Column(
            children: [
              // Back Button
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(children: [
                  CustomCircularButton(
                    imagePath: null,
                    iconColor: Colors.black,
                    onPressed: performBackPressed,
                    icon: Icons.arrow_back,
                    width: 40,
                    height: 40,
                    iconSize: 30,
                    mainAlignment: Alignment.center,
                    defaultBackgroundColor: Colors.transparent,
                    clickedBackgroundColor: Colors.white,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Expanded(
                    child: Text(
                      "Settings",
                      textScaleFactor: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
              ),

              const SizedBox(
                height: 8,
              ),

              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //   Notification Setting Collection
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: NotificationSettingCollection(),
                      ),

                      //   Social Setting Collection
                      SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          Expanded(child: SocialSettingCollection()),
                        ],
                      ),

                      // // Language Title
                      // const SizedBox(
                      //   height: 16,
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 24),
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         "Language",
                      //         style: TextStyle(
                      //             color: Color(getDarkGreyColor),
                      //             fontSize: 15,
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      //
                      // //   Language Setting Collection
                      // const SizedBox(
                      //   height: 8,
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 24),
                      //   child: LanguageSettingCollection(),
                      // ),

                      // General Title
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Text(
                              "General",
                              style: TextStyle(
                                  color: Color(getDarkGreyColor),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      //   General Setting Collection
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: GeneralSettingCollection(),
                      ),

                      // Space
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
