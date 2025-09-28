//pages/income_input_page.dart
import 'package:flutter/material.dart';
import '../services/income_calculator.dart';
import '../widgets/income_field.dart';
import '../services/tax_data_service.dart';


import '../services/firestore_service.dart';

class IncomeInputPage extends StatefulWidget {
  final String incomeType;

  const IncomeInputPage({super.key, required this.incomeType});

  @override
  State<IncomeInputPage> createState() => _IncomeInputPageState();
}

class _IncomeInputPageState extends State<IncomeInputPage> {
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

  String selectedMode = "Annual"; // default
  int? selectedMonthIndex; // which month is picked
  final TextEditingController annualCtrl = TextEditingController();
  late List<List<Map<String, TextEditingController>>> monthlyEmploymentCtrls;
  late List<List<Map<String, TextEditingController>>> monthlyBusinessCtrls;
  late List<List<TextEditingController>> monthlyDynamicCtrls;

  // Employment income categories
  final List<String> employmentCategories = [
    "Salary / Wages",
    "Allowances",
    "Expense Reimbursements",
    "Agreement Payments",
    "Termination Payments",
    "Retirement Contributions & Payments",
    "Payments on Your Behalf",
    "Benefits in Kind",
    "Employee Share Schemes",
  ];

  // Business income categories (with rent for business purpose added)
  final List<String> businessCategories = [
    "Service Fees",
    "Sales of Trading Stock",
    "Capital Gains from Assets/Liabilities",
    "Realisation of Depreciable Assets",
    "Payments for Restrictions",
    "Other Business Income",
    "Rent for Business Purpose",
  ];

  // Annual employment income controllers
  late Map<String, TextEditingController> annualEmploymentCtrls;
  // Annual business income controllers
  late Map<String, TextEditingController> annualBusinessCtrls;

  // APIT controller
  final TextEditingController apitCtrl = TextEditingController();

  // Rent for business purpose controllers
  final TextEditingController rentBusinessIncomeCtrl = TextEditingController();
  final TextEditingController rentBusinessWhtCtrl = TextEditingController();
  String rentMaintainedByUser = "No";

  final service = TaxDataService();

  @override
  void initState() {
    super.initState();

    if (widget.incomeType == "Employment") {
      // Annual employment controllers
      annualEmploymentCtrls = {
        for (var cat in employmentCategories) cat: TextEditingController(),
      };

      // Monthly employment controllers (per month, per category)
      monthlyEmploymentCtrls = List.generate(
        12,
        (_) => employmentCategories
            .map((cat) => {cat: TextEditingController()})
            .toList(),
      );
    } else if (widget.incomeType == "Business") {
      // Annual business controllers
      annualBusinessCtrls = {
        for (var cat in businessCategories) cat: TextEditingController(),
      };

      // Monthly business controllers (per month, per category)
      monthlyBusinessCtrls = List.generate(
        12,
        (_) => businessCategories
            .map((cat) => {cat: TextEditingController()})
            .toList(),
      );
    } else {
      monthlyDynamicCtrls = List.generate(12, (_) => [TextEditingController()]);
    }
  }

  void addDynamicField(int monthIndex) {
    setState(() {
      monthlyDynamicCtrls[monthIndex].add(TextEditingController());
    });
  }

