//pages/investment_income_page.dart
import 'package:flutter/material.dart';
import 'income_input_page.dart';
import 'rent_input_page.dart';
import 'solar_income_page.dart';
import 'interest_income_page.dart';

class InvestmentIncomePage extends StatelessWidget {
  const InvestmentIncomePage({super.key});

  void goToIncomePage(BuildContext context, String type) {
    if (type == "Rent Income") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RentInputPage()),
      );
    } else if (type == "Solar Income") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SolarIncomePage()),
      );
    } else if (type == "Interest Income (Annual)" ||
        type == "Interest Income (Monthly)" ||
        type == "Interest Income") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InterestIncomePage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IncomeInputPage(incomeType: type),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const neutral900 = Color(0xFF111714);
    const neutral300 = Color(0xFFdce5df);

    final investmentTypes = [
      "Dividends ",
      "Discounts, Charges, Annuities",
      "Natural Resource Payments",
      "Rent Income",
      "Premiums",
      "Royalties",
      "Gains from Selling Investment Assets",
      "Payments for Restricting Investment Activity",
      "Lottery, Betting, Gambling Winnings",
      "Solar Income",
      "Interest Income",
      "Other Investment",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Investment Income"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: investmentTypes.length,
        itemBuilder: (context, index) {
          final type = investmentTypes[index];
          return GestureDetector(
            onTap: () => goToIncomePage(context, type),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: neutral300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: neutral900,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: neutral900,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
