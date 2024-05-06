import 'dart:async';
import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../../components/CustomCircularButton.dart';
import '../../components/CustomOnClickContainer.dart';
import '../../components/CustomProject.dart';
import '../components/CachedVideoPlayer.dart';
import '../data/MediaData.dart';

class CheckUploadPostMediaPage extends StatefulWidget {
  final int startAt;
  final Function(int index)? editingRemoval;
  final WidgetStateNotifier<List<MediaData?>> mediaSelectionNotifier;

  const CheckUploadPostMediaPage(
      {super.key,
      required this.mediaSelectionNotifier,
      required this.startAt,
      this.editingRemoval});

  @override
  State<StatefulWidget> createState() {
    return _CheckUploadPostMediaPageState();
  }
}

class _CheckUploadPostMediaPageState extends State<CheckUploadPostMediaPage> {
  Timer? timer;
  PageController? pageController;
  Map<int, CustomVideoPlayerController> videoController = {};
  int currentView = 0;
  bool notVideo = false;
  WidgetStateNotifier<int> mediaPositionNotifier = WidgetStateNotifier();

  @override
  void initState() {
    super.initState();
    setDarkUiViewOverlay();
    currentView = widget.startAt;
    mediaPositionNotifier.sendNewState(currentView);
    pageController = PageController(initialPage: widget.startAt);
  }

  void performBackPressed() {
    try {
      if (KeyboardVisibilityProvider.isKeyboardVisible(context)) {
        hideKeyboard(context).then((value) {});
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    timer == null;

    videoController.values.forEach((element) {
      element.dispose();
    });
  }

  void handleMediaChanged(index) {
    currentView = index;
    mediaPositionNotifier.sendNewState(currentView);
    List<CustomVideoPlayerController> videoControllers =
        videoController.values.toList();

    videoControllers.forEach((element) {
      if (element.hashCode !=
          videoController.values.elementAtOrNull(index).hashCode) {
        element.videoPlayerController.seekTo(const Duration());
        element.videoPlayerController.pause();
      }
    });
  }

  void removeCurrent() {
    if (widget.editingRemoval == null) {
      List<MediaData?> mediaFiles =
          widget.mediaSelectionNotifier.currentValue ?? [];
      if (currentView == 0) {
        mediaFiles.removeAt(0);
        if (mediaFiles.length > 1) {
          widget.mediaSelectionNotifier.sendNewState(mediaFiles);
        } else {
          widget.mediaSelectionNotifier.sendNewState([null]);
          Navigator.pop(context);
        }
      } else {
        mediaFiles.removeAt(currentView);
        currentView--;
        mediaPositionNotifier.sendNewState(currentView);
        widget.mediaSelectionNotifier.sendNewState(mediaFiles);
      }
    } else {
      widget.editingRemoval!(currentView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PopScope(
          onPopInvoked: (pop) async {
            setLightUiViewOverlay();
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: WidgetStateConsumer(
                    widgetStateNotifier: widget.mediaSelectionNotifier,
                    widgetStateBuilder: (context, snapshot) {
                      return PageView(
                        controller: pageController,
                        onPageChanged: handleMediaChanged,
                        children: (snapshot ?? [])
                            .where((element) => element != null)
                            .toList()
                            .asMap()
                            .map((key, mediaType) => MapEntry(
                                key,
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          getScreenHeight(context) * 0.25),
                                  child: getMediaViewer(key, mediaType!),
                                )))
                            .values
                            .toList(),
                      );
                    }),
              ),

              // Profile Header

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: MultiWidgetStateConsumer(
                    widgetStateListNotifiers: [
                      mediaPositionNotifier,
                      widget.mediaSelectionNotifier
                    ],
                    widgetStateListBuilder: (context) {
                      int currentView = mediaPositionNotifier.currentValue ?? 0;
                      int totalView =
                          widget.mediaSelectionNotifier.currentValue?.length ??
                              0;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CustomCircularButton(
                                      imagePath: null,
                                      iconColor: Colors.white,
                                      onPressed: performBackPressed,
                                      icon: Icons.arrow_back,
                                      width: 40,
                                      height: 40,
                                      iconSize: 30,
                                      mainAlignment: Alignment.center,
                                      defaultBackgroundColor:
                                          Colors.transparent,
                                      clickedBackgroundColor: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Media ${currentView + 1}/${totalView - 1}",
                                        textScaler: TextScaler.noScaling,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomOnClickContainer(
                                      onTap: removeCurrent,
                                      defaultColor: Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      clickedColor:
                                          Colors.white.withOpacity(0.2),
                                      padding: const EdgeInsets.all(6),
                                      child: const Row(
                                        children: [
                                          Text(
                                            "Remove",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            Icons.cancel,
                                            size: 24,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageViewer(String imageUri) {
    return Center(
      child: PhotoViewGallery.builder(
        itemCount: 1,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(
              imageUri,
            ),
            errorBuilder: (a, b, c) {
              return const Center(
                  child: Text(
                "No Image to display",
                style: TextStyle(color: Colors.white),
              ));
            },
            minScale: PhotoViewComputedScale.covered,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const NeverScrollableScrollPhysics(),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget imageViewerFromDevice(String imageUri) {
    return Center(
        child: AspectRatio(
      aspectRatio: 1 / 1,
      child: Image.file(
        File(imageUri),
        fit: BoxFit.cover,
      ),
    ));
  }

  Widget getMediaViewer(int index, MediaData mediaType) {
    return switch (mediaType.mediaType) {
      MediaType.image => mediaType.mediaFromDevice
          ? imageViewerFromDevice(mediaType.mediaData)
          : imageViewer(mediaType.mediaData),
      MediaType.video => getVideoPlayerWidget(index, mediaType),
    };
  }

  Widget getVideoPlayerWidget(int index, MediaData mediaType) {
    VideoPlayerController controller = mediaType.mediaFromDevice
        ? VideoPlayerController.file(File(mediaType.mediaData))
        : VideoPlayerController.networkUrl(Uri.parse(mediaType.mediaData));

    CustomVideoPlayerSettings customVideoPlayerSettings =
        const CustomVideoPlayerSettings(
            playOnlyOnce: false,
            showDurationPlayed: false,
            showFullscreenButton: false,
            alwaysShowThumbnailOnVideoPaused: true,
            durationAfterControlsFadeOut: Duration(seconds: 2));

    CustomVideoPlayerController customVideoPlayerController =
        CustomVideoPlayerController(
            customVideoPlayerSettings: customVideoPlayerSettings,
            context: context,
            videoPlayerController: controller);

    videoController[index] = customVideoPlayerController;

    videoController[index]?.videoPlayerController.setLooping(true);

    return CachedVideoPlayer(
      aspectRatio: 1 / 1,
      videoUrl: Uri.parse(mediaType.mediaData),
      placeholder: progressBarWidget(),
      controller: customVideoPlayerController,
    );
  }
}
