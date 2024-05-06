import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/CustomProject.dart';
import '../db_references/Parts.dart';
import '../supabase/SupabaseConfig.dart';

class PartsOperation {
  PostgrestTransformBuilder<PostgrestList> getPartDataForSearch(
      String likeText, int limitBy) {
    return SupabaseConfig.client
        .from(dbReference(Parts.table))
        .select("*")
        .ilike(dbReference(Parts.identity), "%$likeText%")
        .limit(limitBy);
  }

  PostgrestTransformBuilder<PostgrestList> getPartsData(
      String categoryId, String lesserThanTime, bool fromStart, int retry,
      {int? limitBy}) {
    final filter = SupabaseConfig.client
        .from(dbReference(Parts.table))
        .select("*")
        .eq(dbReference(Parts.category_id), categoryId);

    final search =
        // fromStart == false
        //     ?
        filter
            .lte(dbReference(Parts.created_at), lesserThanTime)
            .order(dbReference(Parts.created_at));
    // : filter;

    if (limitBy != null) {
      return search.limit(limitBy);
    } else {
      return search;
    }
  }

  PostgrestTransformBuilder<PostgrestMap?> sendANewPart(
      String partsIdentity,
      String partsDescription,
      String partsPrice,
      String categoryId,
      String currency,
      String memberId,
      int hasMedia) {
    return SupabaseConfig.client
        .from(dbReference(Parts.table))
        .insert({
          dbReference(Parts.identity): partsIdentity,
          dbReference(Parts.description): partsDescription,
          dbReference(Parts.price): partsPrice,
          dbReference(Parts.category_id): categoryId,
          dbReference(Parts.currency): currency,
          dbReference(Parts.has_media): hasMedia > 0,
          dbReference(Parts.added_by): memberId,
        })
        .select()
        .maybeSingle();
  }

  PostgrestTransformBuilder<PostgrestMap?> updateAPart(
      String partsIdentity,
      String partsDescription,
      String partsPrice,
      String currency,
      String categoryId,
      int hasMedia,
      String partsId) {
    return SupabaseConfig.client
        .from(dbReference(Parts.table))
        .update({
          dbReference(Parts.identity): partsIdentity,
          dbReference(Parts.description): partsDescription,
          dbReference(Parts.price): partsPrice,
          dbReference(Parts.currency): currency,
          dbReference(Parts.category_id): categoryId,
          dbReference(Parts.has_media): hasMedia > 0,
        })
        .eq(dbReference(Parts.id), partsId)
        .select()
        .maybeSingle();
  }

  PostgrestFilterBuilder deleteAPart(String partsId) {
    return SupabaseConfig.client
        .from(dbReference(Parts.table))
        .delete()
        .eq(dbReference(Parts.id), partsId);
  }
}
