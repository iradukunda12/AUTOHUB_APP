import 'package:autohub/builders/CustomWrapListBuilder.dart';
import 'package:autohub/components/CustomProject.dart';
import 'package:autohub/drawer/UserProfileDrawer.dart';
import 'package:autohub/operation/CacheOperation.dart';
import 'package:autohub/pages/SearchedPage.dart';
import 'package:flutter/material.dart';

import '../builders/ControlledStreamBuilder.dart';
import '../components/CustomCircularButton.dart';
import '../components/CustomOnClickContainer.dart';
import '../components/WrappingSilverAppBar.dart';
import '../data/TabData.dart';
import '../data_notifier/CategoryNotifier.dart';
import '../db_references/Members.dart';
import '../main.dart';
import 'AppWrapper.dart';
import 'PartsPages.dart';
import 'ServicesPage.dart';
import 'SettingsPage.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage>
    implements CategoryImplement {
  RetryStreamListener categoryRetryStreamListener = RetryStreamListener();

  List<TabData> get allTabs => [
        TabData(const Tab(text: "Buy Parts"), allOrderTypes[0]),
        TabData(const Tab(text: "Services"), allOrderTypes[1]),
      ];

  List get allOrderTypes => [
        Column(
          children: [
            Expanded(
              child: PartsPage(
                categoryNotifier: CategoryNotifier().partsDataNotifier,
                retryStreamListener: categoryRetryStreamListener,
              ),
            )
          ],
        ),
        Column(
          children: [
            Expanded(
              child: ServicesPage(
                categoryNotifier: CategoryNotifier().servicesDataNotifier,
                retryStreamListener: categoryRetryStreamListener,
              ),
            )
          ],
        ),
      ];

  @override
  void initState() {
    super.initState();
    CategoryNotifier().start(this);
    saveUserType();
  }

  void saveUserType() async {
    await CacheOperation().saveCacheData(dbReference(Members.type),
        dbReference(Members.type_key), dbReference(Members.type_of_user));
  }

  @override
  BuildContext? getLatestContext() {
    return context;
  }

  @override
  PaginationProgressController? getPaginationProgressController() {
    return null;
  }

  @override
  RetryStreamListener? getRetryStreamListener() {
    return categoryRetryStreamListener;
  }

  void openSearchPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SearchedPage()));
  }

  void openNavigationBar(BuildContext scaffoldContext) {
    Scaffold.of(scaffoldContext).openDrawer();
  }

  void openSettings() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: UserProfileDrawer(),
      body: SafeArea(
        child: DefaultTabController(
          length: allTabs.length,
          child: AppWrapper(
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  WrappingSliverAppBar(
                      titleSpacing: 0,
                      elevation: 0,
                      snap: true,
                      floating: true,
                      forceMaterialTransparency: true,
                      title: Container(
                        color: Colors.white,
                        child: Column(children: [
                          // Top buttons
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 24, bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Menu
                                CustomCircularButton(
                                  imagePath: null,
                                  mainAlignment: Alignment.center,
                                  iconColor: Color(getDarkGreyColor),
                                  onPressed: () {
                                    openNavigationBar(context);
                                  },
                                  icon: Icons.menu,
                                  gap: 8,
                                  width: 45,
                                  height: 45,
                                  iconSize: 35,
                                  defaultBackgroundColor: Colors.transparent,
                                  colorImage: true,
                                  showShadow: false,
                                  clickedBackgroundColor:
                                      const Color(getDarkGreyColor)
                                          .withOpacity(0.4),
                                ),

                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: SizedBox(
                                      height: 40,
                                      child: CustomOnClickContainer(
                                        onTap: openSearchPage,
                                        defaultColor: Colors.transparent,
                                        clickedColor: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                            color: Colors.grey.shade500),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.search,
                                                size: 20,
                                                color: Colors.grey.shade700,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                "Search here",
                                                textScaler:
                                                    TextScaler.noScaling,
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    fontSize: 16),
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                ),

                                SizedBox(
                                  width: 8,
                                ),
                                // Settings
                                CustomCircularButton(
                                  imagePath: null,
                                  mainAlignment: Alignment.center,
                                  iconColor: Color(getDarkGreyColor),
                                  onPressed: openSettings,
                                  icon: Icons.settings,
                                  gap: 8,
                                  width: 45,
                                  height: 45,
                                  iconSize: 35,
                                  defaultBackgroundColor: Colors.transparent,
                                  colorImage: true,
                                  showShadow: false,
                                  clickedBackgroundColor:
                                      const Color(getDarkGreyColor)
                                          .withOpacity(0.4),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      )),
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                    sliver: WrappingSliverAppBar(
                      titleSpacing: 0,
                      pinned: true,
                      // backgroundColor: Colors.grey.shade50,
                      title: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey.shade400))),
                            child: TabBar(
                              labelColor: const Color(getMainBlueColor),
                              indicatorColor: const Color(getMainBlueColor),
                              unselectedLabelColor: Colors.grey.shade400,
                              isScrollable: false,
                              labelPadding: const EdgeInsets.only(left: 24),
                              tabs: [
                                // All tabs
                                for (var i = 0; i < allTabs.length; i++)
                                  allTabs[i].tab
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ];
              },
              body: TabBarView(children: [
                for (var i = 0; i < allTabs.length; i++) allTabs[i].tabView
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
