import 'package:autohub/data/MediaData.dart';
import 'package:flutter/material.dart';

import '../data/ServicesData.dart';
import '../data_notifier/UserProfileNotifier.dart';
import '../handler/MediaHandler.dart';
import '../operation/CategoryOperation.dart';

class ServiceWidget extends StatelessWidget {
  final ServicesData serviceData;
  final VoidCallback onTap;
  final UserProfileNotifier? userAddedProfileNotifier;
  final UserProfileNotifier? userEditedProfileNotifier;

  const ServiceWidget(
      {super.key,
      required this.serviceData,
      required this.onTap,
      required this.userAddedProfileNotifier,
      required this.userEditedProfileNotifier});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 130,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Builder(builder: (context) {
                      MediaData? media = serviceData.servicesMedia.firstOrNull;
                      if ((media != null)) {
                        return Row(
                          children: [
                            Expanded(
                              child: MediaHandler(
                                media: media,
                                clicked: onTap,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Icon(
                          Icons.miscellaneous_services,
                          size: 100,
                          color: Colors.black.withOpacity(0.5),
                        );
                      }
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    serviceData.servicesIdentity,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${serviceData.servicesCurrency} ${CategoryOperation().formatNumber(double.parse(serviceData.servicesPrice))}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    serviceData.servicesDescription,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }
}
