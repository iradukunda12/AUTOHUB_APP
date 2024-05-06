// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:autohub/data/CategoryData.dart';
import 'package:autohub/data/PartsData.dart';
import 'package:autohub/data/ServicesData.dart';
import 'package:autohub/data_notifier/PartsNotifier.dart';
import 'package:autohub/data_notifier/ServicesNotifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_document/my_files/init.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../builders/ControlledStreamBuilder.dart';
import '../builders/CustomWrapListBuilder.dart';
import '../components/CustomProject.dart';
import '../data/NotifierDataClass.dart';
import '../db_references/Category.dart';
import '../db_references/NotifierType.dart';
import '../db_references/Parts.dart';
import '../db_references/Services.dart';
import '../operation/CacheOperation.dart';
import '../operation/CategoryOperation.dart';
import 'UserProfileNotifier.dart';

class CategoryImplement {
  BuildContext? getLatestContext() => null;

  RetryStreamListener? getRetryStreamListener() => null;

  PaginationProgressController? getPaginationProgressController() => null;
}

class CategoryNotifier {
  static final CategoryNotifier instance = CategoryNotifier.internal();

  factory CategoryNotifier() => instance;

  CategoryNotifier.internal();

  WidgetStateNotifier<List<CategoryData>> state = WidgetStateNotifier();

  final List<CategoryData> _data = [];

  CategoryImplement? _categoryImplement;
  List<CategoryImplement> categoryImplement = [];

  bool started = false;

  bool _fromStart = false;
  String categoryFromTime = DateTime.now().toUtc().toString();

  WidgetStateNotifier<List<CategoryData>> partsDataNotifier =
      WidgetStateNotifier();
  WidgetStateNotifier<List<CategoryData>> servicesDataNotifier =
      WidgetStateNotifier();

  final NotifierDataClass<PartsNotifier?, NotifierType> _partsNotifiers =
      NotifierDataClass();

  final NotifierDataClass<ServicesNotifier?, NotifierType> _servicesNotifiers =
      NotifierDataClass();
  final NotifierDataClass<UserProfileNotifier?, NotifierType>
      _userPostNotifier = NotifierDataClass();

  CategoryNotifier start(CategoryImplement categoryImplement) {
    BuildContext? buildContext = categoryImplement.getLatestContext();
    if (buildContext != null) {
      _categoryImplement = categoryImplement;
      _attachListeners(categoryImplement);
      _startFetching();
    }
    return this;
  }

  CategoryImplement? getPartsImplement() {
    return _categoryImplement;
  }

  void _startFetching() {
    started = true;
    _fetchLocalPostProfile();
    _fetchCategoryOnline();
  }

  void requestPaginate({bool canForceRetry = false}) {
    if (started) {
      if (canForceRetry) {
        getPartsImplement()?.getRetryStreamListener()?.sendForcedRetry();
      }
      _fetchCategoryOnline();
    }
  }

  void getLatestPostReceived(String? time) async {
    if (time != null) {
      categoryFromTime = time;
      saveLastPostTimeChecked(time);
    }
  }

  Future<bool> saveLastPostTimeChecked(String time) async {
    return false;
    return CacheOperation().saveCacheData("", "", time);
  }

  List<CategoryData> getLatestData() {
    return _data;
  }

  void _retryListener() {
    restart();
  }

  void _attachListeners(CategoryImplement commentImplement) {
    RetryStreamListener? retryStreamListener =
        commentImplement.getRetryStreamListener();
    retryStreamListener?.addListener(_retryListener);
  }

  void addImplements(CategoryImplement commentImplement) {
    categoryImplement.add(commentImplement);
    RetryStreamListener? retryStreamListener =
        commentImplement.getRetryStreamListener();
    retryStreamListener?.addListener(_retryListener);
  }

  void removeImplements(CategoryImplement commentImplement) {
    categoryImplement.removeWhere((element) => element == commentImplement);
    commentImplement.getRetryStreamListener()?.removeListener(_retryListener);
  }

