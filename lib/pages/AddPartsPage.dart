import 'dart:async';
import 'dart:io';

import 'package:autohub/components/CustomPrimaryButton.dart';
import 'package:autohub/components/CustomProject.dart';
import 'package:autohub/data/CategoryData.dart';
import 'package:autohub/data_notifier/CategoryNotifier.dart';
import 'package:autohub/db_references/NotifierType.dart';
import 'package:autohub/operation/CategoryOperation.dart';
import 'package:autohub/operation/PartsOperation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_compress/video_compress.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../collections/common_collection/CurrencyCollection.dart';
import '../components/CustomCircularButton.dart';
import '../components/CustomEditTextField.dart';
import '../components/CustomOnClickContainer.dart';
import '../components/CustomSelectDialogField.dart';
import '../data/CurrencyData.dart';
import '../data/MediaData.dart';
import '../db_references/Category.dart' as cat;
import '../db_references/Parts.dart';
import '../handler/MediaHandler.dart';
import '../supabase/SupabaseConfig.dart';
import 'AddCategoryPage.dart';
import 'CheckUploadPostMediaPage.dart';

class AddPartsPage extends StatefulWidget {
  const AddPartsPage({super.key});

  @override
  State<AddPartsPage> createState() => _AddPartsPageState();
}

class _AddPartsPageState extends State<AddPartsPage> {
  PageController controller = PageController();
  TextEditingController identityController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  WidgetStateNotifier<bool> identityNotifier =
      WidgetStateNotifier(currentValue: false);
  WidgetStateNotifier<bool> descriptionNotifier =
      WidgetStateNotifier(currentValue: false);
  WidgetStateNotifier<bool> priceNotifier =
      WidgetStateNotifier(currentValue: false);
  WidgetStateNotifier<CategoryData> categoryNotifier = WidgetStateNotifier();
  WidgetStateNotifier<String> currencyNotifier = WidgetStateNotifier();

  TextEditingController categorySearchController = TextEditingController();
  TextEditingController currencySearchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    identityNotifier.addController(identityController, (stateNotifier) {
      stateNotifier.sendNewState(identityController.text.isNotEmpty);
    });

    descriptionNotifier.addController(descriptionController, (stateNotifier) {
      stateNotifier.sendNewState(descriptionController.text.isNotEmpty);
    });

    priceNotifier.addController(priceController, (stateNotifier) {
      stateNotifier.sendNewState(priceController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    super.dispose();

    identityNotifier.removeController(disposeMethod: () {
      identityController.dispose();
    });
    descriptionNotifier.removeController(disposeMethod: () {
      descriptionController.dispose();
    });
    priceNotifier.removeController(disposeMethod: () {
      priceController.dispose();
    });

    categorySearchController.dispose();
    currencySearchController.dispose();
  }

  WidgetStateNotifier<List<MediaData?>> mediaNotifier =
      WidgetStateNotifier(currentValue: [null]);

  void performBackPressed() {
    Navigator.pop(context);
  }

  void onTapImage() async {
    Future<List<String?>?> picker = Platform.isIOS
        ? FilePicker.platform
            .pickFiles(type: FileType.image, allowMultiple: true)
            .then<List<String?>?>((value) => value?.paths)
        : ImagePicker()
            .pickMultiImage()
            .then<List<String?>?>((value) => value.map((e) => e.path).toList());

    picker.then((value) {
      List<MediaData?> media = [];
      final images =
          value?.map((e) => MediaData(MediaType.image, e ?? "")).toList();
      media.addAll(mediaNotifier.currentValue ?? []);
      media.addAll(images ?? []);
      if (images?.isNotEmpty == true) {
        startProgressPeriodForMedia();
      }
      mediaNotifier.sendNewState(rearrangeFiles(media));
    });
  }

  List<MediaData?> rearrangeFiles(List<MediaData?> media) {
    int found = media.indexWhere((element) => element == null);
    if (found != -1) {
      media.removeAt(found);
      media.add(null);
    }
    return media;
  }

  void onTapVideo() {
    Future<List<String?>?> picker = FilePicker.platform
        .pickFiles(type: FileType.video, allowMultiple: true)
        .then<List<String?>?>((value) => value?.paths);

    picker.then((value) {
      List<MediaData?> media = [];

      final videos =
          value?.map((e) => MediaData(MediaType.video, e ?? "")).toList();
      media.addAll(mediaNotifier.currentValue ?? []);
      media.addAll(videos ?? []);
      if (videos?.isNotEmpty == true) {
        startProgressPeriodForMedia();
      }
      mediaNotifier.sendNewState(rearrangeFiles(media));
    });
  }

  void removeMediaAt(int index) {
    mediaNotifier.currentValue?.removeAt(index);
    mediaNotifier.sendNewState(mediaNotifier.currentValue);
  }

  void tappedOnMediaAt(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CheckUploadPostMediaPage(
                  mediaSelectionNotifier: mediaNotifier,
                  startAt: index,
                )));
  }

