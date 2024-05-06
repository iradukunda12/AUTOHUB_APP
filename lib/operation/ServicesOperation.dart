import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/CustomProject.dart';
import '../db_references/Services.dart';
import '../supabase/SupabaseConfig.dart';

class ServicesOperation {
  PostgrestTransformBuilder<PostgrestList> getServiceDataForSearch(
      String likeText, int limitBy) {
    return SupabaseConfig.client
        .from(dbReference(Services.table))
        .select("*")
        .ilike(dbReference(Services.identity), "%$likeText%")
        .limit(limitBy);
  }

  PostgrestTransformBuilder<PostgrestList> getServicesData(
      String categoryId, String lesserThanTime, bool fromStart, int retry,
      {int? limitBy}) {
    final filter = SupabaseConfig.client
        .from(dbReference(Services.table))
        .select("*")
        .eq(dbReference(Services.category_id), categoryId);

    final search =
        // fromStart == false
        //     ?
        filter
            .lte(dbReference(Services.created_at), lesserThanTime)
            .order(dbReference(Services.created_at));
    // : filter;

    if (limitBy != null) {
      return search.limit(limitBy);
    } else {
      return search;
    }
  }

  PostgrestTransformBuilder<PostgrestMap?> sendANewService(
      String partsIdentity,
      String partsDescription,
      String partsPrice,
      String categoryId,
      String currency,
      String memberId,
      int hasMedia) {
    return SupabaseConfig.client
        .from(dbReference(Services.table))
        .insert({
          dbReference(Services.identity): partsIdentity,
          dbReference(Services.description): partsDescription,
          dbReference(Services.price): partsPrice,
          dbReference(Services.category_id): categoryId,
          dbReference(Services.currency): currency,
          dbReference(Services.has_media): hasMedia > 0,
          dbReference(Services.added_by): memberId,
        })
        .select()
        .maybeSingle();
  }

  PostgrestTransformBuilder<PostgrestMap?> updateAService(
      String partsIdentity,
      String partsDescription,
      String partsPrice,
      String currency,
      String categoryId,
      int hasMedia,
      String servicesId) {
    return SupabaseConfig.client
        .from(dbReference(Services.table))
        .update({
          dbReference(Services.identity): partsIdentity,
          dbReference(Services.description): partsDescription,
          dbReference(Services.price): partsPrice,
          dbReference(Services.currency): currency,
          dbReference(Services.category_id): categoryId,
          dbReference(Services.has_media): hasMedia > 0,
        })
        .eq(dbReference(Services.id), servicesId)
        .select()
        .maybeSingle();
  }

  PostgrestFilterBuilder deleteAService(String servicesId) {
    return SupabaseConfig.client
        .from(dbReference(Services.table))
        .delete()
        .eq(dbReference(Services.id), servicesId);
  }
}
