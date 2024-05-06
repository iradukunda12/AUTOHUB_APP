import 'package:flutter/material.dart';
import 'package:open_document/my_files/init.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../Utils/VersionUtils.dart';
import '../data/UpdateInfo.dart';
import '../pages/UpdatePage.dart';

class UpdateInfoConsumer extends StatefulWidget {
  final WidgetStateNotifier<UpdateInfo> updateAppInfoNotifier;
  final Widget child;

  const UpdateInfoConsumer(
      {super.key, required this.updateAppInfoNotifier, required this.child});

  @override
  State<UpdateInfoConsumer> createState() => _UpdateInfoConsumerState();
}

class _UpdateInfoConsumerState extends State<UpdateInfoConsumer> {
  StreamSubscription? streamSubscription;

  bool pushed = false;

  @override
  void initState() {
    super.initState();
    handleVersionUtil(widget.updateAppInfoNotifier.currentValue);
    streamSubscription ??= widget.updateAppInfoNotifier.stream.listen((event) {
      handleVersionUtil(event);
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription?.cancel();
  }

  void handleVersionUtil(UpdateInfo? updateInfo) async {
    if (updateInfo == null) return;
    final packageInfo = await PackageInfo.fromPlatform();
    String oldIosVersion = packageInfo.version;
    String oldAndroidVersion = packageInfo.version;

    String newIosVersion = updateInfo.iosVersion!;
    String newAndroidVersion = updateInfo.androidVersion!;

    int iosUpdated = VersionUtils.compareVersions(oldIosVersion, newIosVersion);
    int androidUpdated =
        VersionUtils.compareVersions(oldAndroidVersion, newAndroidVersion);

    if (Platform.isIOS && iosUpdated < 0) {
      triggerIosUpdate(updateInfo, packageInfo);
    } else if (Platform.isAndroid && androidUpdated < 0) {
      triggerAndroidUpdate(updateInfo, packageInfo);
    }
  }

  void triggerIosUpdate(UpdateInfo updateInfo, PackageInfo packageInfo) {
    if (!pushed) {
      pushed = true;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UpdatePage(
                    updateInfo: updateInfo.copyWith(
                        iosInstalledVersion: packageInfo.version),
                    onOpened: () {
                      pushed = true;
                    },
                  ))).then((value) {
        pushed = false;
      });
    } else {
      Navigator.pop(context);
      pushed = false;
      triggerIosUpdate(updateInfo, packageInfo);
    }
  }

  void triggerAndroidUpdate(UpdateInfo updateInfo, PackageInfo packageInfo) {
    if (!pushed) {
      pushed = true;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UpdatePage(
                    updateInfo: updateInfo.copyWith(
                        androidInstalledVersion: packageInfo.version),
                    onOpened: () {
                      pushed = true;
                    },
                  ))).then((value) {
        pushed = false;
      });
    } else {
      Navigator.pop(context);
      pushed = false;
      triggerAndroidUpdate(updateInfo, packageInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
