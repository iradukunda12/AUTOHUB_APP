// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:open_document/my_files/init.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../builders/ControlledStreamBuilder.dart';
import '../builders/CustomWrapListBuilder.dart';
import '../data/UserData.dart';
import '../data/UserProfileData.dart';
import '../operation/MembersOperation.dart';
import '../supabase/SupabaseConfig.dart';
import 'ProfileNotifier.dart';

class UserProfileImplement {
  BuildContext? getLatestContext() => null;

  RetryStreamListener? getRetryStreamListener() => null;

  PaginationProgressController? getPaginationProgressController() => null;
}

class UserProfileNotifier {
  WidgetStateNotifier<UserProfileData> state = WidgetStateNotifier();

  UserProfileData? _data;

  UserProfileImplement? _postProfileImplement;

  bool started = false;

  String? _memberId;

  StreamSubscription? profileStreamSubscription;
  StreamSubscription? userStreamSubscription;

  UserProfileNotifier attachMembersId(String postId,
      {bool startFetching = false}) {
    _memberId = postId;
    if (startFetching) {
      _startFetching();
    }
    return this;
  }

  UserProfileNotifier start(
      UserProfileImplement postProfileImplement, String postId,
      {bool startFetching = true}) {
    BuildContext? buildContext = postProfileImplement.getLatestContext();
    if (buildContext != null && postId == _memberId) {
      _postProfileImplement = postProfileImplement;
      _attachListeners(postProfileImplement);
      if (startFetching) {
        _startFetching();
      }
    }
    return this;
  }

  void _startFetching() {
    started = true;

    if (!forThisUser()) {
      _fetchLocalPostProfile();
      _fetchPostProfileOnline();
    }
  }

  bool forThisUser() {
    String thisUser = SupabaseConfig.client.auth.currentUser?.id ?? '';

    if (thisUser.isNotEmpty && _memberId == thisUser) {
      UserData? userData = ProfileNotifier().state.currentValue;
      if (userData != null) {
        _configure(UserProfileData.fromJson(userData.toJson()), true);
        userStreamSubscription ??=
            ProfileNotifier().state.stream.listen((event) {
          if (event != null) {
            _configure(UserProfileData.fromJson(event.toJson()), true);
          }
        });
      }
      return true;
    }
    return false;
  }

  UserProfileData? getLatestData() {
    return _data;
  }

  void _retryListener() {
    restart();
  }

  void _attachListeners(UserProfileImplement commentImplement) {
    RetryStreamListener? retryStreamListener =
        commentImplement.getRetryStreamListener();
    retryStreamListener?.addListener(_retryListener);
  }

  void restart() {
    if (started) {
      _fetchPostProfileOnline();
    }
  }

  void endSubscription() {
    profileStreamSubscription?.cancel();
    profileStreamSubscription = null;
    userStreamSubscription?.cancel();
    userStreamSubscription = null;
  }

  void stop() {
    endSubscription();
    _postProfileImplement
        ?.getRetryStreamListener()
        ?.removeListener(_retryListener);
  }

  Future<void> _fetchPostProfileOnline() async {
    if (_memberId == null) {
      return;
    }

    await profileStreamSubscription?.cancel();
    profileStreamSubscription = null;
    profileStreamSubscription = MembersOperation()
        .userOnlineRecordStream(_memberId!)
        .listen((userRecord) {
      if (userRecord.singleOrNull != null) {
        _configure(UserProfileData.fromOnlineData(userRecord.single), false);
      }
    });
  }

  void _fetchLocalPostProfile() async {
    if (_memberId == null) {
      return;
    }
    // final savedPostProfileData = await CacheOperation().getCacheData(
    //     "", _memberId!,
    //     fromWhere: _fromWhere);

    // if (savedPostProfileData != null) {
    //   final postProfileData = UserProfileData.fromJson(savedPostProfileData);
    //   _configure(postProfileData, false);
    // }
  }

  void updateLatestData(UserProfileData postProfileData) {
    _data = postProfileData;
  }

  void _configure(UserProfileData postProfileData, bool userData) {
    updateLatestData(postProfileData);
    sendUpdateToUi(postProfileData);

    if (!userData) {
      saveLatestPostProfile();
    }
  }

  void sendUpdateToUi(UserProfileData userProfileData) {
    state.sendNewState(userProfileData);
  }

  Future<void> saveLatestPostProfile() async {
    // if (_data != null) {
    //   await CacheOperation().saveCacheData(
    //       "", _memberId!, _data?.toJson(),
    //       fromWhere: _fromWhere);
    // }
  }
}
