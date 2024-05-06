import 'package:autohub/components/CustomPrimaryButton.dart';
import 'package:autohub/components/CustomProject.dart';
import 'package:autohub/data/CategoryData.dart';
import 'package:autohub/data_notifier/CategoryNotifier.dart';
import 'package:autohub/operation/CategoryOperation.dart';
import 'package:autohub/supabase/SupabaseConfig.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../components/CustomCircularButton.dart';
import '../components/CustomEditTextField.dart';
import '../db_references/Category.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  TextEditingController identityController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  WidgetStateNotifier<bool> identityNotifier =
      WidgetStateNotifier(currentValue: false);
  WidgetStateNotifier<bool> descriptionNotifier =
      WidgetStateNotifier(currentValue: false);
  WidgetStateNotifier<String> forWhichNotifier = WidgetStateNotifier();

  @override
  void initState() {
    super.initState();

    identityNotifier.addController(identityController, (stateNotifier) {
      stateNotifier.sendNewState(identityController.text.isNotEmpty);
    });
    descriptionNotifier.addController(descriptionController, (stateNotifier) {
      stateNotifier.sendNewState(descriptionController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    super.dispose();

    identityNotifier.removeController(disposeMethod: () {
      identityController.dispose();
    });
    descriptionNotifier.removeController(disposeMethod: () {
      descriptionController.dispose();
    });
  }

  void performBackPressed() {
    Navigator.pop(context);
  }

  List<MapEntry<Widget, dynamic Function()>> getGender() {
    return [
      MapEntry(
          const Text(
            "Parts",
            style: TextStyle(fontSize: 18),
            textScaler: TextScaler.noScaling,
          ), () {
        forWhichNotifier.sendNewState(dbReference(Category.parts));
      }),
      MapEntry(
          const Text(
            "Services",
            style: TextStyle(fontSize: 18),
            textScaler: TextScaler.noScaling,
          ), () {
        forWhichNotifier.sendNewState(dbReference(Category.services));
      }),
      MapEntry(
          const Text(
            "All type",
            style: TextStyle(fontSize: 18),
            textScaler: TextScaler.noScaling,
          ), () {
        forWhichNotifier.sendNewState(dbReference(Category.all));
      }),
    ];
  }

  void saveCategory() {
    String identity = identityController.text.trim().toLowerCase();
    String description = descriptionController.text.toLowerCase().replaceFirst(
        descriptionController.text[0],
        descriptionController.text[0].toUpperCase());
    String forWhich = forWhichNotifier.currentValue!;
    String? thisUser = SupabaseConfig.client.auth.currentUser?.id;

    if (thisUser == null) {
      showDebug(msg: "An error occurred");
      return;
    }

    showCustomProgressBar(context);
    CategoryOperation()
        .saveNewCategory(identity, description, forWhich, thisUser)
        .then((value) {
      closeCustomProgressBar(context);

      if (value != null) {
        CategoryData categoryData = CategoryData.fromOnline(value);
        CategoryNotifier().addNewCategory(categoryData);
        showToastMobile(msg: "Successfully added a new category");
        Navigator.pop(context);
      } else {
        showToastMobile(msg: "An error has occurred");
      }
    }).onError((error, stackTrace) {
      closeCustomProgressBar(context);
      showDebug(msg: "$error $stackTrace");
      if (error is PostgrestException && error.code == "409") {
        showToastMobile(msg: "Duplicate category found");
      } else {
        showToastMobile(msg: "An error has occurred");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(children: [
                CustomCircularButton(
                  imagePath: null,
                  iconColor: Colors.black,
                  onPressed: performBackPressed,
                  icon: Icons.arrow_back,
                  width: 40,
                  height: 40,
                  iconSize: 30,
                  mainAlignment: Alignment.center,
                  defaultBackgroundColor: Colors.transparent,
                  clickedBackgroundColor: Colors.white,
                ),
                const SizedBox(
                  width: 8,
                ),
                const Expanded(
                  child: Text(
                    "New Category",
                    textScaleFactor: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: CustomEditTextField(
                          capitalization: TextCapitalization.words,
                          keyboardType: TextInputType.text,
                          controller: identityController,
                          hintText: "Category Identity",
                          obscureText: false,
                          titleStyle: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.bold),
                          useShadow: false,
                          textSize: 16),
                    ),

                    //  Part Description
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: CustomEditTextField(
                          capitalization: TextCapitalization.words,
                          keyboardType: TextInputType.text,
                          controller: descriptionController,
                          hintText: "Category Description",
                          obscureText: false,
                          titleStyle: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.bold),
                          useShadow: false,
                          textSize: 16),
                    ),

                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: WidgetStateConsumer(
                          widgetStateNotifier: forWhichNotifier,
                          widgetStateBuilder: (context, forWhich) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Category Type",
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.8),
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                PopupMenuButton(
                                    color: Colors.grey.shade200,
                                    surfaceTintColor: Colors.transparent,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          boxShadow: [
                                            // BoxShadow(
                                            //   color: Colors.black.withOpacity(0.1),
                                            //   blurRadius: 8,
                                            //   offset: const Offset(0, 4),
                                            // ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 20),
                                            child: Text(
                                              CategoryOperation()
                                                          .fowWhichIdentity[
                                                      forWhich] ??
                                                  "Category Type",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: forWhich == null
                                                      ? Colors.black
                                                          .withOpacity(0.7)
                                                      : Colors.black),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    onSelected: (itemIndex) {
                                      getGender()
                                          .elementAtOrNull(itemIndex)
                                          ?.value
                                          .call();
                                    },
                                    itemBuilder: (context) {
                                      return getGender()
                                          .asMap()
                                          .map((index, e) {
                                            return MapEntry(
                                                index,
                                                PopupMenuItem(
                                                    value: index,
                                                    child: e.key));
                                          })
                                          .values
                                          .toList();
                                    }),
                              ],
                            );
                          }),
                    ),

                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MultiWidgetStateConsumer(
                          widgetStateListNotifiers: [
                            identityNotifier,
                            descriptionNotifier,
                            forWhichNotifier,
                          ],
                          widgetStateListBuilder: (context) {
                            bool enable =
                                identityNotifier.currentValue == true &&
                                    descriptionNotifier.currentValue == true &&
                                    forWhichNotifier.currentValue?.isNotEmpty ==
                                        true;

                            return CustomPrimaryButton(
                                isEnabled: enable,
                                buttonText: "Save",
                                onTap: saveCategory);
                          }),
                    ),

                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
