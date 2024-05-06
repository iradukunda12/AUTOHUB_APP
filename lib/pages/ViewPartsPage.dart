import 'package:autohub/components/PartWidget.dart';
import 'package:autohub/data/PartsData.dart';
import 'package:autohub/data_notifier/PartsNotifier.dart';
import 'package:autohub/db_references/NotifierType.dart';
import 'package:autohub/pages/AddPartsPage.dart';
import 'package:flutter/material.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../builders/ControlledStreamBuilder.dart';
import '../builders/CustomWrapListBuilder.dart';
import '../components/CustomCircularButton.dart';
import '../components/CustomProject.dart';
import '../data_notifier/CategoryNotifier.dart';
import '../data_notifier/UserProfileNotifier.dart';
import '../main.dart';
import '../operation/AuthenticationOperation.dart';
import 'PartExtendedPage.dart';

class ViewPartsPage extends StatefulWidget {
  final PartsNotifier partsNotifier;

  const ViewPartsPage({super.key, required this.partsNotifier});

  @override
  State<ViewPartsPage> createState() => _ViewPartsPageState();
}

class _ViewPartsPageState extends State<ViewPartsPage>
    implements PartsImplement {
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
    widget.partsNotifier.addImplements(this);
  }

  @override
  void dispose() {
    super.dispose();
    widget.partsNotifier.removeImplements(this);
  }

  void performBackPressed() {
    Navigator.pop(context);
  }

  void goToNewParts() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AddPartsPage()));
  }

  void checkThePartData(PartsData partsData) {
    UserProfileNotifier? userAddedProfileNotifier = widget.partsNotifier
        .getPostProfileNotifier(partsData.partsAddedBy, NotifierType.normal);
    UserProfileNotifier? userEditedProfileNotifier = widget.partsNotifier
        .getPostProfileNotifier(
            partsData.partsEditedBy ?? '', NotifierType.normal);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PartExtendedPage(
                  partsData: partsData,
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
                    "All Parts",
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
                    widgetStateNotifier: widget.partsNotifier.state,
                    widgetStateBuilder: (context, snapshot) {
                      List<List<PartsData>?> partsDataList =
                          createSubgroups(snapshot ?? [], 2);

                      if (widget.partsNotifier.getLatestData().isEmpty ==
                          true) {
                        if (snapshot?.isEmpty == true) {
                          return const Center(
                            child: Text(
                              "No parts to show",
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
                        partsDataList = createSubgroups(
                            widget.partsNotifier.getLatestData(), 2);
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
                          itemCount: partsDataList.length,
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
                            final view = partsDataList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  for (int position = 0;
                                      position < (view?.length ?? 0);
                                      position++)
                                    Expanded(
                                      child: Builder(builder: (context) {
                                        PartsData partsData = view![position];

                                        UserProfileNotifier?
                                            userAddedProfileNotifier = widget
                                                .partsNotifier
                                                .getPostProfileNotifier(
                                                    view[position].partsAddedBy,
                                                    NotifierType.normal);
                                        UserProfileNotifier?
                                            userEditedProfileNotifier = widget
                                                .partsNotifier
                                                .getPostProfileNotifier(
                                                    view[position]
                                                            .partsEditedBy ??
                                                        '',
                                                    NotifierType.normal);

                                        return PartWidget(
                                            partData: partsData,
                                            onTap: () {
                                              checkThePartData(partsData);
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
