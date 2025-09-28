//pages/mode_selection_page.dart
import 'package:flutter/material.dart';
import 'income_input_page.dart';
import 'qualifying_payments_page.dart';
import 'foreign_income_page.dart';
import 'investment_income_page.dart';
import 'estimated_tax_page.dart';
import 'year_selection_page.dart';
import '../services/tax_data_service.dart';

class ModeSelectionPage extends StatefulWidget {
  const ModeSelectionPage({super.key});

  @override
  State<ModeSelectionPage> createState() => _ModeSelectionPageState();
}

class _ModeSelectionPageState extends State<ModeSelectionPage> {
  String? selectedType;
  final TaxDataService service = TaxDataService();

  final List<String> incomeTypes = [
    "Employment",
    "Business",
    "Investment",
    "Other",
    "Foreign", // NEW option
  ];

  void goToNextPage() {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose an income type")),
      );
      return;
    }

    if (selectedType == "Foreign") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ForeignIncomePage()),
      );
    } else if (selectedType == "Investment") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InvestmentIncomePage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IncomeInputPage(incomeType: selectedType!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF38E07B);
    const neutral900 = Color(0xFF111714);
    const neutral300 = Color(0xFFdce5df);
    const neutral50 = Color(0xFFf8faf9);

    return Scaffold(
      backgroundColor: neutral50,
      appBar: AppBar(
        backgroundColor: neutral50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: neutral900),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const YearSelectionPage()),
          ),
        ),
        title: const Text(
          "Income Tax Cal",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: neutral900,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Income Type",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: neutral900,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  ...incomeTypes.map((type) {
                    final selected = selectedType == type;
                    return GestureDetector(
                      onTap: () => setState(() => selectedType = type),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? primaryColor : neutral300,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: neutral900,
                                ),
                              ),
                            ),
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? primaryColor : neutral300,
                                  width: 2,
                                ),
                                color: selected ? primaryColor : Colors.white,
                              ),
                              child: selected
                                  ? const Center(
                                      child: Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  // Qualifying Payments Page
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QualifyingPaymentsPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Enter Qualifying Payments"),
                  ),
                  const SizedBox(height: 16),
                  // View Estimated Taxable Income Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EstimatedTaxPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("View Tax Summary"),
                  ),
                  if (service.selectedTaxYear == "2025/2026") ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to Quarterly Installment Payment page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Quarterly Installment Payment"),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: goToNextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: neutral900,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Continue",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
