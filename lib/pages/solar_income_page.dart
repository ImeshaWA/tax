//pages/solar_income_page.dart
import 'package:flutter/material.dart';
import '../services/tax_data_service.dart';
import '../widgets/income_field.dart';


import '../services/firestore_service.dart';


class SolarIncomePage extends StatefulWidget {
  const SolarIncomePage({super.key});

  @override
  State<SolarIncomePage> createState() => SolarIncomePageState();
}

class SolarIncomePageState extends State<SolarIncomePage> {
  final TaxDataService service = TaxDataService();

  final TextEditingController installCostCtrl = TextEditingController();
  final TextEditingController reliefCountCtrl = TextEditingController();
  final TextEditingController solarIncomeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    installCostCtrl.text = service.solarInstallCost.toString();
    reliefCountCtrl.text = service.solarReliefCount.toString();
    solarIncomeCtrl.text = service.totalSolarIncome.toString();
  }

  void saveSolarDetails() async {
    service.solarInstallCost = double.tryParse(installCostCtrl.text) ?? 0.0;
    service.solarReliefCount = int.tryParse(reliefCountCtrl.text) ?? 0;
    service.totalSolarIncome = double.tryParse(solarIncomeCtrl.text) ?? 0.0;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solar income details saved")),
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
      appBar: AppBar(title: const Text("Solar Income")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Solar system must be connected to the national grid",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            IncomeField(controller: installCostCtrl, label: "Total Solar Installation Cost"),
            IncomeField(controller: reliefCountCtrl, label: "No. of Times Relief Availed"),
            IncomeField(controller: solarIncomeCtrl, label: "Annual Solar Income"),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: saveSolarDetails,
                child: const Text("Save Solar Income"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
