// ignore_for_file: constant_identifier_names

import 'package:autohub/builders/CustomWrapListBuilder.dart';
import 'package:autohub/data/PartsData.dart';
import 'package:autohub/data_notifier/CategoryNotifier.dart';
import 'package:autohub/operation/CategoryOperation.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../builders/ControlledStreamBuilder.dart';
import '../components/CustomProject.dart';
import '../data/MediaData.dart';
import '../data/NotifierDataClass.dart';
import '../db_references/NotifierType.dart';
import '../db_references/Parts.dart';
import '../operation/CacheOperation.dart';
import '../operation/PartsOperation.dart';
import 'UserProfileNotifier.dart';

class PartsStack {
  int? _currentStack;

  int getStack(BuildContext context) {
    _currentStack ??= PartsNotifier().stack.length;
    return _currentStack!;
  }
}

class PartsImplement {
  BuildContext? getLatestContext() => null;

  RetryStreamListener? getRetryStreamListener() => null;

  PaginationProgressController? getPaginationProgressController() => null;
}

class PartsNotifier {
  WidgetStateNotifier<List<PartsData>> state = WidgetStateNotifier();

  final List<PartsData> _data = [];

  // final NotifierDataClass<CategoryNotifier?, NotifierType>
  // _categoriesNotifiers = NotifierDataClass();

  final NotifierDataClass<UserProfileNotifier?, NotifierType>
      _userPostNotifier = NotifierDataClass();

  String? _categoryId;

  List<int> stack = [];
  PartsImplement? _partsImplement;
  List<PartsImplement> partsImplements = [];

  bool started = false;
  bool _fromStart = false;
  String partsFromTime = DateTime.now().toUtc().toString();

  PartsNotifier attachCategoryId(String categoryId,
      {bool startFetching = false}) {
    _categoryId = categoryId;
    if (startFetching) {
      _startFetching();
    }
    return this;
  }

  PartsNotifier start(
      PartsImplement partsImplement, PartsStack partsStack, String categoryId) {
    BuildContext? buildContext = partsImplement.getLatestContext();
    if (buildContext != null && _categoryId == categoryId) {
      _partsImplement = partsImplement;
      _attachListeners(partsImplement);
      _startFetching();
    }
    return this;
  }

  Future<void> _startFetching() async {
    started = true;
    _fetchPartsLocal();
    _fetchPartsOnline();
  }

  void _fetchPartsLocal() async {
    final savedPosts = await CacheOperation().getCacheData("", "");

    if (savedPosts != null && savedPosts is Map) {
      // _configure([], false);
    }
  }

  // CategoryNotifier? getCommentLikeNotifier(
  //     String commentId, NotifierType notifierType) {
  //   return _categoriesNotifiers.getData(commentId, forWhich: notifierType);
  // }

  UserProfileNotifier? getPostProfileNotifier(
      String membersId, NotifierType notifierType) {
    return _userPostNotifier.getData(membersId, forWhich: notifierType);
  }

  Future<List<UserProfileNotifier?>> _fetchCreatedByUserProfileNotifier(
      List<Map<String, dynamic>> allParts, NotifierType notifierType) async {
    return await Future.wait([
      ...(allParts
          .asMap()
          .map((key, value) {
            String memberId = value[dbReference(Parts.added_by)];
            return MapEntry(
                key, createAUserProfileNotifier(memberId, notifierType));
          })
          .values
          .toList())
    ]);
  }

  Future<List<UserProfileNotifier?>> _fetchEditedByUserProfileNotifier(
      List<Map<String, dynamic>> allParts, NotifierType notifierType) async {
    return await Future.wait([
      ...(allParts
          .asMap()
          .map((key, value) {
            String memberId = value[dbReference(Parts.edited_by)];
            return MapEntry(
                key, createAUserProfileNotifier(memberId, notifierType));
          })
          .values
          .toList())
    ]);
  }

  Future<UserProfileNotifier?> createAUserProfileNotifier(
      String memberId, NotifierType notifierType) async {
    if (!_userPostNotifier.containIdentity(memberId, notifierType)) {
      UserProfileNotifier userProfileNotifier =
          UserProfileNotifier().attachMembersId(memberId, startFetching: true);
      _userPostNotifier.addReplacementData(
          memberId, notifierType, userProfileNotifier);
      return _userPostNotifier.getData(memberId, forWhich: notifierType);
    } else {
      UserProfileNotifier? userProfileNotifier =
          _userPostNotifier.getData(memberId, forWhich: notifierType);
      return userProfileNotifier;
    }
  }

  Future<List<List<MediaData>>> _fetchPartsMedia(
      List<Map<String, dynamic>> allPosts) async {
    final postMedia = allPosts.map((value) async {
      String partsId = value[dbReference(Parts.id)];
      List<FileObject> mediaFiles =
          await CategoryOperation().getMediaFiles(partsId);
      return mediaFiles
          .asMap()
          .map((key, mediaFile) {
            MediaData parsedData =
                CategoryOperation().getParsedData(partsId, mediaFile);
            return MapEntry(key, parsedData);
          })
          .values
          .toList();
    }).toList();

    return Future.wait(postMedia);
  }

  void updateLatestData(List<PartsData> allParts) {
    _data.addAll(allParts);
    _data.sort((a, b) {
      final aDate = DateTime.tryParse(a.partsCreatedAt);
      final bDate = DateTime.tryParse(b.partsCreatedAt);

      if (aDate == null || bDate == null) {
        return 0;
      }
      return aDate.isBefore(bDate) ? 1 : 0;
    });
  }

  PartsImplement? getPartsImplement() {
    return _partsImplement;
  }

  void requestPaginate({bool canForceRetry = false}) {
    if (started) {
      if (canForceRetry) {
        getPartsImplement()?.getRetryStreamListener()?.sendForcedRetry();
      }
      _fetchPartsOnline();
    }
  }

