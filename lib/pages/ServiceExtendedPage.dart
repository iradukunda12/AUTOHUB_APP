import 'package:autohub/components/CustomPrimaryButton.dart';
import 'package:autohub/components/EllipsisText.dart';
import 'package:autohub/data/ServicesData.dart';
import 'package:autohub/data/UserProfileData.dart';
import 'package:autohub/data_notifier/CategoryNotifier.dart';
import 'package:autohub/db_references/NotifierType.dart';
import 'package:autohub/operation/CategoryOperation.dart';
import 'package:autohub/operation/ServicesOperation.dart';
import 'package:autohub/pages/EditServicePage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../components/CustomCircularButton.dart';
import '../components/CustomOnClickContainer.dart';
import '../components/CustomProject.dart';
import '../components/ExpandedPageView.dart';
import '../data/MediaData.dart';
import '../data_notifier/UserProfileNotifier.dart';
import '../handler/MediaHandler.dart';
import '../operation/AuthenticationOperation.dart';
import 'CheckPostMediaPage.dart';

class ServiceExtendedPage extends StatefulWidget {
  final ServicesData servicesData;
  final UserProfileNotifier? userAddedProfileNotifier;
  final UserProfileNotifier? userEditedProfileNotifier;

  const ServiceExtendedPage(
      {super.key,
      required this.servicesData,
      required this.userAddedProfileNotifier,
      required this.userEditedProfileNotifier});

  @override
  State<ServiceExtendedPage> createState() => _ServiceExtendedPageState();
}

class _ServiceExtendedPageState extends State<ServiceExtendedPage> {
  PageController controller = PageController();

  void performBackPressed() {
    Navigator.pop(context);
  }

