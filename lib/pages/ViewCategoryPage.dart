import 'package:autohub/components/EllipsisText.dart';
import 'package:autohub/db_references/NotifierType.dart';
import 'package:autohub/operation/CategoryOperation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../builders/ControlledStreamBuilder.dart';
import '../builders/CustomWrapListBuilder.dart';
import '../components/CustomCircularButton.dart';
import '../components/CustomProject.dart';
import '../data/CategoryData.dart';
import '../data_notifier/CategoryNotifier.dart';
import '../main.dart';
import '../operation/AuthenticationOperation.dart';
import 'AddCategoryPage.dart';
import 'EditCategoryPage.dart';

class ViewCategoryPage extends StatefulWidget {
  final WidgetStateNotifier<List<CategoryData>> categoryNotifier;

  const ViewCategoryPage({super.key, required this.categoryNotifier});

  @override
  State<ViewCategoryPage> createState() => _ViewCategoryPageState();
}

class _ViewCategoryPageState extends State<ViewCategoryPage>
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

  void deleteCategory(CategoryData categoryData) {
    openDialog(
      context,
      color: Colors.grey.shade200,
      const Text(
        "Category Deletion",
        style: TextStyle(color: Colors.red, fontSize: 17),
      ),
      Text(
          "Doing this is risky and you cannot recover the data for any sub data under this category.\n\nAre you sure you want to delete ${categoryData.categoryIdentity} category?"),
      [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold))),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirmDeleteCategory(categoryData);
            },
            child: const Text("Yes",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold))),
      ],
    );
  }

  void onConfirmDeleteCategory(CategoryData categoryData) {
    showCustomProgressBar(context);
    CategoryOperation().deleteCategory(categoryData.categoryId).then((value) {
      CategoryNotifier().removeThisCategory(categoryData);
      closeCustomProgressBar(context);
      showToastMobile(msg: "Deleted the category");
    }).onError((error, stackTrace) {
      closeCustomProgressBar(context);
      showDebug(msg: "$error $stackTrace");
      showDebug(msg: "An error occurred");
    });
  }

  void editCategory(CategoryData categoryData) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditCategoryPage(
                  categoryData: categoryData,
                )));
  }

  void goToNewCategory() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AddCategoryPage()));
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
                const Expanded(
                  child: Text(
                    "Categories",
                    textScaleFactor: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                CustomCircularButton(
                  imagePath: null,
                  iconColor: const Color(getMainBlueColor),
                  onPressed: goToNewCategory,
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
                      categoryData = CategoryNotifier().getLatestData();
                    }

                    return CustomWrapListBuilder(
                        paginateSize: 5,
                        paginationProgressController:
                            paginationProgressController,
                        paginationProgressStyle: PaginationProgressStyle(
                            padding: const EdgeInsets.only(bottom: 50),
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
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(16)),
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
                                          if (AuthenticationOperation()
                                                  .thisUser !=
                                              null)
                                            Row(
                                              children: [
                                                CustomCircularButton(
                                                  imagePath: null,
                                                  iconColor: Colors.red,
                                                  onPressed: () {
                                                    deleteCategory(category);
                                                  },
                                                  icon: Icons.delete,
                                                  width: 34,
                                                  height: 34,
                                                  iconSize: 26,
                                                  mainAlignment:
                                                      Alignment.center,
                                                  defaultBackgroundColor:
                                                      Colors.transparent,
                                                  clickedBackgroundColor:
                                                      Colors.white,
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                CustomCircularButton(
                                                  imagePath: null,
                                                  iconColor: Colors.green,
                                                  onPressed: () {
                                                    editCategory(category);
                                                  },
                                                  icon: Icons.edit,
                                                  width: 34,
                                                  height: 34,
                                                  iconSize: 26,
                                                  mainAlignment:
                                                      Alignment.center,
                                                  defaultBackgroundColor:
                                                      Colors.transparent,
                                                  clickedBackgroundColor:
                                                      Colors.white,
                                                ),
                                              ],
                                            )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      EllipsisText(
                                          text: category.categoryDescription,
                                          maxLength: 150,
                                          textStyle: TextStyle(
                                              color: Colors.black
                                                  .withOpacity(0.7))),
                                      const SizedBox(
                                        height: 24,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: WidgetStateConsumer(
                                                widgetStateNotifier: CategoryNotifier()
                                                        .getPostProfileNotifier(
                                                            category
                                                                .categoryCreatedBy,
                                                            NotifierType.normal)
                                                        ?.state ??
                                                    WidgetStateNotifier(),
                                                widgetStateBuilder:
                                                    (context, data) {
                                                  if (data == null)
                                                    return const SizedBox();
                                                  return Row(
                                                    children: [
                                                      Flexible(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.7),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 4,
                                                                    horizontal:
                                                                        6),
                                                            child: Text(
                                                              data.fullName,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                          ),
                                          const SizedBox(
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
                                      )
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
