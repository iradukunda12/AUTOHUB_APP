import 'package:autohub/components/CustomPrimaryButton.dart';
import 'package:autohub/components/CustomProject.dart';
import 'package:autohub/data/AppServiceData.dart';
import 'package:autohub/main.dart';
import 'package:flutter/material.dart';
import 'package:open_document/my_files/init.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../db_references/AppFile.dart';
import '../operation/AppFileOperation.dart';
import '../operation/CacheOperation.dart';
import '../pages/PdfVieverPage.dart';

class PrivacyPolicyConsumer extends StatefulWidget {
  final WidgetStateNotifier<AppFileServiceData> privacyPolicyNotifier;
  final Widget child;

  const PrivacyPolicyConsumer(
      {super.key, required this.privacyPolicyNotifier, required this.child});

  @override
  State<PrivacyPolicyConsumer> createState() => _PrivacyPolicyConsumerState();
}

class _PrivacyPolicyConsumerState extends State<PrivacyPolicyConsumer> {
  StreamSubscription? streamSubscription;

  WidgetStateNotifier<bool> acceptedNotifier =
      WidgetStateNotifier(currentValue: false);

  @override
  void initState() {
    super.initState();
    handlePrivacyData(widget.privacyPolicyNotifier.currentValue);
    streamSubscription ??= widget.privacyPolicyNotifier.stream.listen((event) {
      handlePrivacyData(event);
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription?.cancel();
  }

  void onTapPrivacyAndPolicy() {
    showCustomProgressBar(context);
    AppFileOperation().fetchParticularAppFile(AppFile.pp).then((value) {
      closeCustomProgressBar(context);

      if (value != null) {
        AppFileServiceData appFileServiceData =
            AppFileServiceData.fromOnline(value);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PdfViewerPage(
                      localIdentity: dbReference(AppFile.pp),
                      pdfTitle: 'Privacy Policy',
                      appFileNotifier:
                          WidgetStateNotifier(currentValue: appFileServiceData),
                    ))).then((value) {});
      } else {
        showToastMobile(msg: "An error has occurred");
      }
    }).onError((error, stackTrace) {
      closeCustomProgressBar(context);
      showToastMobile(msg: "An error has occurred");
      showDebug(msg: "$error $stackTrace");
    });
  }

  void policyAccepted(AppFileServiceData appFileServiceData) {
    showCustomProgressBar(context);
    CacheOperation()
        .saveCacheData(dbReference(AppFile.database),
            dbReference(AppFile.pp_check), appFileServiceData.toJson())
        .then((value) {
      closeCustomProgressBar(context);
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      showToastMobile(msg: "Unable to accept policy");
      showDebug(msg: "$error $stackTrace");
      closeCustomProgressBar(context);
    });
  }

  void handlePrivacyData(AppFileServiceData? appFileServiceData) async {
    if (appFileServiceData != null) {
      openAlert(
          context,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WidgetStateConsumer(
                  widgetStateNotifier: acceptedNotifier,
                  widgetStateBuilder: (context, accepted) {
                    return SizedBox(
                      width: getScreenWidth(context) - (16 * 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "Privacy Policy",
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              )),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "We value your privacy and are committed to safeguarding your personal information. We want to inform you that we have updated our privacy policy to better reflect our dedication to protecting your data.",
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 18),
                              )),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              Checkbox(
                                activeColor: const Color(getMainBlueColor),
                                value: accepted ?? false,
                                onChanged: (newValue) {
                                  acceptedNotifier.sendNewState(newValue);
                                },
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: onTapPrivacyAndPolicy,
                                  child: const Text(
                                    "I read and accepted the Privacy Policy",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          CustomPrimaryButton(
                              isEnabled: accepted == true,
                              buttonText: "Continue",
                              onTap: () {
                                policyAccepted(appFileServiceData);
                              }),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Later",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  )),
                            ],
                          )
                        ],
                      ),
                    );
                  })
            ],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
