import 'package:autohub/data/CategoryData.dart';
import 'package:autohub/data_notifier/CategoryNotifier.dart';
import 'package:autohub/data_notifier/ServicesNotifier.dart';
import 'package:autohub/db_references/NotifierType.dart';
import 'package:autohub/handler/ServicesHandler.dart';
import 'package:flutter/material.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../builders/ControlledStreamBuilder.dart';
import '../builders/CustomWrapListBuilder.dart';
import '../components/CustomButtonRefreshCard.dart';
import '../components/CustomProject.dart';
import '../main.dart';

class ServicesPage extends StatefulWidget {
  final RetryStreamListener retryStreamListener;
  final WidgetStateNotifier<List<CategoryData>> categoryNotifier;

  const ServicesPage(
      {super.key,
      required this.categoryNotifier,
      required this.retryStreamListener});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  Widget build(BuildContext context) {
    return WidgetStateConsumer(
        widgetStateNotifier: widget.categoryNotifier,
        widgetStateBuilder: (context, snapshot) {
          List<CategoryData>? categoryData = snapshot;

          if (categoryData?.isEmpty == true) {
            return Center(
                child: CustomButtonRefreshCard(
                    topIcon: const Icon(
                      Icons.not_interested,
                      size: 50,
                    ),
                    retryStreamListener: widget.retryStreamListener,
                    displayText: "There are no services yet."));
          }
          if (snapshot == null) {
            return SizedBox(
                height: getScreenHeight(context) * 0.5,
                child: Center(
                  child: progressBarWidget(),
                ));
          }
          // else {

          // }

          return CustomWrapListBuilder(
              paginateSize: 10,
              sliver: true,
              // paginationProgressController: paginationProgressController,
              paginationProgressStyle: PaginationProgressStyle(
                  padding: const EdgeInsets.only(bottom: 50),
                  useDefaultTimeOut: true,
                  progressMaxDuration: const Duration(seconds: 15),
                  scrollThreshold: 25),
              itemCount: categoryData?.length,
              alwaysPaginating: true,
              retryStreamListener: widget.retryStreamListener,
              wrapEdgePosition: (edgePosition) {
                if (edgePosition == WrapEdgePosition.normalBottom) {
                  widget.retryStreamListener
                      .controlRequestCall(const Duration(seconds: 5), () {
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

                ServicesNotifier? servicesNotifier = CategoryNotifier()
                    .getServicesNotifier(
                        category.categoryId, NotifierType.normal);

                bool showCategory = servicesNotifier != null;

                return Column(
                  children: [
                    if (showCategory)
                      ServicesHandler(
                        category: category.categoryIdentity,
                        servicesDataStateNotifier: servicesNotifier.state,
                        servicesNotifier: servicesNotifier,
                      ),
                    if (index + 1 == categoryData.length && showCategory)
                      const SizedBox(
                        height: 25,
                      ),
                  ],
                );
              });
        });
  }
}
