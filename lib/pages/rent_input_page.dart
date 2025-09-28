//pages/rent_input_page.dart
import 'package:flutter/material.dart';
import '../services/tax_data_service.dart';
import '../widgets/income_field.dart';

import '../services/firestore_service.dart';

class RentInputPage extends StatefulWidget {
  const RentInputPage({super.key});

  @override
  State<RentInputPage> createState() => _RentInputPageState();
}

class _RentInputPageState extends State<RentInputPage> {
  final TaxDataService service = TaxDataService();

  final List<String> months = [
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
    "January",
    "February",
    "March",
  ];

  // Resident purpose
  String? residentMode;
  int? selectedResidentMonth;
  final TextEditingController annualResidentCtrl = TextEditingController();
  late List<List<TextEditingController>> monthlyResidentCtrls;

  // 🔹 New field for maintenance responsibility
  bool? isMaintainedByUser;

  @override
  void initState() {
    super.initState();
    monthlyResidentCtrls = List.generate(12, (_) => [TextEditingController()]);
    annualResidentCtrl.text = "0.0";
  }

  void addDynamicField(int monthIndex, bool isResident) {
    setState(() {
      monthlyResidentCtrls[monthIndex].add(TextEditingController());
    });
  }

  void saveRent() async {
    double totalResident = 0.0;

    // Resident
    if (residentMode == "Annual") {
      totalResident = double.tryParse(annualResidentCtrl.text) ?? 0.0;
    } else if (residentMode == "Monthly") {
      for (int i = 0; i < 12; i++) {
        for (var ctrl in monthlyResidentCtrls[i]) {
          totalResident += double.tryParse(ctrl.text) ?? 0.0;
        }
      }
    }

    service.totalRentIncome = totalResident;

    // 🔹 Save maintenance responsibility as well
    service.isMaintainedByUser = isMaintainedByUser ?? false;

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

  Widget buildIncomeSection(String title) {
    String? mode = residentMode;
    int? selectedMonth = selectedResidentMonth;
    List<List<TextEditingController>> monthlyCtrls = monthlyResidentCtrls;
    TextEditingController annualCtrl = annualResidentCtrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // 🔹 Annual / Monthly Toggle
        Row(
          children: ["Annual", "Monthly"].map((m) {
            bool selected = mode == m;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  residentMode = m;
                  selectedResidentMonth = null;
                }),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: selected ? Colors.blue : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    m,
                    style: TextStyle(
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // 🔹 Annual mode
        if (mode == "Annual")
          IncomeField(controller: annualCtrl, label: "$title Annual Amount"),

        // 🔹 Monthly mode
        if (mode == "Monthly") ...[
          // Horizontal month selector
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: months.length,
              itemBuilder: (context, i) {
                bool selected = selectedMonth == i;
                return GestureDetector(
                  onTap: () => setState(() {
                    selectedResidentMonth = i;
                  }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? Colors.blue : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        months[i],
                        style: TextStyle(
                          fontSize: 16,
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Show inputs only for selected month
          if (selectedMonth != null) ...[
            Text(
              "${months[selectedMonth]} $title Income",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            for (int j = 0; j < monthlyCtrls[selectedMonth].length; j++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: IncomeField(
                  controller: monthlyCtrls[selectedMonth][j],
                  label: "$title ${j + 1}",
                ),
              ),
            ElevatedButton.icon(
              onPressed: () => addDynamicField(selectedMonth!, true),
              icon: const Icon(Icons.add),
              label: Text("Add $title Income"),
            ),
          ],
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rent Income")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildIncomeSection("Resident Purpose"),

            // 🔹 New Section: Maintenance Responsibility
            const SizedBox(height: 20),
            const Text(
              "Is the building/house maintained by you?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: isMaintainedByUser,
                        onChanged: (bool? value) {
                          if (value != null) {
                            setState(() {
                              isMaintainedByUser = value;
                            });
                          }
                        },
                      ),
                      const Text("Yes"),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: isMaintainedByUser,
                        onChanged: (bool? value) {
                          if (value != null) {
                            setState(() {
                              isMaintainedByUser = value;
                            });
                          }
                        },
                      ),
                      const Text("No"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: saveRent,
                child: const Text("Save Rent Income"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
