// ignore_for_file: constant_identifier_names

import 'package:autohub/data/ServicesData.dart';
import 'package:autohub/data_notifier/CategoryNotifier.dart';
import 'package:autohub/operation/CategoryOperation.dart';
import 'package:autohub/operation/ServicesOperation.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../builders/ControlledStreamBuilder.dart';
import '../builders/CustomWrapListBuilder.dart';
import '../components/CustomProject.dart';
import '../data/MediaData.dart';
import '../data/NotifierDataClass.dart';
import '../db_references/NotifierType.dart';
import '../db_references/Services.dart';
import '../operation/CacheOperation.dart';
import 'UserProfileNotifier.dart';

class ServicesStack {
  int? _currentStack;

  int getStack(BuildContext context) {
    _currentStack ??= ServicesNotifier().stack.length;
    return _currentStack!;
  }
}

class ServicesImplement {
  BuildContext? getLatestContext() => null;

  RetryStreamListener? getRetryStreamListener() => null;

  PaginationProgressController? getPaginationProgressController() => null;
}

class ServicesNotifier {
  WidgetStateNotifier<List<ServicesData>> state = WidgetStateNotifier();

  final List<ServicesData> _data = [];

  // final NotifierDataClass<CategoryNotifier?, NotifierType>
  // _categoriesNotifiers = NotifierDataClass();

  final NotifierDataClass<UserProfileNotifier?, NotifierType>
      _userPostNotifier = NotifierDataClass();

  String? _categoryId;

  List<int> stack = [];
  ServicesImplement? _servicesImplement;
  List<ServicesImplement> servicesImplements = [];

  bool started = false;
  bool _fromStart = false;
  String partsFromTime = DateTime.now().toUtc().toString();

  ServicesNotifier attachCategoryId(String categoryId,
      {bool startFetching = false}) {
    _categoryId = categoryId;
    if (startFetching) {
      _startFetching();
    }
    return this;
  }

  ServicesNotifier start(ServicesImplement partsImplement,
      ServicesStack partsStack, String categoryId) {
    BuildContext? buildContext = partsImplement.getLatestContext();
    if (buildContext != null && _categoryId == categoryId) {
      _servicesImplement = partsImplement;
      _attachListeners(partsImplement);
      _startFetching();
    }
    return this;
  }

