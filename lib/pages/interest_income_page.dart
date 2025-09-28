//pages/interest_income_page.dart
import 'package:flutter/material.dart';
import '../services/tax_data_service.dart';
import '../widgets/income_field.dart';


import '../services/firestore_service.dart';

class InterestIncomePage extends StatefulWidget {
  const InterestIncomePage({super.key});

  @override
  State<InterestIncomePage> createState() => InterestIncomePageState();
}

class InterestIncomePageState extends State<InterestIncomePage> {
  final TaxDataService service = TaxDataService();

  // Each account holds 3 controllers: [interest, time period, WHT]
  List<List<TextEditingController>> fixedDepositAccounts = [];
  List<List<TextEditingController>> savingAccounts = [];

  @override
  void initState() {
    super.initState();
    // Add one default account for each category
    fixedDepositAccounts.add([
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ]);
    savingAccounts.add([
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ]);
  }

  void addFixedDepositAccount() {
    setState(() {
      fixedDepositAccounts.add([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    });
  }

  void addSavingAccount() {
    setState(() {
      savingAccounts.add([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    });
  }

  void saveInterestIncome() async {
    double total = 0.0;

    // Fixed Deposit Income
    for (var acc in fixedDepositAccounts) {
      total += double.tryParse(acc[0].text) ?? 0.0; // Interest Income
    }

    // Saving Account Income
    for (var acc in savingAccounts) {
      total += double.tryParse(acc[0].text) ?? 0.0; // Interest Income
    }

    // Save to investment categories for WHT calculation
    service.investmentCategories["Fixed Deposit Interest"] =
        fixedDepositAccounts.fold<double>(
          0.0,
          (sum, acc) => sum + (double.tryParse(acc[0].text) ?? 0.0),
        );

    service.investmentCategories["Normal Saving Interest"] = savingAccounts
        .fold<double>(
          0.0,
          (sum, acc) => sum + (double.tryParse(acc[0].text) ?? 0.0),
        );

    service.totalInvestmentIncome = total;

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Interest income saved")));
    }

    try {
      await FirestoreService.saveCalculatorData(service.getAllDataAsMap());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save to Firestore: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget buildAccountSection(
    String title,
    List<List<TextEditingController>> accounts,
    VoidCallback onAdd,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    IncomeField(
                      controller: accounts[index][0],
                      label: "$title ${index + 1} - Interest Income (Gross)",
                    ),
                    const SizedBox(height: 8),
                    IncomeField(
                      controller: accounts[index][1],
                      label: "$title ${index + 1} - Time Period",
                    ),
                    const SizedBox(height: 8),
                    IncomeField(
                      controller: accounts[index][2],
                      label: "$title ${index + 1} - WHT Amount",
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text("Add Another $title Account"),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interest Income")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildAccountSection(
              "Fixed Deposit",
              fixedDepositAccounts,
              addFixedDepositAccount,
            ),
            buildAccountSection(
              "Normal Saving",
              savingAccounts,
              addSavingAccount,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveInterestIncome,
              child: const Text("Save Interest Income"),
            ),
          ],
        ),
      ),
    );
  }
}
