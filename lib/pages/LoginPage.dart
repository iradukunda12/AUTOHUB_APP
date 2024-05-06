import 'dart:async';

import 'package:autohub/pages/AdminMainPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_obj;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/CustomCircularButton.dart';
import '../components/CustomEditTextField.dart';
import '../components/CustomPrimaryButton.dart';
import '../components/CustomProject.dart';
import '../db_references/Members.dart';
import '../main.dart';
import '../operation/AuthenticationOperation.dart';
import '../operation/MembersOperation.dart';
import '../services/AppFileService.dart';
import '../supabase/SupabaseConfig.dart';
import 'InitialPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool userNameAvail = false;
  bool passwordAvail = false;
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    userNameController.addListener(() {
      setState(() {
        userNameAvail = userNameController.text.isNotEmpty &&
            CustomEditTextFormatter(null)
                .isEmail(userNameController.text.trim());
      });
    });

    passwordController.addListener(() {
      setState(() {
        passwordAvail = passwordController.text.isNotEmpty &&
            CustomEditTextFormatter(CustomEditTextFieldFormatOptions(
                    hasUpperCase: true,
                    hasLowerCase: true,
                    hasLengthOf: 6,
                    hasNumbers: true,
                    hasSpecialCharacter: true))
                .validatePassword(passwordController.text);
      });
    });
  }

  Future<bool> backPressed() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PrimaryPage()),
      (Route<dynamic> route) => false,
    );
    return false;
  }

  bool enableButtonOnValidateCheck() {
    return userNameAvail && passwordAvail;
  }

  void onUnsuccessful(Object error) {
    closeCustomProgressBar(context);
    if (error.runtimeType == supabase_obj.AuthException) {
      String errorMessage =
          (error as supabase_obj.AuthException).message.toLowerCase();

      showToastMobile(msg: errorMessage);
    } else if (error.runtimeType == TimeoutException) {
      showToastMobile(
          msg:
              "You were timeout under 1 minute due to something that occurred.");
    } else {
      showDebug(msg: "$error");

      showToastMobile(msg: "No internet connection.");
    }
  }

  void goToAdminMainPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AdminMainPage()),
      (Route<dynamic> route) => false,
    );
  }

  void onSignInComplete(AuthResponse response) async {
    showCustomProgressBar(context);

    MembersOperation()
        .userOnlineRecord(
      SupabaseConfig.client.auth.currentUser?.id ?? '',
    )
        .then((userData) async {
      handleUserData(response, userData);
    }).onError((error, stackTrace) {
      closeCustomProgressBar(context);
      showToastMobile(msg: "An error occurred");
      showDebug(msg: "$error $stackTrace");
    });
  }

  void handleUserData(AuthResponse response, dynamic userData) {
    String? uuid = response.user?.id;

    // User data not null
    if (userData != null) {
      // Retrieve the uuid
      // Check if there is a value
      if (uuid != null) {
        // Fetch AppFiles

        if (userData[dbReference(Members.is_admin)] == false) {
          closeCustomProgressBar(context);

          openDialog(
              context,
              cancelTouch: false,
              const Text(
                "Administrator",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You are not a valid admin to sign in. Contact one of the administrators.",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    AuthenticationOperation().signOut(context);
                  },
                  child: const Text(
                    "Okay",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ]);
        } else {
          AppFileService().fetchAppFiles().then((value) {
            // Clear any saved entries for the new user
            MembersOperation().removeExistedUserRecord().then((removed) {
              // Check if operation was successful
              // Save the user data to storage
              MembersOperation()
                  .saveOnlineUserRecordToLocal(userData, useOther: true)
                  .then((saved) async {
                //  Check if saving operation was success

                if (saved) {
                  // Set this user to be verified to storage
                  MembersOperation()
                      .setUserLocalVerification(uuid)
                      .then((setVerification) {
                    // If user is verified to storage
                    if (setVerification) {
                      // Return to the secondary page.
                      closeCustomProgressBar(context);
                      goToAdminMainPage();
                    } else {
                      // Verification to storage failed
                      onSignInError(1);
                    }
                  }).onError((error, stackTrace) {
                    onSignInError(2);
                  });
                } else {
                  // Unable to save data
                  onSignInError(3);
                }
              }).onError((error, stackTrace) {
                showDebug(msg: "$error $stackTrace");
                onSignInError(4);
              });
            }).onError((error, stackTrace) => onSignInError(6));
          }).onError((error, stackTrace) => onSignInError(18));
        }
      } else {
        // Retrieving uuid failed
        onSignInError(9);
      }
    } else {
      // Retrieving uuid failed
      onSignInError(16);
    }
  }

  Future<Null>? onSignInError(int n) async {
    closeCustomProgressBar(context);
    showToastMobile(msg: "Unable to Sign in at the moment. Code $n");
    AuthenticationOperation().signOut(context);
  }

  void signInUsers() {
    hideKeyboard(context);
    showCustomProgressBar(context, cancelTouch: true);

    String email = userNameController.text.trim();
    String password = passwordController.text.trim();
    AuthenticationOperation().signInWithEmail(email, password).listen((event) {
      closeCustomProgressBar(context);
      if (event.user != null) {
        onSignInComplete(event);
      } else {
        showToastMobile(msg: "Try again!!!");
      }
    }, onError: onUnsuccessful);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PopScope(
          onPopInvoked: (pop) {
            backPressed();
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Center(
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          // Message
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                CustomCircularButton(
                                  imagePath: null,
                                  mainAlignment: Alignment.center,
                                  iconColor: const Color(getDarkGreyColor),
                                  onPressed: () {
                                    backPressed();
                                  },
                                  icon: Icons.arrow_back,
                                  gap: 8,
                                  width: 45,
                                  height: 45,
                                  iconSize: 35,
                                  defaultBackgroundColor: Colors.transparent,
                                  colorImage: true,
                                  showShadow: false,
                                  clickedBackgroundColor:
                                      const Color(getDarkGreyColor)
                                          .withOpacity(0.4),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 40,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "AUTOHUB",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.anton(
                                  color: Colors.black, fontSize: 58),
                            ),
                          ),

                          //  Hello Text
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text("Login",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold)),
                          ),

                          // Welcome Text
                          const SizedBox(height: 48),

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: getScreenWidth(context) * 0.05),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: CustomEditTextField(
                                        controller: userNameController,
                                        hintText: "Email",
                                        obscureText: false,
                                        useShadow: false,
                                        titleStyle: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        fillColor: Colors.white,
                                        textSize: 16),
                                  ),

                                  //  Password TextField
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: CustomEditTextField(
                                        controller: passwordController,
                                        hintText: "Password",
                                        obscureText: true,
                                        fillColor: Colors.white,
                                        titleStyle: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        useShadow: false,
                                        textSize: 16),
                                  ),

                                  //  SignIn Button
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24),
                                          child: CustomPrimaryButton(
                                              buttonText: "Sign In",
                                              onTap: signInUsers,
                                              isEnabled:
                                                  enableButtonOnValidateCheck()),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
