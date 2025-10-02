// pages/exempt_income_page.dart
import 'package:flutter/material.dart';
import '../widgets/income_field.dart';
import '../services/tax_data_service.dart';
import '../services/firestore_service.dart';

class ExemptIncomePage extends StatefulWidget {
  const ExemptIncomePage({super.key});

  @override
  State<ExemptIncomePage> createState() => _ExemptIncomePageState();
}

class _ExemptIncomePageState extends State<ExemptIncomePage> {
  final TaxDataService service = TaxDataService();
  final TextEditingController exemptCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    exemptCtrl.text = service.exemptIncome.toString();
  }

  void saveExemptIncome() async {
    service.exemptIncome = double.tryParse(exemptCtrl.text) ?? 0.0;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exempt/Excluded income saved")),
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

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exempt/Excluded Income")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter total exempt/excluded income (local & foreign)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            IncomeField(
              controller: exemptCtrl,
              label: "Exempt Income Amount",
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: saveExemptIncome,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}