  void restart() {
    if (started) {
      _fetchCategoryOnline();

      partsDataNotifier.currentValue?.forEach((element) {
        _partsNotifiers.getData(element.categoryId,
            forWhich: NotifierType.normal);
      });
    }
  }

  void stop() {
    _categoryImplement
        ?.getRetryStreamListener()
        ?.removeListener(_retryListener);
  }

  Future<void> _fetchCategoryOnline() async {
    try {
      _getCategoryLinkedData(
          (await CategoryOperation().getCategoryData(
                  categoryFromTime, _fromStart, 4,
                  limitBy: 20))
              .toList(),
          NotifierType.normal);
    } catch (e) {
      sendUpdateToUi(_data);
      partsDataNotifier.sendNewState(partsDataNotifier.currentValue ?? []);
      servicesDataNotifier
          .sendNewState(servicesDataNotifier.currentValue ?? []);
    }
  }

  Future<List<UserProfileNotifier?>> _fetchCreatedByUserProfileNotifier(
      List<Map<String, dynamic>> allCategory, NotifierType notifierType) async {
    return await Future.wait([
      ...(allCategory
          .asMap()
          .map((key, value) {
            String memberId = value[dbReference(Category.created_by)];
            return MapEntry(
                key, createAUserProfileNotifier(memberId, notifierType));
          })
          .values
          .toList())
    ]);
  }

