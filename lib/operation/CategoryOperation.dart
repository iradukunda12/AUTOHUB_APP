import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/CustomProject.dart';
import '../data/MediaData.dart';
import '../db_references/Category.dart';
import '../supabase/SupabaseConfig.dart';

class CategoryOperation {
  Map get fowWhichIdentity => {
        dbReference(Category.parts): "Parts",
        dbReference(Category.services): "Services",
        dbReference(Category.all): "All type"
      };

  PostgrestTransformBuilder<PostgrestList> getCategoryData(
      String lesserThanTime, bool fromStart, int retry,
      {int? limitBy}) {
    final filter =
        SupabaseConfig.client.from(dbReference(Category.table)).select("*");

    final search =
        // fromStart == false
        //     ?
        filter
            .lte(dbReference(Category.created_at), lesserThanTime)
            .order(dbReference(Category.created_at));
    // : filter;

    if (limitBy != null) {
      return search.limit(limitBy);
    } else {
      return search;
    }
  }

  PostgrestTransformBuilder<PostgrestMap?> saveNewCategory(
      String categoryIdentity,
      String categoryDescription,
      String categoryForWhich,
      String categoryAddedBy) {
    return SupabaseConfig.client
        .from(dbReference(Category.table))
        .insert({
          dbReference(Category.identity): categoryIdentity,
          dbReference(Category.description): categoryDescription,
          dbReference(Category.for_which): categoryForWhich,
          dbReference(Category.created_by): categoryAddedBy,
        })
        .select()
        .maybeSingle();
  }

  PostgrestFilterBuilder deleteCategory(String categoryId) {
    return SupabaseConfig.client
        .from(dbReference(Category.table))
        .delete()
        .eq(dbReference(Category.id), categoryId);
  }

  PostgrestTransformBuilder<PostgrestMap?> updateCategory(
      String categoryIdentity,
      String categoryDescription,
      String categoryForWhich,
      String categoryId) {
    return SupabaseConfig.client
        .from(dbReference(Category.table))
        .update({
          dbReference(Category.identity): categoryIdentity,
          dbReference(Category.description): categoryDescription,
          dbReference(Category.for_which): categoryForWhich,
        })
        .eq(dbReference(Category.id), categoryId)
        .select()
        .maybeSingle();
  }

  String getPostBucketPath(String id, String name) {
    final mediaPath = "$id/$name";
    return SupabaseConfig.client.storage
        .from(dbReference("media_bucket"))
        .getPublicUrl(mediaPath);
  }

  String getOnlinePath(String path) {
    return SupabaseConfig.client.storage.from("media_bucket").getPublicUrl(
            path.split("/").toList().fold("", (previousValue, element) {
          if (element != "media_bucket") {
            if (previousValue.isEmpty) return element;
            return "$previousValue/$element";
          }
          return previousValue;
        }));
  }

  Future<List<FileObject>> getMediaFiles(String postId) {
    return SupabaseConfig.client.storage
        .from(dbReference("media_bucket"))
        .list(path: postId);
  }

  MediaData getParsedData(String partsId, FileObject mediaFile) {
    String name = mediaFile.name;
    MediaType mediaType =
        name.contains("image") ? MediaType.image : MediaType.video;
    String mediaPath = getPostBucketPath(partsId, name);
    return MediaData(mediaType, mediaPath);
  }

  String getExtension(String path, String mediaType) {
    final mediaExtension = path.split(".").last.toLowerCase();
    return "$mediaType/$mediaExtension";
  }

  String getPostMediaPath(String id, String type, int index) {
    return "/$id/${type.split("/")[0]}_$index";
  }

  int getMediaIndex(String mediaDataLink) {
    return int.parse(mediaDataLink.split("/").last.split("_").last.toString());
  }

  Future<String> uploadPostMedia(
      String postId, int index, Uint8List mediaByte, String mediaType) {
    final mediaPath = getPostMediaPath(postId, mediaType, index);
    return SupabaseConfig.client.storage.from("media_bucket").uploadBinary(
        mediaPath, mediaByte,
        fileOptions: FileOptions(upsert: true, contentType: mediaType));
  }

  Future<List<FileObject>> deletePostMedia(
      String postId, int index, String mediaType) {
    final mediaPath = getPostMediaPath(postId, mediaType, index);
    return SupabaseConfig.client.storage
        .from("media_bucket")
        .remove([mediaPath]);
  }

  String displayTheCategory(String category) {
    List<String> words = category.split(" ");
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] =
            words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
      }
    }
    return words.join(" ");
  }

  String formatNumber(double value) {
    List<String> valueText = value.toString().split(".");
    if (value >= 1000000000) {
      double billionValue = value / 1000000000.0;
      return '${billionValue.toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      double millionValue = value / 1000000.0;
      return '${millionValue.toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      String formatted = value.toStringAsFixed(0);
      int length = formatted.length;
      return '${formatted.substring(0, length - 3)},${formatted.substring(length - 3)}.${valueText.last}';
    } else {
      return value.toStringAsFixed(1);
    }
  }
}
