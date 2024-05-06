import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../components/CustomProject.dart';
import '../data/MediaData.dart';

class MediaTypeData {
  final Uint8List data;
  final String type;

  MediaTypeData(this.data, this.type);
}

class MediaHandler extends StatefulWidget {
  final bool device;
  final MediaData media;
  final Function()? clicked;

  const MediaHandler(
      {super.key, required this.media, this.device = false, this.clicked});

  @override
  State<MediaHandler> createState() => _MediaHandlerState();
}

class _MediaHandlerState extends State<MediaHandler> {
  @override
  Widget build(BuildContext context) {
    MediaData mediaData = widget.media;
    return getTheMediaTypeView(mediaData);
  }

  double addPercentage(double value, double percentage) {
    return value + (value * percentage);
  }

  Widget getTheMediaTypeView(
    MediaData mediaData,
  ) {
    return GestureDetector(
      onTap: () {
        if (widget.clicked != null) {
          widget.clicked!();
        }
      },
      child: Stack(
        children: [
          switch (mediaData.mediaType) {
            MediaType.image => imageMedia(mediaData.mediaData),
            MediaType.video => getVideoMedia(mediaData.mediaData),
          }
        ],
      ),
    );
  }

  Future<Uint8List?> getLocalVideoThumbnail(String video) async {
    return await VideoThumbnail.thumbnailData(
      video: video,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
  }

  Future<Uint8List?> getOnlineVideoThumbnail(String video, String path) async {
    final filePath = await VideoThumbnail.thumbnailFile(
      video: video,
      thumbnailPath: path,
      imageFormat: ImageFormat.WEBP,
    );
    if (filePath == null) {
      return null;
    }
    return await File(filePath).readAsBytes();
  }

  Widget imageMedia(String image) {
    return Row(
      children: [
        Expanded(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
            child: widget.device
                ? Image.file(
                    File(image),
                    fit: BoxFit.cover,
                    errorBuilder: (a, b, c) {
                      return widgetProvider(Icons.not_interested);
                    },
                  )
                : CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (a, b, c) {
                      return widgetProvider(Icons.circle_outlined,
                          other: progressBarWidget());
                    },
                    errorWidget: (a, b, c) {
                      return widgetProvider(Icons.not_interested);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Future<Uint8List?> getVideoThumbnail(String video) async {
    final videoPath = widget.device
        ? (await getLocalVideoThumbnail(video))
        : (await getOnlineVideoThumbnail(
            video, (await getTemporaryDirectory()).path));
    if (videoPath != null) {
      return videoPath;
    }
    return null;
  }

  Widget widgetProvider(IconData iconData, {Widget? other}) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
        ),
        child: Center(
          child: other ??
              Icon(
                iconData,
                color: Colors.white,
                size: 24,
              ),
        ));
  }

  Widget getVideoMedia(String video) {
    return FutureBuilder(
        future: getVideoThumbnail(video),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Error occurred
            return widgetProvider(Icons.circle_outlined,
                other: Container(
                  child: Center(
                    child: progressBarWidget(),
                  ),
                ));
          }
          return Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0)),
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          errorBuilder: (a, b, c) {
                            return widgetProvider(Icons.not_interested);
                          },
                        )),
                  ),
                ],
              ),
              Positioned.fill(
                  child: Center(
                child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    )),
              ))
            ],
          );
        });
  }
}
