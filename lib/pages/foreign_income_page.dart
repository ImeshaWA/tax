//pages/foreign_income_page.dart
//pages/foreign_income_page.dart
import 'package:flutter/material.dart';
import 'income_input_page.dart';
import '../widgets/income_field.dart';
import '../services/tax_data_service.dart';
import '../services/firestore_service.dart';

class ForeignIncomePage extends StatefulWidget {
  const ForeignIncomePage({super.key});

  @override
  State<ForeignIncomePage> createState() => _ForeignIncomePageState();
}

class _ForeignIncomePageState extends State<ForeignIncomePage> {
  final List<String> foreignTypes = const [
    "Foreign Employment",
    "Foreign Business",
    "Foreign Investment",
    "Foreign Other",
  ];

  final TaxDataService service = TaxDataService();
  final TextEditingController foreignTaxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    foreignTaxCtrl.text = service.foreignTaxCredits.toString();
  }

  void saveForeignTaxCredits() async {
    service.foreignTaxCredits = double.tryParse(foreignTaxCtrl.text) ?? 0.0;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foreign tax credits saved")),
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

  void goToIncomePage(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IncomeInputPage(incomeType: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const neutral900 = Color(0xFF111714);
    const neutral300 = Color(0xFFdce5df);

    return Scaffold(
      appBar: AppBar(title: const Text("Foreign Income"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 List of foreign income types
            Expanded(
              child: ListView.builder(
                itemCount: foreignTypes.length,
                itemBuilder: (context, index) {
                  final type = foreignTypes[index];
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
            ),

            const SizedBox(height: 20),

            // 🔹 Foreign Tax Credits Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Do you pay foreign tax?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            IncomeField(
              controller: foreignTaxCtrl,
              label: "Estimated Foreign Tax Credits Paid",
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveForeignTaxCredits,
              child: const Text("Save Foreign Tax Credits"),
            ),
          ],
        ),
      ),
    );
  }
}
