//pages/estimated_tax_page.dart
import 'package:flutter/material.dart';
import '../services/tax_computation_service.dart';



class EstimatedTaxPage extends StatefulWidget {
  const EstimatedTaxPage({super.key});

  @override
  State<EstimatedTaxPage> createState() => _EstimatedTaxPageState();
}

class _EstimatedTaxPageState extends State<EstimatedTaxPage> {
  late final TaxComputationService taxService;

  @override
  void initState() {
    super.initState();
    taxService = TaxComputationService();
    // Trigger relief calculations to populate the values
    taxService.totalReliefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estimated Tax Calculation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 🔹 Income Components Section
            _buildSectionTitle("Income Components"),
            summaryRow(
              "Total Annual Employment Income",
              taxService.service.totalEmploymentIncome,
            ),
            summaryRow(
              "Total Annual Business Income",
              taxService.service.totalBusinessIncome,
            ),
            summaryRow(
              "Total Annual Investment Income",
              taxService.service.calculateTotalInvestmentIncome(),
            ),
            summaryRow(
              "Total Annual Foreign Income",
              taxService.service.calculateTotalForeignIncome(),
            ),
            const Divider(),

            // 🔹 Tax Calculation Section
            _buildSectionTitle("Tax Calculation"),
            summaryRow(
              "Total Assessable Income",
              taxService.estimatedAssessableIncome(),
            ),
            summaryRow(
              "Total Qualifying Payments",
              taxService.totalQualifyingPayments(),
            ),
            summaryRow("Personal Relief", TaxComputationService.personalRelief),
            summaryRow("Rent Relief", taxService.service.rentRelief),
            summaryRow("Solar Relief", taxService.service.solarPanel),
            summaryRow("Total Relief", taxService.totalReliefs()),
            summaryRow("Taxable Income", taxService.estimatedTaxableIncome()),
            const Divider(),

            // 🔹 Tax Liability Section
            _buildSectionTitle("Tax Liability"),
            summaryRow(
              "Taxable Income (without Foreign)",
              taxService.taxableIncomeWithoutForeign(),
            ),
            summaryRow(
              "Tax Liability (without Foreign)",
              taxService.taxLiabilityWithoutForeign(),
            ),
            summaryRow(
              "Tax Liability (Foreign)",
              taxService.annualForeignIncomeLiability(),
            ),
            summaryRow("Final Tax Liability", taxService.finalTaxLiability()),
            summaryRow("Tax Payable", taxService.taxPayable()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget summaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Text(
            "Rs. ${value.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