  void saveIncome() async {
    double annual = 0.0;

    if (selectedMode == "Annual") {
      if (widget.incomeType == "Employment") {
        annual = annualEmploymentCtrls.values
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .fold(0.0, (a, b) => a + b);
      } else if (widget.incomeType == "Business") {
        annual = annualBusinessCtrls.values
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .fold(0.0, (a, b) => a + b);

        // Add rent for business separately
        final rentIncome = double.tryParse(rentBusinessIncomeCtrl.text) ?? 0.0;
        final rentWht = double.tryParse(rentBusinessWhtCtrl.text) ?? 0.0;
        service.rentBusinessIncome = rentIncome;
        service.rentBusinessWht = rentWht;
        service.rentMaintainedByUser = rentMaintainedByUser == "Yes";
        annual += rentIncome;
      } else {
        annual = double.tryParse(annualCtrl.text) ?? 0.0;
      }
    } else {
      annual = getAnnualIncome();
    }

    // Save to TaxDataService based on income type
    if (widget.incomeType == "Employment") {
      service.totalEmploymentIncome = annual;
      service.apitAmount = double.tryParse(apitCtrl.text) ?? 0.0;
    } else if (widget.incomeType == "Business") {
      service.totalBusinessIncome = annual;
    } else if (widget.incomeType == "Investment") {
      service.investmentCategories[widget.incomeType] = annual;
      service.calculateTotalInvestmentIncome(); // Update total
    } else if (widget.incomeType == "Rent Income") {
      service.totalRentIncome = annual;
    } else if (widget.incomeType == "Solar Income") {
      service.totalSolarIncome = annual;
    } else if (widget.incomeType == "Other") {
      service.totalOtherIncome = annual;
    } else if (widget.incomeType.startsWith("Foreign")) {
      service.foreignIncomeCategories[widget.incomeType] = annual;
      service.calculateTotalForeignIncome(); // Update total
    } else {
      if ([
        "Dividends",
        "Discounts, Charges, Annuities",
        "Natural Resource Payments",
        "Premiums",
        "Royalties",
        "Gains from Selling Investment Assets",
        "Payments for Restricting Investment Activity",
        "Lottery, Betting, Gambling Winnings",
        "Other Investment",
      ].contains(widget.incomeType)) {
        service.investmentCategories[widget.incomeType] = annual;
        service.calculateTotalInvestmentIncome(); // Update total
      } else {
        service.totalDomesticIncome += annual;
      }
    }


    if (mounted) {
      // Check if widget is mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Saved ${widget.incomeType} income: Rs. $annual"),
        ),
      );
    }


    try {
      await FirestoreService.saveCalculatorData(service.getAllDataAsMap());
    } catch (e) {
      if (mounted) {
        // Check if widget is mounted before using context
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save to Firestore: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      // Check if widget is mounted before navigating
      Navigator.pop(context);
    }
  }












  double getAnnualIncome() {
    if (widget.incomeType == "Employment") {
      return monthlyEmploymentCtrls.fold(0.0, (sum, monthList) {
        final monthTotal = monthList.fold<double>(0.0, (mSum, catMap) {
          final ctrl = catMap.values.first;
          return mSum + (double.tryParse(ctrl.text) ?? 0.0);
        });
        return sum + monthTotal;
      });
    } else if (widget.incomeType == "Business") {
      double total = monthlyBusinessCtrls.fold(0.0, (sum, monthList) {
        final monthTotal = monthList.fold<double>(0.0, (mSum, catMap) {
          final ctrl = catMap.values.first;
          return mSum + (double.tryParse(ctrl.text) ?? 0.0);
        });
        return sum + monthTotal;
      });
      total += double.tryParse(rentBusinessIncomeCtrl.text) ?? 0.0;
      return total;
    } else {
      return IncomeCalculator.calculateAnnualDynamic(
        monthlyDynamicCtrls
            .map(
              (monthCtrls) => monthCtrls
                  .map((c) => double.tryParse(c.text) ?? 0.0)
                  .toList(),
            )
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.incomeType} Income")),
      body: Column(
        children: [
          // Toggle Annual/Monthly
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: ["Annual", "Monthly"].map((mode) {
                final selected = selectedMode == mode;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      selectedMode = mode;
                      selectedMonthIndex = null;
                    }),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? Colors.green : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        mode,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: selectedMode == "Annual"
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: widget.incomeType == "Employment"
                        ? ListView(
                            children: [
                              ...annualEmploymentCtrls.keys.map((label) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6.0,
                                  ),
                                  child: IncomeField(
                                    controller: annualEmploymentCtrls[label]!,
                                    label: label,
                                  ),
                                );
                              }).toList(),
                              const Divider(height: 32, thickness: 2),
                              IncomeField(
                                controller: apitCtrl,
                                label: "APIT Amount",
                              ),
                            ],
                          )
                        : widget.incomeType == "Business"
                        ? ListView(
                            children: [
                              ...annualBusinessCtrls.keys.map((label) {
                                if (label == "Rent for Business Purpose") {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Divider(height: 32, thickness: 2),
                                      const Text(
                                        "Rent for Business Purpose",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      IncomeField(
                                        controller: rentBusinessIncomeCtrl,
                                        label: "Rent Income",
                                      ),
                                      IncomeField(
                                        controller: rentBusinessWhtCtrl,
                                        label: "WHT Amount",
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Text("Maintained by User? "),
                                          DropdownButton<String>(
                                            value: rentMaintainedByUser,
                                            items: ["Yes", "No"]
                                                .map(
                                                  (val) => DropdownMenuItem(
                                                    value: val,
                                                    child: Text(val),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                rentMaintainedByUser =
                                                    val ?? "No";
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                    ),
                                    child: IncomeField(
                                      controller: annualBusinessCtrls[label]!,
                                      label: label,
                                    ),
                                  );
                                }
                              }).toList(),
                            ],
                          )
                        : Column(
                            children: [
                              IncomeField(
                                controller: annualCtrl,
                                label: "${widget.incomeType} Income (Annual)",
                              ),
                            ],
                          ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Horizontal month selector
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: months.length,
                          itemBuilder: (context, i) {
                            final selected = selectedMonthIndex == i;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedMonthIndex = i),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.green
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.green
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    months[i],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: selected
                                          ? Colors.white
                                          : Colors.black87,
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

                      if (selectedMonthIndex != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: widget.incomeType == "Employment"
                                ? ListView(
                                    children: [
                                      ...monthlyEmploymentCtrls[selectedMonthIndex!]
                                          .map((catMap) {
                                            final label = catMap.keys.first;
                                            final ctrl = catMap.values.first;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6.0,
                                                  ),
                                              child: IncomeField(
                                                controller: ctrl,
                                                label: label,
                                              ),
                                            );
                                          })
                                          .toList(),
                                      const Divider(height: 32, thickness: 2),
                                      IncomeField(
                                        controller: apitCtrl,
                                        label: "APIT Amount",
                                      ),
                                    ],
                                  )
                                : widget.incomeType == "Business"
                                ? ListView(
                                    children: [
                                      ...monthlyBusinessCtrls[selectedMonthIndex!].map((
                                        catMap,
                                      ) {
                                        final label = catMap.keys.first;
                                        final ctrl = catMap.values.first;
                                        if (label ==
                                            "Rent for Business Purpose") {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Divider(
                                                height: 32,
                                                thickness: 2,
                                              ),
                                              const Text(
                                                "Rent for Business Purpose",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              IncomeField(
                                                controller:
                                                    rentBusinessIncomeCtrl,
                                                label: "Rent Income",
                                              ),
                                              IncomeField(
                                                controller: rentBusinessWhtCtrl,
                                                label: "WHT Amount",
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  const Text(
                                                    "Maintained by User? ",
                                                  ),
                                                  DropdownButton<String>(
                                                    value: rentMaintainedByUser,
                                                    items: ["Yes", "No"]
                                                        .map(
                                                          (val) =>
                                                              DropdownMenuItem(
                                                                value: val,
                                                                child: Text(
                                                                  val,
                                                                ),
                                                              ),
                                                        )
                                                        .toList(),
                                                    onChanged: (val) {
                                                      setState(() {
                                                        rentMaintainedByUser =
                                                            val ?? "No";
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6.0,
                                            ),
                                            child: IncomeField(
                                              controller: ctrl,
                                              label: label,
                                            ),
                                          );
                                        }
                                      }).toList(),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (
                                        int j = 0;
                                        j <
                                            monthlyDynamicCtrls[selectedMonthIndex!]
                                                .length;
                                        j++
                                      )
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: IncomeField(
                                            controller:
                                                monthlyDynamicCtrls[selectedMonthIndex!][j],
                                            label:
                                                "${widget.incomeType} ${j + 1}",
                                          ),
                                        ),
                                      ElevatedButton.icon(
                                        onPressed: () => addDynamicField(
                                          selectedMonthIndex!,
                                        ),
                                        icon: const Icon(Icons.add),
                                        label: Text(
                                          "Add ${widget.incomeType} Income",
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saveIncome,
        label: const Text("Save"),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
