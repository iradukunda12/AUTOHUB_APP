import 'package:autohub/components/CustomProject.dart';
import 'package:autohub/data/MediaData.dart';

import '../db_references/Services.dart';

class ServicesData {
  final String servicesId;
  final String servicesIdentity;
  final String servicesDescription;
  final String servicesPrice;
  final String servicesCurrency;
  final String servicesAddedBy;
  final String? servicesEditedBy;
  final String servicesCreateAt;
  final bool servicesHasMedia;
  final List<MediaData> servicesMedia;
  final String servicesCategoryId;

  // Constructor for ServicesData
  ServicesData(
    this.servicesId,
    this.servicesIdentity,
    this.servicesDescription,
    this.servicesPrice,
    this.servicesCurrency,
    this.servicesAddedBy,
    this.servicesEditedBy,
    this.servicesCreateAt,
    this.servicesHasMedia,
    this.servicesMedia,
    this.servicesCategoryId,
  );

  // Converts a ServicesData instance to a Map object.
  Map<dynamic, dynamic> toJson() {
    return {
      'servicesId': servicesId,
      'servicesIdentity': servicesIdentity,
      'servicesDescription': servicesDescription,
      'servicesPrice': servicesPrice,
      'servicesCurrency': servicesCurrency,
      'servicesAddedBy': servicesAddedBy,
      'servicesEditedBy': servicesEditedBy,
      'servicesCreateAt': servicesCreateAt,
      'servicesHasMedia': servicesHasMedia,
      'servicesMedia': servicesMedia.map((e) => e.toJson()).toList(),
      'servicesCategoryId': servicesCategoryId,
    };
  }

  // Creates a ServicesData instance from a map (deserialization).
  factory ServicesData.fromJson(Map<dynamic, dynamic> json) {
    return ServicesData(
      json['servicesId'] as String,
      json['servicesIdentity'] as String,
      json['servicesDescription'] as String,
      json['servicesPrice'] as String,
      json['servicesCurrency'] as String,
      json['servicesAddedBy'] as String,
      json['servicesEditedBy'] as String,
      json['servicesCreateAt'] as String,
      json['servicesHasMedia'] as bool,
      (json['servicesMedia'] as List<dynamic>)
          .map((media) => MediaData.fromJson(media))
          .toList(),
      json['servicesCategoryId'] as String,
    );
  }

  factory ServicesData.fromOnline(
      Map<dynamic, dynamic> json, List<MediaData> postMedia) {
    return ServicesData(
      json[dbReference(Services.id)] as String,
      json[dbReference(Services.identity)] as String,
      json[dbReference(Services.description)] as String,
      json[dbReference(Services.price)] as String,
      json[dbReference(Services.currency)] as String,
      json[dbReference(Services.added_by)] as String,
      json[dbReference(Services.edited_by)],
      json[dbReference(Services.created_at)] as String,
      json[dbReference(Services.has_media)] as bool,
      postMedia,
      json[dbReference(Services.category_id)] as String,
    );
  }

  // Creates a copy of the instance with optionally updated fields.
  ServicesData copyWith({
    String? servicesId,
    String? servicesIdentity,
    String? servicesDescription,
    String? servicesPrice,
    String? servicesCurrency,
    String? servicesAddedBy,
    String? servicesEditedBy,
    String? servicesCreateAt,
    bool? servicesHasMedia,
    List<MediaData>? servicesMedia,
    String? servicesCategoryId,
  }) {
    return ServicesData(
      servicesId ?? this.servicesId,
      servicesIdentity ?? this.servicesIdentity,
      servicesDescription ?? this.servicesDescription,
      servicesPrice ?? this.servicesPrice,
      servicesCurrency ?? this.servicesCurrency,
      servicesAddedBy ?? this.servicesAddedBy,
      servicesEditedBy ?? this.servicesEditedBy,
      servicesCreateAt ?? this.servicesCreateAt,
      servicesHasMedia ?? this.servicesHasMedia,
      servicesMedia ?? this.servicesMedia,
      servicesCategoryId ?? this.servicesCategoryId,
    );
  }
}
