// import 'package:autohub/components/CustomProject.dart';
// import 'package:flutter/material.dart';
// import 'package:open_document/my_files/init.dart';
//
// class IosCustomSafeAreaConfig {
//   final double maxTopLength;
//   final double maxBottomLength;
//   final double maxLeftLength;
//   final double maxRightLength;
//   final double percentage;
//   final bool top;
//   final bool bottom;
//   final bool left;
//   final bool right;
//   final Color? color;
//
//   const IosCustomSafeAreaConfig(
//       {this.maxTopLength = 50,
//       this.percentage = 5,
//       this.top = true,
//       this.bottom = true,
//       this.left = false,
//       this.right = false,
//       this.maxBottomLength = 50,
//       this.maxLeftLength = 16,
//       this.maxRightLength = 16,
//       this.color = Colors.white});
//
//   static const defaultConfig = IosCustomSafeAreaConfig();
// }
//
// class AndroidCustomSafeAreConfig {
//   final bool top;
//   final bool bottom;
//   final bool left;
//   final bool right;
//   final EdgeInsets minimum;
//   final bool maintainBottomViewPadding;
//
//   const AndroidCustomSafeAreConfig(
//       {this.left = true,
//       this.top = true,
//       this.right = true,
//       this.bottom = true,
//       this.minimum = EdgeInsets.zero,
//       this.maintainBottomViewPadding = false});
//
//   static const defaultConfig = AndroidCustomSafeAreConfig();
// }
//
// class CustomSafeArea extends StatelessWidget {
//   final Widget child;
//   final IosCustomSafeAreaConfig iosCustomSafeAreaConfig;
//   final AndroidCustomSafeAreConfig androidCustomSafeAreConfig;
//
//   const CustomSafeArea({
//     super.key,
//     this.iosCustomSafeAreaConfig = IosCustomSafeAreaConfig.defaultConfig,
//     this.androidCustomSafeAreConfig = AndroidCustomSafeAreConfig.defaultConfig,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (Platform.isAndroid) {
//       return SafeArea(
//           left: androidCustomSafeAreConfig.left,
//           right: androidCustomSafeAreConfig.right,
//           top: androidCustomSafeAreConfig.top,
//           bottom: androidCustomSafeAreConfig.bottom,
//           minimum: androidCustomSafeAreConfig.minimum,
//           maintainBottomViewPadding:
//               androidCustomSafeAreConfig.maintainBottomViewPadding,
//           child: child);
//     }
//
//     double getLength(double maxLength, double viewMetricLength, bool canLength,
//         double percentage) {
//       if (!canLength) return 0;
//
//       double length = (percentage / 100) * viewMetricLength;
//
//       if (length > maxLength) return maxLength;
//       return length;
//     }
//
//     double height = getScreenHeight(context);
//     double width = getScreenWidth(context);
//     return Container(
//       color:
//       iosCustomSafeAreaConfig.color ??
//           Theme.of(context).appBarTheme.backgroundColor
//       ,
//       padding: EdgeInsets.only(
//         top: getLength(iosCustomSafeAreaConfig.maxTopLength, height,
//             iosCustomSafeAreaConfig.top, iosCustomSafeAreaConfig.percentage),
//         bottom: getLength(
//             iosCustomSafeAreaConfig.maxBottomLength,
//             height,
//             iosCustomSafeAreaConfig.bottom,
//             iosCustomSafeAreaConfig.percentage - 2),
//         left: getLength(iosCustomSafeAreaConfig.maxLeftLength, width,
//             iosCustomSafeAreaConfig.left, iosCustomSafeAreaConfig.percentage),
//         right: getLength(iosCustomSafeAreaConfig.maxRightLength, width,
//             iosCustomSafeAreaConfig.right, iosCustomSafeAreaConfig.percentage),
//       ),
//       child: MediaQuery.removePadding(
//         context: context,
//         removeLeft: iosCustomSafeAreaConfig.left,
//         removeTop: iosCustomSafeAreaConfig.top,
//         removeRight: iosCustomSafeAreaConfig.right,
//         removeBottom: iosCustomSafeAreaConfig.bottom,
//         child: AnnotatedRegion(
//             value: SystemUiOverlayStyle(
//               systemNavigationBarColor: Colors.white,
//               systemNavigationBarDividerColor: Colors.transparent,
//               systemNavigationBarIconBrightness: Brightness.dark,
//               statusBarBrightness: Platform.isIOS ? Brightness.light : Brightness.light,
//               statusBarColor: Colors.grey.shade50,
//               statusBarIconBrightness: Platform.isIOS ? Brightness.light : Brightness.dark,
//             ),
//             child: child),
//       ),
//     );
//   }
// }
