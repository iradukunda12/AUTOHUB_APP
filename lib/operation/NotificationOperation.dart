import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

import '../components/CustomProject.dart';
import '../db_references/Notification.dart' as not;
import 'CacheOperation.dart';

class NotificationOperation {
  Future<ValueListenable<Box>?> listenable() async {
    return await CacheOperation()
        .getListenable(dbReference(not.Notification.database));
  }

  Future<bool> changeNotificationStatus(
      AuthorizationStatus authorizationStatus) {
    return CacheOperation().saveCacheData(
        dbReference(not.Notification.database),
        dbReference(not.Notification.status),
        dbReference(authorizationStatus));
  }
}
