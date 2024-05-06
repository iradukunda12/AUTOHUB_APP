import 'package:autohub/components/CustomOnClickContainer.dart';
import 'package:autohub/data_notifier/ServicesNotifier.dart';
import 'package:autohub/db_references/Category.dart';
import 'package:autohub/db_references/NotifierType.dart';
import 'package:autohub/operation/CategoryOperation.dart';
import 'package:autohub/pages/ViewPartsPage.dart';
import 'package:autohub/pages/ViewServicesPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../builders/ControlledStreamBuilder.dart';
import '../builders/CustomWrapListBuilder.dart';
import '../components/CustomCircularButton.dart';
import '../components/CustomProject.dart';
import '../data/CategoryData.dart';
import '../data_notifier/CategoryNotifier.dart';
import '../data_notifier/PartsNotifier.dart';
import '../main.dart';
import '../operation/AuthenticationOperation.dart';
import 'AddPartsPage.dart';
import 'AddServicePage.dart';

class ViewCategoryDataPage extends StatefulWidget {
  final Category categoryFor;
  final WidgetStateNotifier<List<CategoryData>> categoryNotifier;

  const ViewCategoryDataPage(
      {super.key, required this.categoryNotifier, required this.categoryFor});

  @override
  State<ViewCategoryDataPage> createState() => _ViewCategoryDataPageState();
}

class _ViewCategoryDataPageState extends State<ViewCategoryDataPage>
    implements CategoryImplement {
  RetryStreamListener retryStreamListener = RetryStreamListener();
  PaginationProgressController paginationProgressController =
      PaginationProgressController();

  @override
  BuildContext? getLatestContext() {
    return context;
  }

  @override
  PaginationProgressController? getPaginationProgressController() {
    return paginationProgressController;
  }

  @override
  RetryStreamListener? getRetryStreamListener() {
    return retryStreamListener;
  }

  @override
  void initState() {
    super.initState();
    CategoryNotifier().addImplements(this);
  }

  @override
  void dispose() {
    super.dispose();
    CategoryNotifier().removeImplements(this);
  }

  void performBackPressed() {
    Navigator.pop(context);
  }

  void viewCategory(CategoryData categoryData) {
    if (widget.categoryFor == Category.parts) {
      PartsNotifier? partsNotifier = CategoryNotifier()
          .getPartsNotifier(categoryData.categoryId, NotifierType.normal);
      if (partsNotifier != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewPartsPage(
                      partsNotifier: partsNotifier,
                    )));
      }
    } else if (widget.categoryFor == Category.services) {
      ServicesNotifier? servicesNotifier = CategoryNotifier()
          .getServicesNotifier(categoryData.categoryId, NotifierType.normal);
      if (servicesNotifier != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewServicesPage(
                      servicesNotifier: servicesNotifier,
                    )));
      }
    }
  }

  void addNewPart() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AddPartsPage()));
  }

  void addNewService() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AddServicePage()));
  }

  void goToNewAddition() {
    if (widget.categoryFor == Category.parts) {
      addNewPart();
    } else if (widget.categoryFor == Category.services) {
      addNewService();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                Expanded(
                  child: Text(
                    CategoryOperation().displayTheCategory(CategoryOperation()
                        .fowWhichIdentity[dbReference(widget.categoryFor)]),
                    textScaleFactor: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (AuthenticationOperation().thisUser != null)
                  CustomCircularButton(
                    imagePath: null,
                    iconColor: const Color(getMainBlueColor),
                    onPressed: goToNewAddition,
                    icon: Icons.add,
                    width: 40,
                    height: 40,
                    iconSize: 30,
                    mainAlignment: Alignment.center,
                    defaultBackgroundColor: Colors.transparent,
                    clickedBackgroundColor: Colors.white,
                  ),
              ]),
            ),
            const SizedBox(
              height: 8,
            ),

            Expanded(
              child: WidgetStateConsumer(
                  widgetStateNotifier: widget.categoryNotifier,
                  widgetStateBuilder: (context, snapshot) {
                    List<CategoryData>? categoryData = snapshot;

                    if (CategoryNotifier().getLatestData().isEmpty == true) {
                      if (snapshot?.isEmpty == true) {
                        return const Center(
                          child: Text(
                            "No category to show",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        );
                      }

                      if (snapshot == null) {
                        return Center(
                          child: progressBarWidget(),
                        );
                      }
                    } else {
                      categoryData = CategoryNotifier()
                          .getLatestData()
                          .where((element) =>
                              element.categoryFor ==
                                  dbReference(Category.all) ||
                              element.categoryFor ==
                                  dbReference(widget.categoryFor))
                          .toList();
                    }

                    return CustomWrapListBuilder(
                        // paginateSize: 20,
                        paginationProgressController:
                            paginationProgressController,
                        paginationProgressStyle: PaginationProgressStyle(
                            padding: const EdgeInsets.only(bottom: 50, top: 24),
                            useDefaultTimeOut: true,
                            progressMaxDuration: const Duration(seconds: 15),
                            scrollThreshold: 25),
                        itemCount: categoryData?.length,
                        alwaysPaginating: true,
                        retryStreamListener: retryStreamListener,
                        wrapEdgePosition: (edgePosition) {
                          if (edgePosition == WrapEdgePosition.normalBottom) {
                            retryStreamListener.controlRequestCall(
                                const Duration(seconds: 5), () {
                              CategoryNotifier().requestPaginate();
                            });
                          }
                        },
                        bottomPaginateWidget: const Icon(
                          Icons.add_circle_outline_sharp,
                          size: 50,
                          color: Color(getDarkGreyColor),
                        ),
                        paginationSizeChanged: (size, paginate) {},
                        wrapListBuilder: (context, index) {
                          CategoryData category = categoryData![index];

                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 18,
                                    right: 18,
                                    top: (index == 0) ? 0 : 16,
                                    bottom: (index + 1 == categoryData.length)
                                        ? 34
                                        : 0),
                                child: CustomOnClickContainer(
                                  onTap: () {
                                    viewCategory(category);
                                  },
                                  defaultColor: Colors.grey.shade200,
                                  clickedColor: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(16),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              CategoryOperation()
                                                  .displayTheCategory(category
                                                      .categoryIdentity),
                                              style: GoogleFonts.anton(
                                                color: Colors.black,
                                                fontSize: 28,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                CategoryOperation()
                                                    .displayTheCategory(
                                                        CategoryOperation()
                                                                .fowWhichIdentity[
                                                            category
                                                                .categoryFor]),
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.8),
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                  }),
            )
          ],
        ),
      ),
    );
  }
}
