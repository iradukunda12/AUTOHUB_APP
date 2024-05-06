import 'package:autohub/data_notifier/ServicesNotifier.dart';
import 'package:autohub/db_references/NotifierType.dart';
import 'package:autohub/operation/AuthenticationOperation.dart';
import 'package:autohub/pages/AddPartsPage.dart';
import 'package:flutter/material.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../builders/ControlledStreamBuilder.dart';
import '../builders/CustomWrapListBuilder.dart';
import '../components/CustomCircularButton.dart';
import '../components/CustomProject.dart';
import '../components/ServiceWidget.dart';
import '../data/ServicesData.dart';
import '../data_notifier/CategoryNotifier.dart';
import '../data_notifier/UserProfileNotifier.dart';
import '../main.dart';
import 'ServiceExtendedPage.dart';

class ViewServicesPage extends StatefulWidget {
  final ServicesNotifier servicesNotifier;

  const ViewServicesPage({super.key, required this.servicesNotifier});

  @override
  State<ViewServicesPage> createState() => _ViewServicesPageState();
}

class _ViewServicesPageState extends State<ViewServicesPage>
    implements ServicesImplement {
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
    widget.servicesNotifier.addImplements(this);
  }

  @override
  void dispose() {
    super.dispose();
    widget.servicesNotifier.removeImplements(this);
  }

  void performBackPressed() {
    Navigator.pop(context);
  }

  void goToNewParts() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AddPartsPage()));
  }

  void checkTheServiceData(ServicesData servicesData) {
    UserProfileNotifier? userAddedProfileNotifier = widget.servicesNotifier
        .getPostProfileNotifier(
            servicesData.servicesAddedBy, NotifierType.normal);
    UserProfileNotifier? userEditedProfileNotifier = widget.servicesNotifier
        .getPostProfileNotifier(
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
                    "All Services",
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
                    onPressed: goToNewParts,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: WidgetStateConsumer(
                    widgetStateNotifier: widget.servicesNotifier.state,
                    widgetStateBuilder: (context, snapshot) {
                      List<List<ServicesData>?> servicesDataList =
                          createSubgroups(snapshot ?? [], 2);

                      if (widget.servicesNotifier.getLatestData().isEmpty ==
                          true) {
                        if (snapshot?.isEmpty == true) {
                          return const Center(
                            child: Text(
                              "No service to show",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          );
                        }

                        if (snapshot == null) {
                          return Center(
                            child: progressBarWidget(),
                          );
                        }
                      } else {
                        servicesDataList = createSubgroups(
                            widget.servicesNotifier.getLatestData(), 2);
                      }

                      return CustomWrapListBuilder(
                          paginateSize: 5,
                          paginationProgressController:
                              paginationProgressController,
                          paginationProgressStyle: PaginationProgressStyle(
                              padding:
                                  const EdgeInsets.only(bottom: 50, top: 24),
                              useDefaultTimeOut: true,
                              progressMaxDuration: const Duration(seconds: 15),
                              scrollThreshold: 25),
                          itemCount: servicesDataList.length,
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
                            final view = servicesDataList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  for (int position = 0;
                                      position < (view?.length ?? 0);
                                      position++)
                                    Expanded(
                                      child: Builder(builder: (context) {
                                        ServicesData servicesData =
                                            view![position];

                                        UserProfileNotifier?
                                            userAddedProfileNotifier = widget
                                                .servicesNotifier
                                                .getPostProfileNotifier(
                                                    view[position]
                                                        .servicesAddedBy,
                                                    NotifierType.normal);
                                        UserProfileNotifier?
                                            userEditedProfileNotifier = widget
                                                .servicesNotifier
                                                .getPostProfileNotifier(
                                                    view[position]
                                                            .servicesEditedBy ??
                                                        '',
                                                    NotifierType.normal);

                                        return ServiceWidget(
                                            serviceData: servicesData,
                                            onTap: () {
                                              checkTheServiceData(servicesData);
                                            },
                                            userAddedProfileNotifier:
                                                userAddedProfileNotifier,
                                            userEditedProfileNotifier:
                                                userEditedProfileNotifier);
                                      }),
                                    ),
                                  if (view?.length == 1)
                                    const Expanded(child: SizedBox()),
                                ],
                              ),
                            );
                          });
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
