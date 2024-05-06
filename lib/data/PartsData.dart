import 'package:autohub/components/CustomProject.dart';
import 'package:autohub/data/MediaData.dart';

import '../db_references/Parts.dart';

class PartsData {
  final String partsId;
  final String partsIdentity;
  final String partsDescription;
  final String partsAddedBy;
  final String? partsEditedBy;
  final String partsPrice;
  final String partsCurrency;
  final String partsCreatedAt;
  final bool partsHasMedia;
  final List<MediaData> partsMedia;
  final String partsCategoryId;

  // Constructor for PartsData
  PartsData(
      this.partsId,
      this.partsIdentity,
      this.partsDescription,
      this.partsAddedBy,
      this.partsEditedBy,
      this.partsPrice,
      this.partsCurrency,
      this.partsCreatedAt,
      this.partsHasMedia,
      this.partsMedia,
      this.partsCategoryId);

  // Converts a PartsData instance to a Map object.
  Map<dynamic, dynamic> toJson() {
    return {
      'partsId': partsId,
      'partsIdentity': partsIdentity,
      'partsDescription': partsDescription,
      'partsAddedBy': partsAddedBy,
      'partsEditedBy': partsEditedBy,
      'partsPrice': partsPrice,
      'partsCurrency': partsCurrency,
      'partsCreatedAt': partsCreatedAt,
      'partsHasMedia': partsHasMedia,
      'partsMedia': partsMedia.map((e) => e.toJson()).toList(),
      'partsCategoryId': partsCategoryId,
    };
  }

  // Creates a PartsData instance from a map (deserialization).
  factory PartsData.fromJson(Map<dynamic, dynamic> json) {
    return PartsData(
      json['partsId'] as String,
      json['partsIdentity'] as String,
      json['partsDescription'] as String,
      json['partsAddedBy'] as String,
      json['partsEditedBy'] as String,
      json['partsPrice'] as String,
      json['partsCurrency'] as String,
      json['partsCreatedAt'] as String,
      json['partsHasMedia'] as bool,
      (json['partsMedia'] as List<dynamic>)
          .map((media) => MediaData.fromJson(media))
          .toList(),
      json['partsCategoryId'] as String,
    );
  }

  factory PartsData.fromOnline(
      Map<dynamic, dynamic> json, List<MediaData> postMedia) {
    return PartsData(
      json[dbReference(Parts.id)] as String,
      json[dbReference(Parts.identity)] as String,
      json[dbReference(Parts.description)] as String,
      json[dbReference(Parts.added_by)] as String,
      json[dbReference(Parts.edited_by)],
      json[dbReference(Parts.price)] as String,
      json[dbReference(Parts.currency)] as String,
      json[dbReference(Parts.created_at)] as String,
      json[dbReference(Parts.has_media)] as bool,
      postMedia,
      json[dbReference(Parts.category_id)] as String,
    );
  }

  // Creates a copy of the instance with optionally updated fields.
  PartsData copyWith({
    String? partsId,
    String? partsIdentity,
    String? partsDescription,
    String? partsAddedBy,
    String? partsEditedBy,
    String? partsPrice,
    String? partsCurrency,
    String? partsCreatedAt,
    bool? partsHasMedia,
    List<MediaData>? partsMedia,
    String? partsCategoryId,
  }) {
    return PartsData(
      partsId ?? this.partsId,
      partsIdentity ?? this.partsIdentity,
      partsDescription ?? this.partsDescription,
      partsAddedBy ?? this.partsAddedBy,
      partsEditedBy ?? this.partsEditedBy,
      partsPrice ?? this.partsPrice,
      partsCurrency ?? this.partsCurrency,
      partsCreatedAt ?? this.partsCreatedAt,
      partsHasMedia ?? this.partsHasMedia,
      partsMedia ?? this.partsMedia,
      partsCategoryId ?? this.partsCategoryId,
    );
  }
}
