//pages/qualifying_payment_page.dart
import 'package:flutter/material.dart';
import '../widgets/income_field.dart';
import '../services/tax_data_service.dart';
import 'exempt_income_page.dart';


import '../services/firestore_service.dart';

class QualifyingPaymentsPage extends StatefulWidget {
  const QualifyingPaymentsPage({super.key});

  @override
  State<QualifyingPaymentsPage> createState() => _QualifyingPaymentsPageState();
}

class _QualifyingPaymentsPageState extends State<QualifyingPaymentsPage> {
  final TaxDataService service = TaxDataService();

  final TextEditingController charityCtrl = TextEditingController();
  final TextEditingController govDonationsCtrl = TextEditingController();
  final TextEditingController presidentsFundCtrl = TextEditingController();
  final TextEditingController femaleShopCtrl = TextEditingController();
  final TextEditingController filmExpenditureCtrl = TextEditingController();
  final TextEditingController cinemaNewCtrl = TextEditingController();
  final TextEditingController cinemaUpgradeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    charityCtrl.text = service.charity.toString();
    govDonationsCtrl.text = service.govDonations.toString();
    presidentsFundCtrl.text = service.presidentsFund.toString();
    femaleShopCtrl.text = service.femaleShop.toString();
    filmExpenditureCtrl.text = service.filmExpenditure.toString();
    cinemaNewCtrl.text = service.cinemaNew.toString();
    cinemaUpgradeCtrl.text = service.cinemaUpgrade.toString();
  }

  void savePayments() async {
    service.charity = double.tryParse(charityCtrl.text) ?? 0.0;
    service.govDonations = double.tryParse(govDonationsCtrl.text) ?? 0.0;
    service.presidentsFund = double.tryParse(presidentsFundCtrl.text) ?? 0.0;
    service.femaleShop = double.tryParse(femaleShopCtrl.text) ?? 0.0;
    service.filmExpenditure = double.tryParse(filmExpenditureCtrl.text) ?? 0.0;
    service.cinemaNew = double.tryParse(cinemaNewCtrl.text) ?? 0.0;
    service.cinemaUpgrade = double.tryParse(cinemaUpgradeCtrl.text) ?? 0.0;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payments saved successfully")),
      );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Qualifying Payments")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Qualifying Payments",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            IncomeField(controller: charityCtrl, label: "Donations to Charity"),
            IncomeField(
              controller: govDonationsCtrl,
              label: "Donations to Govt/Institutions",
            ),
            IncomeField(
              controller: presidentsFundCtrl,
              label: "Profits to President's Fund",
            ),
            IncomeField(
              controller: femaleShopCtrl,
              label: "Contribution for Female Shop",
            ),
            IncomeField(
              controller: filmExpenditureCtrl,
              label: "Film Production Expenditure",
            ),
            IncomeField(
              controller: cinemaNewCtrl,
              label: "New Cinema Construction",
            ),
            IncomeField(
              controller: cinemaUpgradeCtrl,
              label: "Cinema Upgrade Expenditure",
            ),

            const SizedBox(height: 20),
            const Text(
              "Other Declarations",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Exempt/Excluded Income button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExemptIncomePage(),
                        ),
                      );
                      setState(() {});
                    },
                    child: const Text("Enter Exempt Income"),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Saved: Rs. ${service.exemptIncome.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: savePayments,
                child: const Text("Save Payments"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