  void tappedOnMediaAt(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CheckPostMediaPage(
                  media: widget.servicesData.servicesMedia,
                  startAt: index,
                )));
  }

  void onTapMessage(UserProfileData data) {
    String? countryCodeText = data.phoneCode;
    String? numberText = data.phone;

    String messageBody = """
I am looking to avail of this service - *${widget.servicesData.servicesIdentity}* for a specific purpose or project. I believe it will greatly benefit me. Could you please discuss more on this?

Total amount: ${widget.servicesData.servicesCurrency} ${widget.servicesData.servicesPrice}

Thank you!
""";

    if (countryCodeText != null && numberText != null) {
      var whatsappUrl =
          Uri.parse("whatsapp://send?phone=${countryCodeText + numberText}"
              "&text=${Uri.encodeComponent(messageBody)}");
      try {
        launchUrl(whatsappUrl);
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      showToastMobile(msg: "An error has occurred");
    }
  }

  void goToEditPage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditServicePage(servicesData: widget.servicesData)));
  }

  void deleteServices() {
    openDialog(
      context,
      color: Colors.grey.shade200,
      const Text(
        "Service Deletion",
        style: TextStyle(color: Colors.red, fontSize: 17),
      ),
      Text(
          "Are you sure you want to delete ${widget.servicesData.servicesIdentity} service?"),
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
              onConfirmDelete();
            },
            child: const Text("Yes",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold))),
      ],
    );
  }

  void onConfirmDelete() {
    showCustomProgressBar(context);

    final mediaDeletion = widget.servicesData.servicesMedia
        .asMap()
        .map((key, value) {
          return MapEntry(
              key,
              CategoryOperation().deletePostMedia(
                  widget.servicesData.servicesId,
                  CategoryOperation().getMediaIndex(value.mediaData),
                  value.mediaType == MediaType.image ? "image" : "video"));
        })
        .values
        .toList();

    final deleteOperation = Future.wait(mediaDeletion);

    final serviceDeletion =
        ServicesOperation().deleteAService(widget.servicesData.servicesId);

    final operation = Future.wait<dynamic>([deleteOperation, serviceDeletion]);
    operation.then((value) {
      CategoryNotifier()
          .getServicesNotifier(
              widget.servicesData.servicesCategoryId, NotifierType.normal)
          ?.deleteTheServices(widget.servicesData.servicesId);
      closeCustomProgressBar(context);
      Navigator.pop(context);
      showToastMobile(msg: "Deleted the service");
    }).onError((error, stackTrace) {
      closeCustomProgressBar(context);
      showDebug(msg: "$error $stackTrace");
      showToastMobile(msg: "An error occurred");
    });
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
                    "Service Details",
                    textScaleFactor: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (AuthenticationOperation().thisUser != null)
                  Row(
                    children: [
                      CustomCircularButton(
                        imagePath: null,
                        iconColor: Colors.red,
                        onPressed: deleteServices,
                        icon: Icons.delete,
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
                      CustomCircularButton(
                        imagePath: null,
                        iconColor: Colors.green,
                        onPressed: goToEditPage,
                        icon: Icons.edit,
                        width: 40,
                        height: 40,
                        iconSize: 30,
                        mainAlignment: Alignment.center,
                        defaultBackgroundColor: Colors.transparent,
                        clickedBackgroundColor: Colors.white,
                      ),
                    ],
                  )
              ]),
            ),
            const SizedBox(
              height: 8,
            ),

            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          widget.servicesData.servicesMedia.isNotEmpty
                              ? ExpandablePageView(
                                  autoScroll: true,
                                  autoScrollDelay: const Duration(seconds: 5),
                                  pageController: controller,
                                  epViews: [
                                      for (int index = 0;
                                          index <
                                              widget.servicesData.servicesMedia
                                                  .length;
                                          index++)
                                        EPView(
                                            crossDimension: EPDimension.match,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: CustomOnClickContainer(
                                                defaultColor:
                                                    Colors.transparent,
                                                clickedColor:
                                                    Colors.transparent,
                                                clipBehavior: Clip.antiAlias,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: SizedBox(
                                                  height:
                                                      getScreenWidth(context) -
                                                          (16 * 2),
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                child:
                                                                    MediaHandler(
                                                                        media: widget.servicesData.servicesMedia[
                                                                            index],
                                                                        clicked:
                                                                            () {
                                                                          tappedOnMediaAt(
                                                                              index);
                                                                        })),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ))
                                    ])
                              : SizedBox(
                                  height: getScreenWidth(context) - (16 * 2),
                                  child: Center(
                                    child: Icon(
                                      Icons.shopping_cart,
                                      size: 180,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                          if (widget.servicesData.servicesMedia.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: SmoothPageIndicator(
                                  controller: controller,
                                  count:
                                      widget.servicesData.servicesMedia.length),
                            ),

                          const SizedBox(
                            height: 16,
                          ),

                          // Identity
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.servicesData.servicesIdentity,
                                    style: GoogleFonts.anton(
                                      color: Colors.black,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Description
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: EllipsisText(
                                    text:
                                        widget.servicesData.servicesDescription,
                                    textStyle: TextStyle(
                                        fontSize: 16, color: Colors.grey[600]),
                                    maxLength: 100,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Added By
                          const SizedBox(
                            height: 24,
                          ),
                          WidgetStateConsumer(
                              widgetStateNotifier:
                                  widget.userAddedProfileNotifier?.state ??
                                      WidgetStateNotifier(currentValue: null),
                              widgetStateBuilder: (context, data) {
                                if (data == null) return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 6),
                                          child: Text(
                                            data.fullName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                          // Currency and Price
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${widget.servicesData.servicesCurrency} ${CategoryOperation().formatNumber(double.parse(widget.servicesData.servicesPrice))}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: WidgetStateConsumer(
                          widgetStateNotifier:
                              widget.userAddedProfileNotifier?.state ??
                                  WidgetStateNotifier(),
                          widgetStateBuilder: (context, data) {
                            if (data == null) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16),
                              child: Container(
                                color: Colors.white,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomPrimaryButton(
                                          buttonText: "Message",
                                          onTap: () {
                                            onTapMessage(data);
                                          }),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