  void startProgressPeriodForMedia() {
    showCustomProgressBar(context);
    Timer(const Duration(milliseconds: 1300), () {
      closeCustomProgressBar(context);
    });
  }

  void addNewCategory() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AddCategoryPage()));
  }

  Future<CategoryData?> openListOfCategory(BuildContext thisContext) async {
    CategoryData? selected;
    WidgetStateNotifier<String> searchNotifier = WidgetStateNotifier();
    WidgetStateNotifier<bool> categoryRefreshNotifier =
        WidgetStateNotifier(currentValue: false);
    String text = '';
    Timer? timer;
    categorySearchController.addListener(() {
      String newText = categorySearchController.text.trim();

      if (text != newText) {
        searchNotifier.sendNewState(newText.trim());
      }
      text = newText;
    });

    await openBottomSheet(thisContext, Builder(builder: (context) {
      setDarkGreyUiViewOverlay();
      return SizedBox(
        height: getScreenHeight(context) * 0.85,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.cancel),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        CategoryNotifier().restart();
                        categoryRefreshNotifier.sendNewState(true);
                        timer?.cancel();
                        timer = Timer(Duration(seconds: 5), () {
                          categoryRefreshNotifier.sendNewState(false);
                        });
                      },
                      child: Row(
                        children: [
                          Text("Refresh"),
                          SizedBox(
                            width: 5,
                          ),
                          WidgetStateConsumer(
                              widgetStateNotifier: categoryRefreshNotifier,
                              widgetStateBuilder: (context, data) {
                                return (data == true)
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child:
                                            progressBarWidget(size: 16, pad: 8))
                                    : Icon(
                                        Icons.refresh,
                                        color: Colors.black,
                                        size: 24,
                                      );
                              }),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: addNewCategory,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 24,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text("New Category")
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),

                TextField(
                  controller: categorySearchController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                      hintText: "eg: Toyota",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      )),
                ),

                const SizedBox(
                  height: 10,
                ),

                Expanded(
                  child: StreamBuilder(
                      stream: searchNotifier.stream,
                      builder: (context, stream) {
                        return WidgetStateConsumer(
                            widgetStateNotifier: CategoryNotifier().state,
                            widgetStateBuilder: (context, snapshot) {
                              List<CategoryData> categoryData = [];
                              categoryRefreshNotifier.sendNewState(false);
                              if (CategoryNotifier().getLatestData().isEmpty ==
                                  true) {
                                if (snapshot?.isEmpty == true) {
                                  return const Center(
                                    child: Text(
                                      "No category to show",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  );
                                }

                                if (snapshot == null) {
                                  return Center(
                                    child: progressBarWidget(),
                                  );
                                }
                              } else {
                                categoryData =
                                    CategoryNotifier().getLatestData();
                              }

                              final category = categoryData
                                  .where((element) => element.categoryIdentity
                                      .toLowerCase()
                                      .contains(
                                          stream.data?.toLowerCase() ?? ''))
                                  .toList()
                                  .where((element) =>
                                      element.categoryFor ==
                                          dbReference(cat.Category.parts) ||
                                      element.categoryFor ==
                                          dbReference(cat.Category.all))
                                  .toList();

                              return ListView.builder(
                                  itemCount: category.length,
                                  itemBuilder: (context, index) {
                                    String identity =
                                        category[index].categoryIdentity;
                                    String type = category[index].categoryFor;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: StatefulBuilder(
                                          builder: (context, set) {
                                        return CustomOnClickContainer(
                                          onTap: () {
                                            set(() {
                                              if (selected?.categoryId !=
                                                  category[index].categoryId) {
                                                selected = category[index];
                                                Navigator.pop(context);
                                              }
                                            });
                                          },
                                          defaultColor: Colors.transparent,
                                          clickedColor: Colors.grey.shade100,
                                          child: Row(children: [
                                            Container(
                                              height: 16,
                                              width: 16,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.black
                                                          .withOpacity(0.6))),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Expanded(
                                                child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  CategoryOperation()
                                                      .displayTheCategory(
                                                          identity),
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  CategoryOperation()
                                                      .fowWhichIdentity[type],
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ]),
                                        );
                                      }),
                                    );
                                  });
                            });
                      }),
                ),
                //   Continue
                const SizedBox(
                  height: 8,
                ),
              ]),
        ),
      );
    }), color: Colors.grey.shade200)
        .then((value) {
      setLightUiViewOverlay();
    });

    return selected;
  }

  Future<String?> openListOfCurrency(BuildContext thisContext) async {
    String? selected;
    CurrencyData? currency;
    WidgetStateNotifier<String> searchNotifier = WidgetStateNotifier();
    String text = '';
    currencySearchController.addListener(() {
      String newText = currencySearchController.text.trim();

      if (text != newText) {
        searchNotifier.sendNewState(newText.trim());
      }
      text = newText;
    });

    await openBottomSheet(thisContext, Builder(builder: (context) {
      setDarkGreyUiViewOverlay();
      return SizedBox(
        height: getScreenHeight(context) * 0.85,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.cancel),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),

                TextField(
                  controller: currencySearchController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                      hintText: "eg: Currency ",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      )),
                ),

                const SizedBox(
                  height: 10,
                ),

                Expanded(
                  child: StreamBuilder(
                      stream: searchNotifier.streamController.stream,
                      builder: (context, stream) {
                        final currencies = CurrencyCollection.getCurrencies();

                        currencies.removeWhere((element) => (!element.code
                                .toLowerCase()
                                .contains(stream.data?.toLowerCase() ?? '') &&
                            !element.name
                                .toLowerCase()
                                .contains(stream.data?.toLowerCase() ?? '')));

                        return ListView.builder(
                            itemCount: currencies.length,
                            itemBuilder: (context, index) {
                              CurrencyData currencyData = currencies[index];

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: StatefulBuilder(builder: (context, set) {
                                  return CustomOnClickContainer(
                                    onTap: () {
                                      set(() {
                                        if (currencyData.code !=
                                            currency?.code) {
                                          selected = currencyData.code;
                                          currency = currencyData;
                                          Navigator.pop(context);
                                        }
                                      });
                                    },
                                    defaultColor: Colors.transparent,
                                    clickedColor: Colors.grey.shade100,
                                    child: Row(children: [
                                      SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Radio<String?>(
                                          value: currencyData.code,
                                          groupValue: currency?.code,
                                          onChanged: (value) {
                                            set(() {
                                              selected = currencyData.code;
                                              currency = currencyData;
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            // code
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                        currencyData.code)),
                                              ],
                                            ),
                                            // name
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  currencyData.name,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(currencyData.symbol)
                                    ]),
                                  );
                                }),
                              );
                            });
                      }),
                ),
                //   Continue
                const SizedBox(
                  height: 8,
                ),
              ]),
        ),
      );
    }), color: Colors.grey.shade200);

    return selected;
  }

  Widget getSelectorWidget(String text, IconData iconData, Function() onClick) {
    return GestureDetector(
      onTap: onClick,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 30,
            color: Colors.black,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            text,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          )
        ],
      ),
    );
  }

  Future<void> sendANewPart() async {
    showCustomProgressBar(context);
    try {
      void clearOperation() {
        identityController.clear();
        descriptionController.clear();
        priceController.clear();
        categoryNotifier.sendNewState(null);
        currencyNotifier.sendNewState(null);
        mediaNotifier.sendNewState([null]);
        showToastMobile(msg: "You have added a new part!");
      }

      void afterAllPostHasBeenAdded(
          Map<String, dynamic> partsData, String categoryId) {
        CategoryNotifier()
            .processPartsData(categoryId, NotifierType.normal, partsData);
        clearOperation();
        closeCustomProgressBar(context);
        Navigator.pop(context);
      }

      // Get Identity
      String partsIdentity = identityController.text.toString().trim();
      // Get Identity
      String partsDescription = descriptionController.text.toString().trim();
      // Get Price
      String partsPrice = priceController.text.toString().trim();
      // Get Category
      String categoryId = categoryNotifier.currentValue!.categoryId;
      // Get Currency
      String currency = currencyNotifier.currentValue!;

      // Get members id
      String? membersId = SupabaseConfig.client.auth.currentUser?.id;

      // Check for existence
      if (membersId == null) {
        showToastMobile(msg: "An unexpected error has occurred");
        closeCustomProgressBar(context);
        return;
      }

      // Start posting
      List<MediaData?> media = mediaNotifier.currentValue ?? [];

      media.removeWhere((element) => element == null);

      // Map out media files
      final imageMedia = media
          .where((element) => element?.mediaType == MediaType.image)
          .map((image) => FlutterNativeImage.compressImage(image!.mediaData,
                  quality: 100, percentage: 100)
              .then((compressedImage) async => MediaTypeData(
                  await compressedImage.readAsBytes(),
                  CategoryOperation()
                      .getExtension(compressedImage.path, "image"))))
          .toList();

      final videoMedia = media
          .where((element) => element?.mediaType == MediaType.video)
          .map((video) => VideoCompress.compressVideo(video!.mediaData,
                      quality: VideoQuality.LowQuality)
                  .then((compressedVideo) async {
                File? file = compressedVideo?.file;

                if (file == null) {
                  return null;
                }
                return MediaTypeData(await file.readAsBytes(),
                    CategoryOperation().getExtension(file.path, "video"));
              }));

      // Get the file future for image
      Future<List<MediaTypeData?>> mediaByteFuture =
          Future.wait([...imageMedia]);

      // Return the file data
      List<MediaTypeData?> getMediaFutureResult = await mediaByteFuture;

      // Get file future for video
      if (videoMedia.isNotEmpty) {
        await Future.forEach(videoMedia, (element) async {
          final data = await element;
          getMediaFutureResult.add(data);
        });
      }

      // Remove null data and handle them
      getMediaFutureResult.removeWhere((element) => element == null);

      // Cast the remaining media
      List<MediaTypeData> getMediaBytes = getMediaFutureResult.cast();

      // has media
      int hasMedia = getMediaBytes.length;

      // Send a new post
      final parts = await PartsOperation().sendANewPart(
          partsIdentity,
          partsDescription,
          partsPrice,
          categoryId,
          currency,
          membersId,
          hasMedia);

      //     Post is sent already but verified if media is attached
      if (parts != null) {
        // Part id
        String partsId = parts[dbReference(Parts.id)];

        if (getMediaBytes.isNotEmpty) {
          //     Start uploading media
          final uploads = getMediaBytes
              .asMap()
              .map((index, mediaByte) => MapEntry(
                  index,
                  CategoryOperation().uploadPostMedia(partsId, index,
                      mediaByte.data, getMediaBytes[index].type)))
              .values
              .toList();

          final uploadOperation = await Future.wait(uploads);

          if (uploadOperation.isNotEmpty) {
            afterAllPostHasBeenAdded(parts, categoryId);
          } else {
            showToastMobile(msg: "An error has occurred");
            closeCustomProgressBar(context);
          }
        } else {
          afterAllPostHasBeenAdded(parts, categoryId);
        }
      } else {
        // Post was not added
        showToastMobile(msg: "An error with part addition");
        closeCustomProgressBar(context);
      }
    } catch (error, stackTrace) {
// Catch uncaught error here
      closeCustomProgressBar(context);
      showToastMobile(msg: "An error has occurred");
      showDebug(msg: "$error $stackTrace");
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
                const Expanded(
                  child: Text(
                    "New Part",
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Media Picker
                    WidgetStateConsumer(
                        widgetStateNotifier: mediaNotifier,
                        widgetStateBuilder: (context, mediaList) {
                          return SizedBox(
                            height: getScreenWidth(context) - (16 * 2),
                            child: PageView.builder(
                                controller: controller,
                                itemCount: mediaList?.length ?? 0,
                                itemBuilder: (context, index) {
                                  if (mediaList![index] == null) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all()),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  getSelectorWidget("Image",
                                                      Icons.image, onTapImage),
                                                  SizedBox(
                                                    width: getScreenWidth(
                                                            context) *
                                                        0.1,
                                                  ),
                                                  getSelectorWidget(
                                                      "Video",
                                                      Icons.video_camera_back,
                                                      onTapVideo),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Stack(
                                        children: [
                                          CustomOnClickContainer(
                                            defaultColor: Colors.transparent,
                                            clickedColor: Colors.transparent,
                                            clipBehavior: Clip.antiAlias,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          child: MediaHandler(
                                                              media: mediaList[
                                                                  index]!,
                                                              device: true,
                                                              clicked: () {
                                                                tappedOnMediaAt(
                                                                    index);
                                                              })),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            right: 0,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 12, left: 8, right: 8),
                                              child: Row(
                                                children: [
                                                  Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      16)),
                                                      child: Text(
                                                        "${index + 1} of ${mediaList.length - 1}",
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15),
                                                      )),
                                                  const Expanded(
                                                      child: SizedBox()),
                                                  CustomOnClickContainer(
                                                      onTap: () {
                                                        removeMediaAt(index);
                                                      },
                                                      defaultColor:
                                                          Colors.black,
                                                      clickedColor: Colors.black
                                                          .withOpacity(0.6),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      child: const Icon(
                                                        Icons.cancel,
                                                        color: Colors.white,
                                                      ))
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                }),
                          );
                        }),

                    const SizedBox(
                      height: 16,
                    ),
                    WidgetStateConsumer(
                        widgetStateNotifier: mediaNotifier,
                        widgetStateBuilder: (context, data) {
                          return SmoothPageIndicator(
                              controller: controller, count: data?.length ?? 0);
                        }),

                    //  Part Identity
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: CustomEditTextField(
                          capitalization: TextCapitalization.words,
                          keyboardType: TextInputType.text,
                          controller: identityController,
                          hintText: "Part Identity",
                          obscureText: false,
                          titleStyle: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.bold),
                          useShadow: false,
                          textSize: 16),
                    ),

                    //  Part Description
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: CustomEditTextField(
                          capitalization: TextCapitalization.words,
                          keyboardType: TextInputType.text,
                          controller: descriptionController,
                          hintText: "Part Description",
                          obscureText: false,
                          titleStyle: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.bold),
                          useShadow: false,
                          textSize: 16),
                    ),

                    //  Part price
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: CustomEditTextField(
                          capitalization: TextCapitalization.words,
                          keyboardType: TextInputType.number,
                          controller: priceController,
                          hintText: "Part Price",
                          obscureText: false,
                          titleStyle: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.bold),
                          useShadow: false,
                          textSize: 16),
                    ),

                    // Category
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: WidgetStateConsumer(
                          widgetStateNotifier: categoryNotifier,
                          widgetStateBuilder: (context, category) {
                            return CustomSelectDialogField<String?>(
                              hintText: 'Category',
                              text: category != null
                                  ? " ${CategoryOperation().displayTheCategory(category.categoryIdentity)}"
                                  : null,
                              useShadow: false,
                              textStyle: const TextStyle(fontSize: 16),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 8),
                              onTap: () async {
                                final getCategory =
                                    await openListOfCategory(context);
                                categorySearchController.clear();
                                if (getCategory != null) {
                                  categoryNotifier.sendNewState(getCategory);
                                }
                              },
                            );
                          }),
                    ),

                    // Category
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: WidgetStateConsumer(
                          widgetStateNotifier: currencyNotifier,
                          widgetStateBuilder: (context, category) {
                            return CustomSelectDialogField<String?>(
                              hintText: 'Currency',
                              text: category != null ? " $category" : null,
                              useShadow: false,
                              textStyle: const TextStyle(fontSize: 16),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 8),
                              onTap: () async {
                                final getCategory =
                                    await openListOfCurrency(context);
                                currencySearchController.clear();
                                setLightUiViewOverlay();
                                if (getCategory != null) {
                                  currencyNotifier.sendNewState(getCategory);
                                }
                              },
                            );
                          }),
                    ),

                    const SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MultiWidgetStateConsumer(
                          widgetStateListNotifiers: [
                            identityNotifier,
                            priceNotifier,
                            descriptionNotifier,
                            categoryNotifier,
                            currencyNotifier
                          ],
                          widgetStateListBuilder: (context) {
                            bool enable =
                                identityNotifier.currentValue == true &&
                                    priceNotifier.currentValue == true &&
                                    descriptionNotifier.currentValue == true &&
                                    categoryNotifier.currentValue != null &&
                                    currencyNotifier.currentValue?.isNotEmpty ==
                                        true;

                            return CustomPrimaryButton(
                                isEnabled: enable,
                                buttonText: "Save",
                                onTap: sendANewPart);
                          }),
                    ),

                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
