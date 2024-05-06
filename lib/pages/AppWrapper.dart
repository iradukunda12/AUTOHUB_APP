import 'package:autohub/components/PrivacyPolicyConsumer.dart';
import 'package:autohub/components/UpdateInfoConsumer.dart';
import 'package:flutter/cupertino.dart';

import '../local_navigation_controller.dart';
import '../services/AppFileService.dart';
import '../services/MainService.dart';

class AppWrapper extends StatefulWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    AppFileService().beginService();
    MainService().startService();
    LocalNavigationController()
        .addNavigatorKey(LocalNavigationController.useNavigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    return UpdateInfoConsumer(
        updateAppInfoNotifier: MainService().updateAppInfoNotifier,
        child: PrivacyPolicyConsumer(
            privacyPolicyNotifier: MainService().changedPrivacyNotifier,
            child: widget.child));
  }
}