  void getLatestPostReceived(String? time) async {
    if (time != null) {
      partsFromTime = time;
      saveLastPostTimeChecked(time);
    }
  }

  Future<bool> saveLastPostTimeChecked(String time) async {
    return false;
    return CacheOperation().saveCacheData("", "", time);
  }

  void _configure(List<PartsData> allParts, bool online) {
    if (allParts.isEmpty && getLatestData().isEmpty && !_fromStart && online) {
      _fromStart = true;
      requestPaginate(canForceRetry: true);
      return;
    }

    List<String> partsIds = getLatestData().map((e) => e.partsId).toList();

    allParts.removeWhere((element) => partsIds.contains(element.partsId));

    partsIds.addAll(allParts.map((e) => e.partsId).toList());

    int partsSize = allParts.length;

    // if (partsSize <= 0 && getLatestData().isNotEmpty) {
    //   getLatestPostReceived(getLatestData().firstOrNull?.partsCreatedAt);
    // } else {
    // }

    updateLatestData(allParts);
    getLatestPostReceived(allParts.lastOrNull?.partsCreatedAt);
    sendNewUpdateToUi();
  }

  void sendNewUpdateToUi() {
    state.sendNewState(_data.reversed.toList());

    CategoryNotifier().handlePartNotifier(_categoryId, _data.isNotEmpty);
    saveLatestComment();
  }

  Future<void> saveLatestComment() async {
    if (_data.isNotEmpty) {
      Map mapData = {
        for (var element in _data) element.partsId: element.toJson()
      };
      await CacheOperation().saveCacheData("", "", mapData);
    }
  }

  void _fetchPartsOnline() async {
    if (_categoryId == null) {
      return null;
    }
    try {
      _getPartLinkedData(
          (await PartsOperation().getPartsData(
                  _categoryId!, partsFromTime, _fromStart, 4,
                  limitBy: 30))
              .toList(),
          NotifierType.normal);
    } catch (e) {
      _configure(getLatestData(), true);
    }
  }

  void addNewPart(Map<String, dynamic> partsData) {
    _getPartLinkedData([partsData], NotifierType.normal);
  }

  Future<List<PartsData>> getPublicPartData(
      List<Map<String, dynamic>> allParts, NotifierType notifierType) async {
    return await _getPartLinkedData(allParts, notifierType);
  }

  Future<List<PartsData>> _getPartLinkedData(
      List<Map<String, dynamic>> allParts, NotifierType notifierType) async {
    _partsImplement?.getPaginationProgressController()?.sendNewState(false);
    for (var element in partsImplements) {
      element.getPaginationProgressController()?.sendNewState(false);
    }

    _fetchCreatedByUserProfileNotifier(allParts, notifierType);
    _fetchEditedByUserProfileNotifier(
        allParts
            .where((element) => element[dbReference(Parts.edited_by)] != null)
            .toList(),
        notifierType);
    final parsMediaList = await _fetchPartsMedia(allParts);
    List<PartsData> parts = allParts
        .asMap()
        .map((key, value) {
          List<MediaData> postMedia = parsMediaList[key];
          return MapEntry(key, PartsData.fromOnline(value, postMedia));
        })
        .values
        .toList();
    if (notifierType == NotifierType.normal) {
      _configure(parts, true);
    }
    return parts;
  }

  List<PartsData> getLatestData() {
    return _data.reversed.toList();
  }

  void _retryListener() {
    restart();
  }

  void addImplements(PartsImplement partsImplement) {
    partsImplements.add(partsImplement);
    RetryStreamListener? retryStreamListener =
        partsImplement.getRetryStreamListener();
    retryStreamListener?.addListener(_retryListener);
  }

  void removeImplements(PartsImplement partsImplement) {
    partsImplements.removeWhere((element) => element == partsImplement);
    partsImplement.getRetryStreamListener()?.removeListener(_retryListener);
  }

  void _attachListeners(PartsImplement partsImplement) {
    RetryStreamListener? retryStreamListener =
        partsImplement.getRetryStreamListener();
    retryStreamListener?.addListener(_retryListener);
  }

  void restart() {
    if (started) {
      _fetchPartsOnline();
    }
  }

  void stop() {
    getPartsImplement()
        ?.getRetryStreamListener()
        ?.removeListener(_retryListener);
  }

  void updateThePartMediaData(String partsID, List<MediaData> list) {
    int found = _data.indexWhere((element) => element.partsId == partsID);

    if (found != -1) {
      _data[found] = _data[found].copyWith(
        partsMedia: list,
      );
      sendNewUpdateToUi();
    }
  }

  void updatePartsData(Map<String, dynamic> partsData) {
    int found = _data.indexWhere(
        (element) => element.partsId == partsData[dbReference(Parts.id)]);
    if (found != -1) {
      PartsData data = PartsData.fromOnline(partsData, _data[found].partsMedia);
      _data[found] = data;
      sendNewUpdateToUi();
    }
  }

  PartsData? movePartsData(Map<String, dynamic> partsData) {
    int found = _data.indexWhere(
        (element) => element.partsId == partsData[dbReference(Parts.id)]);
    if (found != -1) {
      PartsData data = PartsData.fromOnline(partsData, _data[found].partsMedia);
      _data.removeAt(found);
      sendNewUpdateToUi();
      return data;
    }
    return null;
  }

  void pasteMoveData(PartsData getMoveData) {
    _data.add(getMoveData);
    sendNewUpdateToUi();
  }

  void deleteTheParts(String partsData) {
    int found = _data.indexWhere((element) => element.partsId == partsData);
    if (found != -1) {
      _data.removeAt(found);
      sendNewUpdateToUi();
    }
  }
}
