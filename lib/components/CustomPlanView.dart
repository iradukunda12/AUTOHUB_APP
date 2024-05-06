import 'package:autohub/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

import '../data/PlanData.dart';
import 'CustomPlanPaymentView.dart';
import 'EllipsisText.dart';

class CustomPlanView extends StatefulWidget {
  final PlanData planData;
  final int index;

  const CustomPlanView(
      {super.key, required this.planData, required this.index});

  @override
  State<CustomPlanView> createState() => _CustomPlanViewState();
}

class _CustomPlanViewState extends State<CustomPlanView> {
  WidgetStateNotifier<int> selectedViewNotifier = WidgetStateNotifier();

  Widget getPaymentView(bool selected, int index, String title, double price,
      int timePeriod, Color backgroundColor) {
    return CustomPlanPaymentView(
      selected: selected,
      color: Color(getMainBlueColor),
      borderColor: Colors.grey.shade700,
      currency: widget.planData.plansCurrency,
      titleStyle: GoogleFonts.arvo(
          color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
      title: title,
      period: timePeriod,
      price: price,
      subTitleStyle: TextStyle(color: Colors.black, fontSize: 15),
      subMainTitleStyle: TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      bottomStyle: TextStyle(color: Colors.blue, fontSize: 14),
      buttonStyle: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold),
      onSelect: () {
        selectedViewNotifier.sendNewState(index);
      },
      backgroundColor: Colors.transparent,
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return WidgetStateConsumer(
        widgetStateNotifier: selectedViewNotifier,
        widgetStateBuilder: (context, data) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 32,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        widget.planData.plansTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: EllipsisText(
                          textAlign: TextAlign.center,
                          text: widget.planData.plansDescription,
                          maxLength: 150,
                          onMorePressed: () {},
                          textStyle:
                              TextStyle(color: Colors.black, fontSize: 15),
                          moreText: 'more',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 28,
                  ),

                  // getPaymentView((snapshot.data ?? 0) == 0,0, "Monthly", widget.planData.plansMonthlyPayment, 1,Colors.blueAccent,),
                  // SizedBox(height: 16),

                  getPaymentView((data ?? 0) == 0, 0, "Quarterly",
                      widget.planData.plansQuarterlyPayment, 3, Colors.green),
                  SizedBox(height: 16),

                  getPaymentView((data ?? 0) == 1, 1, "Bi-Annual",
                      widget.planData.plansBiAnnualPayment, 6, Colors.red),
                  SizedBox(height: 16),

                  getPaymentView((data ?? 0) == 2, 2, "Yearly",
                      widget.planData.plansYearlyPayment, 12, Colors.yellow),
                  SizedBox(height: 16),
                ],
              ),
            ),
          );
        });
  }
}
