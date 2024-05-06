import '../../components/CustomProject.dart';
import '../../supabase/SupabaseConfig.dart';
import '../db_references/Plans.dart';

class PlansOperation {
  Stream<List<Map<String, dynamic>>> getAllPlans(
      {SupabaseStreamPaginationOption? fetchOptions}) {
    final stream = SupabaseConfig.client
        .from(dbReference(Plans.table))
        .stream(primaryKey: [dbReference(Plans.id)]).order(
            dbReference(Plans.created_at),
            ascending: true);

    if (fetchOptions != null) {
      stream.limit(fetchOptions.supabaseStreamPaginationController.fetchBy);
    }
    return stream;
  }
}