  UserProfileNotifier? getPostProfileNotifier(
      String membersId, NotifierType notifierType) {
    return _userPostNotifier.getData(membersId, forWhich: notifierType);
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

  void _getCategoryLinkedData(
      List<Map<String, dynamic>> allParts, NotifierType notifierType) async {
    _categoryImplement?.getPaginationProgressController()?.sendNewState(false);

    for (var element in categoryImplement) {
      element.getPaginationProgressController()?.sendNewState(false);
    }

    _fetchCreatedByUserProfileNotifier(allParts, notifierType);
    _fetchPartsNotifier(
        allParts.where((element) {
          dynamic type = element[dbReference(Category.for_which)];
          return type == dbReference(dbReference(Category.parts)) ||
              type == dbReference(dbReference(Category.all));
        }).toList(),
        NotifierType.normal);

    _fetchServicesNotifier(
        allParts.where((element) {
          dynamic type = element[dbReference(Category.for_which)];
          return type == dbReference(dbReference(Category.services)) ||
              type == dbReference(dbReference(Category.all));
        }).toList(),
        NotifierType.normal);

    List<CategoryData> categories = allParts
        .asMap()
        .map((key, value) {
          return MapEntry(key, CategoryData.fromOnline(value));
        })
        .values
        .toList();

    _configure(categories, true);
  }

  void _fetchLocalPostProfile() async {
    // final savedPostProfileData = await CacheOperation().getCacheData(
    //     "", _memberId!,
    //     fromWhere: _fromWhere);

    // if (savedPostProfileData != null) {
    //   final postProfileData = UserProfileData.fromJson(savedPostProfileData);
    //   _configure(postProfileData, false);
    // }
  }

  void updateLatestData(List<CategoryData> categories) {
    _data.addAll(categories);
    _data.sort((a, b) {
      final aDate = DateTime.tryParse(a.categoryCreatedAt);
      final bDate = DateTime.tryParse(b.categoryCreatedAt);

      if (aDate == null || bDate == null) {
        return 0;
      }
      return aDate.isBefore(bDate) ? 1 : 0;
    });
  }

  void _configure(List<CategoryData> allCategories, bool online) {
    if (allCategories.isEmpty &&
        getLatestData().isEmpty &&
        !_fromStart &&
        online) {
      _fromStart = true;
      requestPaginate(canForceRetry: true);
      return;
    }

    List<String> categoryIds =
        getLatestData().map((e) => e.categoryId).toList();

    allCategories
        .removeWhere((element) => categoryIds.contains(element.categoryId));

    categoryIds.addAll(allCategories.map((e) => e.categoryId).toList());

    int partsSize = allCategories.length;

    // if (partsSize <= 0 && getLatestData().isNotEmpty) {
    //   getLatestPostReceived(getLatestData().firstOrNull?.categoryCreatedAt);
    // } else {

    // }

    updateLatestData(allCategories);
    getLatestPostReceived(allCategories.lastOrNull?.categoryCreatedAt);
    sendUpdateToUi(allCategories);

    // saveLatestPostProfile();
  }

  void sendUpdateToUi(List<CategoryData> categories) {
    state.sendNewState(categories);
  }

  Future<void> saveLatestPostProfile() async {
    // if (_data != null) {
    //   await CacheOperation().saveCacheData(
    //       "", _memberId!, _data?.toJson(),
    //       fromWhere: _fromWhere);
    // }
  }

  Future<List<PartsNotifier?>> _fetchPartsNotifier(
      List<Map<String, dynamic>> allParts, NotifierType notifierType) async {
    return await Future.wait([
      ...(allParts
          .asMap()
          .map((key, value) {
            String categoryId = value[dbReference(Category.id)];
            return MapEntry(
                key, createAPartsNotifier(categoryId, notifierType));
          })
          .values
          .toList())
    ]);
  }

  PartsNotifier? getPartsNotifier(
      String categoryId, NotifierType notifierType) {
    return _partsNotifiers.getData(categoryId, forWhich: notifierType);
  }

  Future<PartsNotifier?> createAPartsNotifier(
      String categoryId, NotifierType notifierType) async {
    if (!_partsNotifiers.containIdentity(categoryId, notifierType)) {
      PartsNotifier partsNotifier =
          PartsNotifier().attachCategoryId(categoryId, startFetching: true);
      _partsNotifiers.addReplacementData(
          categoryId, notifierType, partsNotifier);
      return _partsNotifiers.getData(categoryId, forWhich: notifierType);
    } else {
      PartsNotifier? partsNotifier =
          _partsNotifiers.getData(categoryId, forWhich: notifierType);
      return partsNotifier;
    }
  }

  Future<List<ServicesNotifier?>> _fetchServicesNotifier(
      List<Map<String, dynamic>> allServices, NotifierType notifierType) async {
    return await Future.wait([
      ...(allServices
          .asMap()
          .map((key, value) {
            String categoryId = value[dbReference(Category.id)];
            return MapEntry(
                key, createAServicesNotifier(categoryId, notifierType));
          })
          .values
          .toList())
    ]);
  }

  ServicesNotifier? getServicesNotifier(
      String categoryId, NotifierType notifierType) {
    return _servicesNotifiers.getData(categoryId, forWhich: notifierType);
  }

  Future<ServicesNotifier?> createAServicesNotifier(
      String categoryId, NotifierType notifierType) async {
    if (!_servicesNotifiers.containIdentity(categoryId, notifierType)) {
      ServicesNotifier servicesNotifier =
          ServicesNotifier().attachCategoryId(categoryId, startFetching: true);
      _servicesNotifiers.addReplacementData(
          categoryId, notifierType, servicesNotifier);
      return _servicesNotifiers.getData(categoryId, forWhich: notifierType);
    } else {
      ServicesNotifier? servicesNotifier =
          _servicesNotifiers.getData(categoryId, forWhich: notifierType);
      return servicesNotifier;
    }
  }

  void addNewCategory(CategoryData categoryData) {
    List<String> categoryIds =
        getLatestData().map((e) => e.categoryId).toList();

    if (!categoryIds.contains(categoryData.categoryId)) {
      _data.add(categoryData);
      sendUpdateToUi(_data);
    }
  }

  void updateCategory(CategoryData oldCategory, CategoryData newCategoryData) {
    int found = _data
        .indexWhere((element) => element.categoryId == oldCategory.categoryId);

    if (found != -1) {
      // Handle parts

      if (newCategoryData.categoryFor == dbReference(Category.parts) ||
          newCategoryData.categoryFor == dbReference(Category.all)) {
        int foundPart = partsDataNotifier.currentValue?.indexWhere((element) =>
                element.categoryId == newCategoryData.categoryId) ??
            -1;

        if (foundPart != -1) {
          _data[found] = newCategoryData;
          partsDataNotifier.currentValue![foundPart] = newCategoryData;
          partsDataNotifier.sendNewState(partsDataNotifier.currentValue);
          sendUpdateToUi(_data);
        }
      }

      // Handle services

      if (newCategoryData.categoryFor == dbReference(Category.services) ||
          newCategoryData.categoryFor == dbReference(Category.all)) {
        int foundPart = servicesDataNotifier.currentValue?.indexWhere(
                (element) =>
                    element.categoryId == newCategoryData.categoryId) ??
            -1;

        if (foundPart != -1) {
          _data[found] = newCategoryData;
          servicesDataNotifier.currentValue![foundPart] = newCategoryData;
          servicesDataNotifier.sendNewState(servicesDataNotifier.currentValue);
          sendUpdateToUi(_data);
        }
      }
    }
  }

  final List<String> _handledParts = [];

  void handlePartNotifier(String? categoryId, bool isNotEmpty) {
    bool notHandled = true;

    if (categoryId != null) {
      int found = partsDataNotifier.currentValue
              ?.map((e) => e.categoryId)
              .toList()
              .indexOf(categoryId) ??
          -1;

      if (isNotEmpty && found == -1) {
        //   Newly added
        int index = _data.map((e) => e.categoryId).toList().indexOf(categoryId);
        if (index != -1) {
          partsDataNotifier.currentValue ??= [];
          partsDataNotifier.currentValue?.add(_data.elementAt(index));
          partsDataNotifier.sendNewState(partsDataNotifier.currentValue);
          notHandled = false;
        }
      } else if (!isNotEmpty && found != -1) {
        //   Remove empty
        partsDataNotifier.currentValue?.removeAt(found);
        partsDataNotifier.sendNewState(partsDataNotifier.currentValue);
      }

      if (!_handledParts.contains(categoryId)) {
        _handledParts.add(categoryId);
      }
    }

    if (notHandled) {
      bool handledAll = true;
      List<String> ids = _data
          .where((element) =>
              element.categoryFor == dbReference(Category.parts) ||
              element.categoryFor == dbReference(Category.all))
          .map((e) => e.categoryId)
          .toList();

      int index = 0;
      while (handledAll && index < ids.length) {
        handledAll = !(getPartsNotifier(ids[index], NotifierType.normal)
                ?.getLatestData()
                .isNotEmpty ==
            true);
        index++;
      }

      if (handledAll && _handledParts.length == ids.length) {
        partsDataNotifier.sendNewState([]);
      }
    }
  }

  final List<String> _handledServices = [];

  void handleServicesNotifier(String? categoryId, bool isNotEmpty) {
    bool notHandled = true;

    if (categoryId != null) {
      int found = servicesDataNotifier.currentValue
              ?.map((e) => e.categoryId)
              .toList()
              .indexOf(categoryId) ??
          -1;

      if (isNotEmpty && found == -1) {
        //   Newly added
        int index = _data.map((e) => e.categoryId).toList().indexOf(categoryId);
        if (index != -1) {
          servicesDataNotifier.currentValue ??= [];
          servicesDataNotifier.currentValue?.add(_data.elementAt(index));
          servicesDataNotifier.sendNewState(servicesDataNotifier.currentValue);
          notHandled = false;
        }
      } else if (!isNotEmpty && found != -1) {
        //   Remove empty
        servicesDataNotifier.currentValue?.removeAt(found);
        servicesDataNotifier.sendNewState(servicesDataNotifier.currentValue);
      }

      if (!_handledServices.contains(categoryId)) {
        _handledServices.add(categoryId);
      }
    }

    if (notHandled) {
      bool handledAll = true;
      List<String> ids = _data
          .where((element) =>
              element.categoryFor == dbReference(Category.services) ||
              element.categoryFor == dbReference(Category.all))
          .map((e) => e.categoryId)
          .toList();

      int index = 0;
      while (handledAll && index < ids.length) {
        handledAll = !(getServicesNotifier(ids[index], NotifierType.normal)
                ?.getLatestData()
                .isNotEmpty ==
            true);
        index++;
      }

      if (handledAll && _handledServices.length == ids.length) {
        servicesDataNotifier.sendNewState([]);
      }
    }
  }

  void processPartsData(String categoryId, NotifierType normal,
      Map<String, dynamic> partsData) async {
    final partsNotifier =
        await createAPartsNotifier(categoryId, NotifierType.normal);
    if (partsNotifier != null) {
      partsNotifier.addNewPart(partsData);
    }
  }

  void processServicesData(String categoryId, NotifierType normal,
      Map<String, dynamic> serviceData) async {
    final serviceNotifier =
        await createAServicesNotifier(categoryId, NotifierType.normal);
    if (serviceNotifier != null) {
      serviceNotifier.addNewService(serviceData);
    }
  }

  CategoryData? getCategoryData(String partsCategoryId) {
    return _data
        .where((element) => element.categoryId == partsCategoryId)
        .singleOrNull;
  }

  void updatePartsData(String categoryId, NotifierType notifierType,
      Map<String, dynamic> partsData) {
    String newCategoryId = partsData[dbReference(Parts.category_id)];

    PartsNotifier? partsNotifier = getPartsNotifier(categoryId, notifierType);

    if (newCategoryId != categoryId) {
      PartsData? getMoveData = partsNotifier?.movePartsData(partsData);

      if (getMoveData != null) {
        getPartsNotifier(newCategoryId, notifierType)
            ?.pasteMoveData(getMoveData);
      }
    } else {
      partsNotifier?.updatePartsData(partsData);
    }
  }

  void updateServicesData(String categoryId, NotifierType notifierType,
      Map<String, dynamic> servicesData) {
    String newCategoryId = servicesData[dbReference(Services.category_id)];

    ServicesNotifier? servicesNotifier =
        getServicesNotifier(categoryId, notifierType);

    if (newCategoryId != categoryId) {
      ServicesData? getMoveData =
          servicesNotifier?.moveServiceData(servicesData);

      if (getMoveData != null) {
        getServicesNotifier(newCategoryId, notifierType)
            ?.pasteMoveData(getMoveData);
      }
    } else {
      servicesNotifier?.updateServiceData(servicesData);
    }
  }

  void removeThisCategory(CategoryData categoryData) {
    int found = _data
        .indexWhere((element) => element.categoryId == categoryData.categoryId);

    // Found the category
    if (found != -1) {
      // Check Part
      int foundInPart = (partsDataNotifier.currentValue ?? []).indexWhere(
          (element) => element.categoryId == categoryData.categoryId);
      if (foundInPart != -1) {
        getPartsNotifier(categoryData.categoryId, NotifierType.normal)
            ?.updateLatestData([]);
        partsDataNotifier.currentValue!.removeAt(foundInPart);
        partsDataNotifier.sendNewState(partsDataNotifier.currentValue);
      }
      // Check Service
      int foundInService = (servicesDataNotifier.currentValue ?? []).indexWhere(
          (element) => element.categoryId == categoryData.categoryId);
      if (foundInPart != -1) {
        getPartsNotifier(categoryData.categoryId, NotifierType.normal)
            ?.updateLatestData([]);
        servicesDataNotifier.currentValue!.removeAt(foundInPart);
        servicesDataNotifier.sendNewState(partsDataNotifier.currentValue);
      }

      _data.removeAt(found);
      sendUpdateToUi(_data);
    }
  }
}
