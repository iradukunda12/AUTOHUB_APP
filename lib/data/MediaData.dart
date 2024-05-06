enum MediaType { image, video }

class MediaData {
  final MediaType mediaType;
  final String mediaData;
  final bool mediaFromDevice;

  MediaData(this.mediaType, this.mediaData, {this.mediaFromDevice = false});

  factory MediaData.fromJson(Map<dynamic, dynamic> json) {
    return MediaData(
      MediaType.values[json['mediaType']],
      json['mediaData'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'mediaType': mediaType.index,
      'mediaData': mediaData,
    };
  }
}
