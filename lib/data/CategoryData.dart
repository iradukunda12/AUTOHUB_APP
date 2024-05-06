import 'package:autohub/components/CustomProject.dart';

import '../db_references/Category.dart';

class CategoryData {
  final String categoryId;
  final String categoryIdentity;
  final String categoryDescription;
  final String categoryFor;
  final String categoryCreatedBy;
  final String categoryCreatedAt;

  // Constructor for CategoryData
  CategoryData(
    this.categoryId,
    this.categoryIdentity,
    this.categoryDescription,
    this.categoryFor,
    this.categoryCreatedBy,
    this.categoryCreatedAt,
  );

  // Converts a CategoryData instance to a Map object.
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryIdentity': categoryIdentity,
      'categoryDescription': categoryDescription,
      'categoryFor': categoryFor,
      'categoryCreatedBy': categoryCreatedBy,
      'categoryCreatedAt': categoryCreatedAt,
    };
  }

  // Creates a CategoryData instance from a map (deserialization).
  factory CategoryData.fromJson(Map<dynamic, dynamic> json) {
    return CategoryData(
      json['categoryId'] as String,
      json['categoryIdentity'] as String,
      json['categoryDescription'] as String,
      json['categoryFor'] as String,
      json['categoryCreatedBy'] as String,
      json['categoryCreatedAt'] as String,
    );
  }

  factory CategoryData.fromOnline(Map<dynamic, dynamic> json) {
    return CategoryData(
      json[dbReference(Category.id)] as String,
      json[dbReference(Category.identity)] as String,
      json[dbReference(Category.description)] as String,
      json[dbReference(Category.for_which)] as String,
      json[dbReference(Category.created_by)] as String,
      json[dbReference(Category.created_at)] as String,
    );
  }

  // Creates a copy of the instance with optionally updated fields.
  CategoryData copyWith({
    String? categoryId,
    String? categoryIdentity,
    String? categoryDescription,
    String? categoryFor,
    String? categoryCreatedBy,
    String? categoryCreatedAt,
  }) {
    return CategoryData(
      categoryId ?? this.categoryId,
      categoryIdentity ?? this.categoryIdentity,
      categoryDescription ?? this.categoryDescription,
      categoryFor ?? this.categoryFor,
      categoryCreatedBy ?? this.categoryCreatedBy,
      categoryCreatedAt ?? this.categoryCreatedAt,
    );
  }
}