  Future<void> _startFetching() async {
    started = true;
    _fetchPartsLocal();
    _fetchServicesOnline();
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
            String memberId = value[dbReference(Services.added_by)];
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
            String memberId = value[dbReference(Services.edited_by)];
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

  Future<List<List<MediaData>>> _fetchServiceMedia(
      List<Map<String, dynamic>> allPosts) async {
    final postMedia = allPosts.map((value) async {
      String serviceId = value[dbReference(Services.id)];
      List<FileObject> mediaFiles =
          await CategoryOperation().getMediaFiles(serviceId);
      return mediaFiles
          .asMap()
          .map((key, mediaFile) {
            MediaData parsedData =
                CategoryOperation().getParsedData(serviceId, mediaFile);
            return MapEntry(key, parsedData);
          })
          .values
          .toList();
    }).toList();

    return Future.wait(postMedia);
  }

  void updateLatestData(List<ServicesData> allServices) {
    _data.addAll(allServices);
    _data.sort((a, b) {
      final aDate = DateTime.tryParse(a.servicesCreateAt);
      final bDate = DateTime.tryParse(b.servicesCreateAt);

      if (aDate == null || bDate == null) {
        return 0;
      }
      return aDate.isBefore(bDate) ? 1 : 0;
    });
  }

  ServicesImplement? getPartsImplement() {
    return _servicesImplement;
  }

  void requestPaginate({bool canForceRetry = false}) {
    if (started) {
      if (canForceRetry) {
        getPartsImplement()?.getRetryStreamListener()?.sendForcedRetry();
      }
      _fetchServicesOnline();
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

  void _configure(List<ServicesData> allServices, bool online) {
    if (allServices.isEmpty &&
        getLatestData().isEmpty &&
        !_fromStart &&
        online) {
      _fromStart = true;
      requestPaginate(canForceRetry: true);
      return;
    }

    List<String> partsIds = getLatestData().map((e) => e.servicesId).toList();

    allServices.removeWhere((element) => partsIds.contains(element.servicesId));

    partsIds.addAll(allServices.map((e) => e.servicesId).toList());

    int partsSize = allServices.length;

    // if (partsSize <= 0 && getLatestData().isNotEmpty) {
    //   getLatestPostReceived(getLatestData().firstOrNull?.servicesCreateAt);
    // } else {
    // }

    updateLatestData(allServices);
    getLatestPostReceived(allServices.lastOrNull?.servicesCreateAt);
    sendNewUpdateToUi();
  }

  void sendNewUpdateToUi() {
    state.sendNewState(_data.reversed.toList());
    CategoryNotifier().handleServicesNotifier(_categoryId, _data.isNotEmpty);
    saveLatestComment();
  }

  Future<void> saveLatestComment() async {
    if (_data.isNotEmpty) {
      Map mapData = {
        for (var element in _data) element.servicesId: element.toJson()
      };
      await CacheOperation().saveCacheData("", "", mapData);
    }
  }

  void _fetchServicesOnline() async {
    if (_categoryId == null) {
      return null;
    }
    try {
      _getServiceLinkedData(
          (await ServicesOperation().getServicesData(
                  _categoryId!, partsFromTime, _fromStart, 4,
                  limitBy: 30))
              .toList(),
          NotifierType.normal);
    } catch (e) {
      _configure(getLatestData(), true);
    }
  }

  void addNewService(Map<String, dynamic> serviceData) {
    _getServiceLinkedData([serviceData], NotifierType.normal);
  }

  Future<List<ServicesData>> getPublicServiceData(
      PostgrestList value, NotifierType external) async {
    return await _getServiceLinkedData(value, external);
  }

  Future<List<ServicesData>> _getServiceLinkedData(
      List<Map<String, dynamic>> allParts, NotifierType notifierType) async {
    _servicesImplement?.getPaginationProgressController()?.sendNewState(false);
    for (var element in servicesImplements) {
      element.getPaginationProgressController()?.sendNewState(false);
    }
    _fetchCreatedByUserProfileNotifier(allParts, notifierType);
    _fetchEditedByUserProfileNotifier(
        allParts
            .where(
                (element) => element[dbReference(Services.edited_by)] != null)
            .toList(),
        notifierType);
    final parsMediaList = await _fetchServiceMedia(allParts);
    List<ServicesData> services = allParts
        .asMap()
        .map((key, value) {
          List<MediaData> postMedia = parsMediaList[key];
          return MapEntry(key, ServicesData.fromOnline(value, postMedia));
        })
        .values
        .toList();
    if (notifierType == NotifierType.normal) {
      _configure(services, true);
    }
    return services;
  }

  List<ServicesData> getLatestData() {
    return _data.reversed.toList();
  }

  void _retryListener() {
    restart();
  }

  void addImplements(ServicesImplement partsImplement) {
    servicesImplements.add(partsImplement);
    RetryStreamListener? retryStreamListener =
        partsImplement.getRetryStreamListener();
    retryStreamListener?.addListener(_retryListener);
  }

  void removeImplements(ServicesImplement partsImplement) {
    servicesImplements.removeWhere((element) => element == partsImplement);
    partsImplement.getRetryStreamListener()?.removeListener(_retryListener);
  }

  void _attachListeners(ServicesImplement partsImplement) {
    RetryStreamListener? retryStreamListener =
        partsImplement.getRetryStreamListener();
    retryStreamListener?.addListener(_retryListener);
  }

  void restart() {
    if (started) {
      _fetchServicesOnline();
    }
  }

  void stop() {
    getPartsImplement()
        ?.getRetryStreamListener()
        ?.removeListener(_retryListener);
  }

  void updateTheServiceMediaData(String servicesID, List<MediaData> list) {
    int found = _data.indexWhere((element) => element.servicesId == servicesID);

    if (found != -1) {
      _data[found] = _data[found].copyWith(
        servicesMedia: list,
      );
      sendNewUpdateToUi();
    }
  }

  void updateServiceData(Map<String, dynamic> servicesData) {
    int found = _data.indexWhere((element) =>
        element.servicesId == servicesData[dbReference(Services.id)]);
    if (found != -1) {
      ServicesData data =
          ServicesData.fromOnline(servicesData, _data[found].servicesMedia);
      _data[found] = data;
      sendNewUpdateToUi();
    }
  }

  ServicesData? moveServiceData(Map<String, dynamic> servicesData) {
    int found = _data.indexWhere((element) =>
        element.servicesId == servicesData[dbReference(Services.id)]);
    if (found != -1) {
      ServicesData data =
          ServicesData.fromOnline(servicesData, _data[found].servicesMedia);
      _data.removeAt(found);
      sendNewUpdateToUi();
      return data;
    }
    return null;
  }

  void pasteMoveData(ServicesData getMoveData) {
    _data.add(getMoveData);
    sendNewUpdateToUi();
  }

  void deleteTheServices(String servicesId) {
    int found = _data.indexWhere((element) => element.servicesId == servicesId);
    if (found != -1) {
      _data.removeAt(found);
      sendNewUpdateToUi();
    }
  }
}
