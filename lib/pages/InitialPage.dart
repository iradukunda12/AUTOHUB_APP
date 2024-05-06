import 'package:autohub/db_references/Members.dart';
import 'package:autohub/operation/CacheOperation.dart';
import 'package:autohub/pages/AdminMainPage.dart';
import 'package:autohub/pages/UserMainPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../../components/CustomPrimaryButton.dart';
import '../../components/CustomProject.dart';
import '../../local_navigation_controller.dart';
import '../collections/common_collection/ResourceCollection.dart';
import '../operation/AuthenticationOperation.dart';
import '../operation/MembersOperation.dart';
import 'LoginPage.dart';

// class CheckAuth extends StatelessWidget {
//   const CheckAuth({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final supabaseAuthChange = SupabaseConfig.client.auth.onAuthStateChange;
//
//     return Scaffold(
//       body: StreamBuilder<AuthState?>(
//         stream: supabaseAuthChange,
//         builder: (context, authSnapshot) {
//           if (authSnapshot.data?.event == AuthChangeEvent.tokenRefreshed) {
//             showToastMobile(msg: "Token has expired!!. Sign in again");
//             AuthenticationOperation().signOut(context, expiredToken: true);
//           }
//
//           if (authSnapshot.data?.event == AuthChangeEvent.userDeleted) {
//             showToastMobile(msg: "You have been removed from AutoHub");
//             AuthenticationOperation().signOut(context, expiredToken: true);
//           }
//           return const UserMainPage();
//         },
//       ),
//     );
//   }
// }

class PrimaryPage extends StatefulWidget {
  const PrimaryPage({super.key});

  @override
  State<PrimaryPage> createState() => _PrimaryPageState();
}

class _PrimaryPageState extends State<PrimaryPage> {
  WidgetStateNotifier<bool> widgetStateNotifier =
      WidgetStateNotifier(currentValue: false);

  Future<bool> navigateToHome() async {
    final userType = await CacheOperation()
        .getCacheData(dbReference(Members.type), dbReference(Members.type_key));

    if (userType == dbReference(Members.type_of_user)) {
      await Future.delayed(const Duration(milliseconds: 1200))
          .then((value) async {
        await Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const UserMainPage()));
      });
    } else {
      // Check current user
      Session? initialSession = await AuthenticationOperation().getSessions();

      await MembersOperation().getUserRecord().then((userData) async {
        if (initialSession?.user != null) {
          if (userData == null) {
            AuthenticationOperation().signOut(context);
            return true;
          }
          await Future.delayed(const Duration(milliseconds: 1200))
              .then((value) async {
            await Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const AdminMainPage()));
          });
          return false;
        }
      });
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    LocalNavigationController()
        .addNavigatorKey(LocalNavigationController.useNavigatorKey);
    navigateToHome().then((value) {
      if (value) {
        widgetStateNotifier.sendNewState(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    void goToAdministratorPage() {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (a) => false);
    }

    void toMainPage() {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserMainPage()),
          (a) => false);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WidgetStateConsumer(
            widgetStateNotifier: widgetStateNotifier,
            widgetStateBuilder: (context, snapshot) {
              if ((snapshot ?? false) == false) {
                return Center(
                  child: progressBarWidget(),
                );
              }
              // return ChoosePlanPage();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Center(
                          child: Column(
                            children: [
                              // Image Illustration
                              SizedBox(height: getScreenHeight(context) * 0.07),
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Lottie.asset(
                                      ResourceCollection.partsLottie,
                                      height: getScreenHeight(context) * 0.25)),
                              // Welcome Text
                              SizedBox(height: getScreenHeight(context) * 0.02),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "AUTOHUB",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.anton(
                                      color: Colors.black, fontSize: 24),
                                ),
                              ),

                              // Attached Text
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "AutoHub is the ultimate destination for automotive enthusiasts and DIYers looking to buy and sell vehicle parts. Our app offers a comprehensive platform where users can easily browse, purchase, and sell a wide range of automotive components, from engine parts to exterior accessories",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.carroisGothicSc(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomPrimaryButton(
                        buttonText: "Continue", onTap: toMainPage),
                    const SizedBox(
                      height: 32,
                    ),
                    GestureDetector(
                      onTap: goToAdministratorPage,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //
                            Text(
                              "To administrator",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.arrow_right_alt,
                              color: Colors.black.withOpacity(0.7),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
