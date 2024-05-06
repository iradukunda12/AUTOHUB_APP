import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/CustomProject.dart';
import '../local_database.dart';
import '../pages/InitialPage.dart';
import '../services/UserProfileService.dart';
import '../supabase/SupabaseConfig.dart';

class TimeOut {
  static Duration authenticationTimeout = Duration(minutes: 1);
}

class AuthenticationOperation {
  String? thisUser = SupabaseConfig.client.auth.currentUser?.id;

  Stream<AuthResponse> signUpWithEmail(String email, String password,
      {Map<String, dynamic>? data}) {
    return SupabaseConfig.client.auth
        .signUp(email: email, password: password, data: data)
        .timeout(TimeOut.authenticationTimeout)
        .asStream();
  }

  Stream<AuthResponse> signInWithEmail(String email, String password) {
    return SupabaseConfig.client.auth
        .signInWithPassword(email: email, password: password)
        .timeout(TimeOut.authenticationTimeout)
        .asStream();
  }

  void signOut(BuildContext context, {bool expiredToken = false}) {
    showCustomProgressBar(context);

    Future.wait([
      LocalDatabase().clearAll(),
      UserProfileService().endService(),
    ]).then((value) {
      LocalDatabase().interface().deleteFromDisk().then((value) {
        LocalDatabase().startHive().then((value) {
          SupabaseConfig.client.auth.signOut().then((value) {
            closeCustomProgressBar(context);
            try {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PrimaryPage()),
              );
            } catch (e) {
              showToastMobile(msg: "An error occurred");
            }
          });
        });
      });
    }).onError((error, stackTrace) {
      SupabaseConfig.client.auth.signOut().then((value) {
        closeCustomProgressBar(context);
        try {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PrimaryPage()),
          );
        } catch (e) {
          showToastMobile(msg: "An error occurred");
        }
      });
    });
  }

  Future<Session?> getSessions() async {
    return SupabaseConfig.client.auth.currentSession;
  }
}
