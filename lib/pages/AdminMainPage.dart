import 'package:autohub/builders/ControlledStreamBuilder.dart';
import 'package:autohub/pages/AddServicePage.dart';
import 'package:autohub/pages/AppWrapper.dart';
import 'package:autohub/pages/ServicesPage.dart';
import 'package:autohub/services/UserProfileService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../builders/CustomWrapListBuilder.dart';
import '../collections/common_collection/ProfileImage.dart';
import '../components/CustomOnClickContainer.dart';
import '../components/CustomProject.dart';
import '../components/WrappingSilverAppBar.dart';
import '../data/TabData.dart';
import '../data/UserData.dart';
import '../data_notifier/CategoryNotifier.dart';
import '../data_notifier/ProfileNotifier.dart';
import '../db_references/Members.dart';
import '../drawer/AdminProfileDrawer.dart';
import '../main.dart';
import '../operation/MembersOperation.dart';
import 'AddCategoryPage.dart';
import 'AddPartsPage.dart';
import 'PartsPages.dart';
import 'SearchedPage.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage>
    implements ProfileImplement, CategoryImplement {
  ProfileStack profileStack = ProfileStack();

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

  @override
  void initState() {
    super.initState();
    UserProfileService().beginService();
    ProfileNotifier().start(this, profileStack);
    CategoryNotifier().start(this);
    handleRestriction();
  }

  void handleRestriction() async {
    final restricted = await MembersOperation()
        .getUserRecord(field: dbReference(Members.restricted));

    if (restricted == true) {
      UserProfileService().handleRestriction(true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    UserProfileService().endService();
    ProfileNotifier().stop(profileStack);
    CategoryNotifier().stop();
  }

  void openSearchPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SearchedPage()));
  }

  void openNavigationBar(BuildContext scaffoldContext) {
    Scaffold.of(scaffoldContext).openDrawer();
  }

  void messageButtonClicked() {}

  void addNewPart() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AddPartsPage()));
  }

  void addNewService() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AddServicePage()));
  }

  void addNewCategory() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AddCategoryPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AdminProfileDrawer(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        child: SpeedDial(
          icon: Icons.menu,
          activeIcon: Icons.close,
          backgroundColor: Color(getMainBlueColor),
          foregroundColor: Colors.white,
          spacing: 12,
          spaceBetweenChildren: 8,
          childMargin: const EdgeInsets.symmetric(horizontal: 16),
          overlayColor: Colors.black,
          overlayOpacity: 0.9,
          children: [
            SpeedDialChild(
                onTap: addNewPart,
                child: const Icon(Icons.car_repair_outlined),
                label: "New Part",
                labelShadow: [],
                labelBackgroundColor: Colors.transparent,
                labelStyle: const TextStyle(fontSize: 20, color: Colors.white)),
            SpeedDialChild(
                onTap: addNewService,
                child: const Icon(Icons.miscellaneous_services),
                label: "New Service",
                labelShadow: [],
                labelBackgroundColor: Colors.transparent,
                labelStyle: const TextStyle(fontSize: 20, color: Colors.white)),
            SpeedDialChild(
                onTap: addNewCategory,
                child: const Icon(Icons.category),
                label: "New Category",
                labelShadow: [],
                labelBackgroundColor: Colors.transparent,
                labelStyle: const TextStyle(fontSize: 20, color: Colors.white)),
          ],
        ),
      ),
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
                                CustomOnClickContainer(
                                  onTap: () {
                                    openNavigationBar(context);
                                  },
                                  defaultColor: Colors.grey.shade200,
                                  clickedColor: Colors.grey.shade300,
                                  height: 45,
                                  width: 45,
                                  clipBehavior: Clip.hardEdge,
                                  shape: BoxShape.circle,
                                  child: WidgetStateConsumer(
                                      widgetStateNotifier:
                                          ProfileNotifier().state,
                                      widgetStateBuilder: (context, snapshot) {
                                        UserData? userData = snapshot;
                                        return ProfileImage(
                                          iconSize: 45,
                                          imageUrl: (imageAddress) {},
                                          imageUri: MembersOperation()
                                              .getMemberProfileBucketPath(
                                                  snapshot?.userId ?? '',
                                                  snapshot?.profileIndex),
                                          fullName:
                                              snapshot?.fullName ?? "Error",
                                        );
                                      }),
                                ),

                                const SizedBox(
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
                                              const SizedBox(
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

                                // // Message
                                // CustomCircularButton(
                                //   imagePath: null,
                                //   mainAlignment: Alignment.center,
                                //   iconColor: Color(getDarkGreyColor),
                                //   onPressed: messageButtonClicked,
                                //   icon: Icons.message,
                                //   gap: 8,
                                //   width: 45,
                                //   height: 45,
                                //   iconSize: 35,
                                //   defaultBackgroundColor: Colors.transparent,
                                //   colorImage: true,
                                //   showShadow: false,
                                //   clickedBackgroundColor:
                                //   const Color(getDarkGreyColor)
                                //       .withOpacity(0.4),
                                // ),
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
                      backgroundColor: Colors.grey.shade50,
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
