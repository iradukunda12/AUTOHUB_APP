import 'package:autohub/components/CustomPrimaryButton.dart';
import 'package:autohub/components/EllipsisText.dart';
import 'package:autohub/data/PartsData.dart';
import 'package:autohub/main.dart';
import 'package:autohub/operation/CategoryOperation.dart';
import 'package:autohub/operation/PartsOperation.dart';
import 'package:autohub/pages/EditPartsPage.dart';
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
import '../data/UserProfileData.dart';
import '../data_notifier/CategoryNotifier.dart';
import '../data_notifier/UserProfileNotifier.dart';
import '../db_references/NotifierType.dart';
import '../handler/MediaHandler.dart';
import '../operation/AuthenticationOperation.dart';
import 'CheckPostMediaPage.dart';

class PartExtendedPage extends StatefulWidget {
  final PartsData partsData;
  final UserProfileNotifier? userAddedProfileNotifier;
  final UserProfileNotifier? userEditedProfileNotifier;

  const PartExtendedPage({
    Key? key,
    required this.partsData,
    required this.userAddedProfileNotifier,
    required this.userEditedProfileNotifier,
  });

  @override
  State<PartExtendedPage> createState() => _PartExtendedPageState();
}

class _PartExtendedPageState extends State<PartExtendedPage> {
  PageController controller = PageController();

  WidgetStateNotifier<int> quantityNotifier =
      WidgetStateNotifier(currentValue: 1);

  void performBackPressed() {
    Navigator.pop(context);
  }

  void tappedOnMediaAt(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckPostMediaPage(
          media: widget.partsData.partsMedia,
          startAt: index,
        ),
      ),
    );
  }

  void removeQuantity() {
    quantityNotifier.sendNewState((quantityNotifier.currentValue ?? 2) - 1);
  }

  void addQuantity() {
    quantityNotifier.sendNewState((quantityNotifier.currentValue ?? 0) + 1);
  }

  void onTapMessage(UserProfileData data) {
    String? countryCodeText = data.phoneCode;
    String? numberText = data.phone;
    int quantity = quantityNotifier.currentValue ?? 1;
    String messageBody = """
I want to buy $quantity *${widget.partsData.partsIdentity + ((quantity > 1) ? "(s)" : "")}* for a specific purpose or project. I believe it will greatly benefit me. 

Total amount: ${widget.partsData.partsCurrency} ${widget.partsData.partsPrice * quantity}

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
        builder: (context) => EditPartsPage(partsData: widget.partsData),
      ),
    );
  }

  void deleteServices() {
    openDialog(
      context,
      color: Colors.grey.shade200,
      const Text(
        "Parts Deletion",
        style: TextStyle(color: Colors.red, fontSize: 17),
      ),
      Text(
          "Are you sure you want to delete ${widget.partsData.partsIdentity} part?"),
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

    final mediaDeletion = widget.partsData.partsMedia
        .asMap()
        .map((key, value) {
          return MapEntry(
              key,
              CategoryOperation().deletePostMedia(
                  widget.partsData.partsId,
                  CategoryOperation().getMediaIndex(value.mediaData),
                  value.mediaType == MediaType.image ? "image" : "video"));
        })
        .values
        .toList();

    final deleteOperation = Future.wait(mediaDeletion);

    final serviceDeletion =
        PartsOperation().deleteAPart(widget.partsData.partsId);

    final operation = Future.wait<dynamic>([deleteOperation, serviceDeletion]);
    operation.then((value) {
      CategoryNotifier()
          .getPartsNotifier(
              widget.partsData.partsCategoryId, NotifierType.normal)
          ?.deleteTheParts(widget.partsData.partsId);
      closeCustomProgressBar(context);
      Navigator.pop(context);
      showToastMobile(msg: "Deleted the part");
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
              child: Row(
                children: [
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
                      "Parts Details",
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
                ],
              ),
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
                          widget.partsData.partsMedia.isNotEmpty
                              ? ExpandablePageView(
                                  autoScroll: true,
                                  autoScrollDelay: const Duration(seconds: 5),
                                  pageController: controller,
                                  epViews: [
                                    for (int index = 0;
                                        index <
                                            widget.partsData.partsMedia.length;
                                        index++)
                                      EPView(
                                          crossDimension: EPDimension.match,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: CustomOnClickContainer(
                                              defaultColor: Colors.transparent,
                                              clickedColor: Colors.transparent,
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
                                                                      media: widget
                                                                              .partsData
                                                                              .partsMedia[
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
                                  ],
                                )
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
                          if (widget.partsData.partsMedia.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: SmoothPageIndicator(
                                  controller: controller,
                                  count: widget.partsData.partsMedia.length),
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
                                    widget.partsData.partsIdentity,
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
                                    text: widget.partsData.partsDescription,
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
                                          color: Colors.black.withOpacity(0.7),
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
                            },
                          ),

                          // Currency and Price
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${widget.partsData.partsCurrency} ${CategoryOperation().formatNumber(double.parse(widget.partsData.partsPrice))}",
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
                    child: MultiWidgetStateConsumer(
                      widgetStateListNotifiers: [
                        quantityNotifier,
                        widget.userAddedProfileNotifier?.state ??
                            WidgetStateNotifier()
                      ],
                      widgetStateListBuilder: (context) {
                        final data = (widget.userAddedProfileNotifier?.state ??
                                WidgetStateNotifier())
                            .currentValue;
                        final quantity = quantityNotifier.currentValue;
                        if (data == null) return const SizedBox();
                        return Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16),
                            child: Row(
                              children: [
                                CustomOnClickContainer(
                                  onTap: addQuantity,
                                  defaultColor: Colors.transparent,
                                  clickedColor: Colors.grey.shade200,
                                  padding: const EdgeInsets.all(8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(getMainBlueColor)),
                                  child: const Center(
                                      child: Icon(
                                    Icons.add,
                                    size: 32,
                                  )),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Text(
                                  "$quantity",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                CustomOnClickContainer(
                                  onTap: () {
                                    if ((quantity ?? 1) > 1) {
                                      removeQuantity();
                                    }
                                  },
                                  defaultColor: Colors.transparent,
                                  clickedColor: Colors.grey.shade200,
                                  padding: const EdgeInsets.all(8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: ((quantity ?? 1) > 1)
                                          ? const Color(getMainBlueColor)
                                          : Colors.red),
                                  child: Center(
                                    child: Icon(
                                      ((quantity ?? 1) > 1)
                                          ? Icons.remove
                                          : Icons.not_interested,
                                      size: 32,
                                      color: ((quantity ?? 1) > 1)
                                          ? null
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: CustomPrimaryButton(
                                      buttonText: "Message",
                                      onTap: () {
                                        onTapMessage(data);
                                      }),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
