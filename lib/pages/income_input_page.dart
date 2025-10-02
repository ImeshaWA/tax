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

class _IncomeInputPageState extends State<IncomeInputPage> with TickerProviderStateMixin {
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

  String selectedMode = "Annual";
  int? selectedMonthIndex;
  final TextEditingController annualCtrl = TextEditingController();
  late List<List<Map<String, TextEditingController>>> monthlyEmploymentCtrls;
  late List<List<Map<String, TextEditingController>>> monthlyBusinessCtrls;
  late List<List<TextEditingController>> monthlyDynamicCtrls;
  late List<TextEditingController> monthlyApitCtrls;
  final TextEditingController annualApitCtrl = TextEditingController();
  late List<TextEditingController> monthlyRentBusinessIncomeCtrls;
  late List<TextEditingController> monthlyRentBusinessWhtCtrls;
  late List<String> monthlyRentMaintainedByUser;

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

  final List<String> businessCategories = [
    "Service Fees",
    "Sales of Trading Stock",
    "Capital Gains from Assets/Liabilities",
    "Realisation of Depreciable Assets",
    "Payments for Restrictions",
    "Other Business Income",
    "Rent for Business Purpose",
  ];

  final List<String> investmentCategories = [
    "Dividends",
    "Discounts, Charges, Annuities",
    "Natural Resource Payments",
    "Premiums",
    "Royalties",
    "Gains from Selling Investment Assets",
    "Payments for Restricting Investment Activity",
    "Lottery, Betting, Gambling Winnings",
    "Other Investment",
  ];

  final List<String> foreignCategories = [
    "Foreign Employment",
    "Foreign Business",
    "Foreign Investment",
    "Foreign Other",
  ];

  late Map<String, TextEditingController> annualEmploymentCtrls;
  late Map<String, TextEditingController> annualBusinessCtrls;
  final TextEditingController rentBusinessIncomeCtrl = TextEditingController();
  final TextEditingController rentBusinessWhtCtrl = TextEditingController();
  String rentMaintainedByUser = "No";

  final service = TaxDataService();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();

    if (widget.incomeType == "Employment") {
      annualEmploymentCtrls = {
        for (var cat in employmentCategories) cat: TextEditingController(),
      };
      monthlyEmploymentCtrls = List.generate(
        12,
        (monthIndex) => employmentCategories.map((cat) => {
              cat: TextEditingController(
                text: service.monthlyEmploymentCategories[monthIndex][cat] != null &&
                    service.monthlyEmploymentCategories[monthIndex][cat]! >= 0
                    ? service.monthlyEmploymentCategories[monthIndex][cat]!.toStringAsFixed(2)
                    : '',
              ),
            }).toList(),
      );
      monthlyApitCtrls = List.generate(12, (_) => TextEditingController());
    } else if (widget.incomeType == "Business") {
      annualBusinessCtrls = {
        for (var cat in businessCategories) cat: TextEditingController(),
      };
      monthlyBusinessCtrls = List.generate(
        12,
        (monthIndex) => businessCategories.map((cat) => {
              cat: TextEditingController(
                text: service.monthlyBusinessCategories[monthIndex][cat] != null &&
                    service.monthlyBusinessCategories[monthIndex][cat]! >= 0
                    ? service.monthlyBusinessCategories[monthIndex][cat]!.toStringAsFixed(2)
                    : '',
              ),
            }).toList(),
      );
      monthlyRentBusinessIncomeCtrls = List.generate(
        12,
        (monthIndex) => TextEditingController(
          text: service.monthlyRentBusinessIncome[monthIndex] != null &&
              service.monthlyRentBusinessIncome[monthIndex]! >= 0
              ? service.monthlyRentBusinessIncome[monthIndex]!.toStringAsFixed(2)
              : '',
        ),
      );
      monthlyRentBusinessWhtCtrls = List.generate(
        12,
        (monthIndex) => TextEditingController(
          text: service.monthlyRentBusinessWht[monthIndex] != null &&
              service.monthlyRentBusinessWht[monthIndex]! >= 0
              ? service.monthlyRentBusinessWht[monthIndex]!.toStringAsFixed(2)
              : '',
        ),
      );
      monthlyRentMaintainedByUser = List.generate(
        12,
        (monthIndex) => service.monthlyRentMaintainedByUser[monthIndex] ?? "No",
      );
    } else if (investmentCategories.contains(widget.incomeType)) {
      monthlyDynamicCtrls = List.generate(
        12,
        (monthIndex) => List.generate(
          service.monthlyInvestmentCategories[monthIndex][widget.incomeType]?.length ?? 1,
          (index) => TextEditingController(
            text: service.monthlyInvestmentCategories[monthIndex][widget.incomeType] != null &&
                service.monthlyInvestmentCategories[monthIndex][widget.incomeType]!.length > index &&
                service.monthlyInvestmentCategories[monthIndex][widget.incomeType]![index] >= 0
                ? service.monthlyInvestmentCategories[monthIndex][widget.incomeType]![index].toStringAsFixed(2)
                : '',
          ),
        ),
      );
    } else if (foreignCategories.contains(widget.incomeType)) {
      monthlyDynamicCtrls = List.generate(
        12,
        (monthIndex) => List.generate(
          service.monthlyForeignCategories[monthIndex][widget.incomeType]?.length ?? 1,
          (index) => TextEditingController(
            text: service.monthlyForeignCategories[monthIndex][widget.incomeType] != null &&
                service.monthlyForeignCategories[monthIndex][widget.incomeType]!.length > index &&
                service.monthlyForeignCategories[monthIndex][widget.incomeType]![index] >= 0
                ? service.monthlyForeignCategories[monthIndex][widget.incomeType]![index].toStringAsFixed(2)
                : '',
          ),
        ),
      );
    } else if (widget.incomeType == "Other") {
      monthlyDynamicCtrls = List.generate(
        12,
        (monthIndex) => List.generate(
          service.monthlyOtherCategories[monthIndex].length != 0 ? service.monthlyOtherCategories[monthIndex].length : 1,
          (index) => TextEditingController(
            text: service.monthlyOtherCategories[monthIndex].length > index &&
                service.monthlyOtherCategories[monthIndex][index] >= 0
                ? service.monthlyOtherCategories[monthIndex][index].toStringAsFixed(2)
                : '',
          ),
        ),
      );
    } else {
      monthlyDynamicCtrls = List.generate(12, (_) => [TextEditingController()]);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    annualCtrl.dispose();
    annualApitCtrl.dispose();
    monthlyApitCtrls.forEach((ctrl) => ctrl.dispose());
    monthlyRentBusinessIncomeCtrls.forEach((ctrl) => ctrl.dispose());
    monthlyRentBusinessWhtCtrls.forEach((ctrl) => ctrl.dispose());
    rentBusinessIncomeCtrl.dispose();
    rentBusinessWhtCtrl.dispose();
    for (var monthList in monthlyEmploymentCtrls) {
      for (var catMap in monthList) {
        catMap.values.first.dispose();
      }
    }
    for (var monthList in monthlyBusinessCtrls) {
      for (var catMap in monthList) {
        catMap.values.first.dispose();
      }
    }
    for (var monthList in monthlyDynamicCtrls) {
      for (var ctrl in monthList) {
        ctrl.dispose();
      }
    }
    annualEmploymentCtrls?.values.forEach((ctrl) => ctrl.dispose());
    annualBusinessCtrls?.values.forEach((ctrl) => ctrl.dispose());
    super.dispose();
  }

  void addDynamicField(int monthIndex) {
    setState(() => monthlyDynamicCtrls[monthIndex].add(TextEditingController()));
  }

  void saveIncome() async {
    double annual = 0.0;
    double apitAmount = 0.0;
    double rentIncome = 0.0;
    double rentWht = 0.0;
    bool maintainedByUser = false;

    if (selectedMode == "Annual") {
      if (widget.incomeType == "Employment") {
        annual = annualEmploymentCtrls.values
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .fold(0.0, (a, b) => a + b);
        apitAmount = double.tryParse(annualApitCtrl.text) ?? 0.0;
      } else if (widget.incomeType == "Business") {
        annual = annualBusinessCtrls.values
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .fold(0.0, (a, b) => a + b);
        rentIncome = double.tryParse(rentBusinessIncomeCtrl.text) ?? 0.0;
        rentWht = double.tryParse(rentBusinessWhtCtrl.text) ?? 0.0;
        maintainedByUser = rentMaintainedByUser == "Yes";
        service.rentBusinessIncome = rentIncome;
        service.rentBusinessWht = rentWht;
        service.rentMaintainedByUser = maintainedByUser;
        annual += rentIncome;
      } else {
        annual = double.tryParse(annualCtrl.text) ?? 0.0;
      }
    } else {
      annual = getAnnualIncome();
      if (widget.incomeType == "Employment") {
        apitAmount = monthlyApitCtrls
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .fold(0.0, (a, b) => a + b);
        if ((service.selectedTaxYear == "2024/2025" || service.selectedTaxYear == "2025/2026") && selectedMonthIndex != null) {
          double monthTotal = 0.0;
          for (var catMap in monthlyEmploymentCtrls[selectedMonthIndex!]) {
            final category = catMap.keys.first;
            final value = double.tryParse(catMap.values.first.text) ?? 0.0;
            service.monthlyEmploymentCategories[selectedMonthIndex!][category] = value;
            monthTotal += value;
          }
          service.monthlyEmploymentTotals[selectedMonthIndex!] = monthTotal;
        }
      } else if (widget.incomeType == "Business") {
        rentIncome = monthlyRentBusinessIncomeCtrls
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .fold(0.0, (a, b) => a + b);
        rentWht = monthlyRentBusinessWhtCtrls
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .fold(0.0, (a, b) => a + b);
        maintainedByUser = monthlyRentMaintainedByUser.any((val) => val == "Yes");
        service.rentBusinessIncome = rentIncome;
        service.rentBusinessWht = rentWht;
        service.rentMaintainedByUser = maintainedByUser;
        if ((service.selectedTaxYear == "2024/2025" || service.selectedTaxYear == "2025/2026") && selectedMonthIndex != null) {
          double monthTotal = monthlyBusinessCtrls[selectedMonthIndex!].fold(
            0.0,
            (sum, catMap) => sum + (double.tryParse(catMap.values.first.text) ?? 0.0),
          );
          monthTotal += double.tryParse(monthlyRentBusinessIncomeCtrls[selectedMonthIndex!].text) ?? 0.0;
          service.monthlyBusinessTotals[selectedMonthIndex!] = monthTotal;
          for (var catMap in monthlyBusinessCtrls[selectedMonthIndex!]) {
            final category = catMap.keys.first;
            final value = double.tryParse(catMap.values.first.text) ?? 0.0;
            service.monthlyBusinessCategories[selectedMonthIndex!][category] = value;
          }
          service.monthlyRentBusinessIncome[selectedMonthIndex!] =
              double.tryParse(monthlyRentBusinessIncomeCtrls[selectedMonthIndex!].text) ?? 0.0;
          service.monthlyRentBusinessWht[selectedMonthIndex!] =
              double.tryParse(monthlyRentBusinessWhtCtrls[selectedMonthIndex!].text) ?? 0.0;
          service.monthlyRentMaintainedByUser[selectedMonthIndex!] = monthlyRentMaintainedByUser[selectedMonthIndex!];
        }
      } else if (investmentCategories.contains(widget.incomeType)) {
        if ((service.selectedTaxYear == "2024/2025" || service.selectedTaxYear == "2025/2026") && selectedMonthIndex != null) {
          double monthTotal = monthlyDynamicCtrls[selectedMonthIndex!]
              .map((c) => double.tryParse(c.text) ?? 0.0)
              .fold(0.0, (sum, value) => sum + value);
          service.monthlyInvestmentTotals[selectedMonthIndex!] = monthTotal;
          service.monthlyInvestmentCategories[selectedMonthIndex!][widget.incomeType] = monthlyDynamicCtrls[selectedMonthIndex!]
              .map((c) => double.tryParse(c.text) ?? 0.0)
              .toList();
        }
      } else if (foreignCategories.contains(widget.incomeType)) {
        if ((service.selectedTaxYear == "2024/2025" || service.selectedTaxYear == "2025/2026") && selectedMonthIndex != null) {
          double monthTotal = monthlyDynamicCtrls[selectedMonthIndex!]
              .map((c) => double.tryParse(c.text) ?? 0.0)
              .fold(0.0, (sum, value) => sum + value);
          service.monthlyForeignTotals[selectedMonthIndex!] = monthTotal;
          service.monthlyForeignCategories[selectedMonthIndex!][widget.incomeType] = monthlyDynamicCtrls[selectedMonthIndex!]
              .map((c) => double.tryParse(c.text) ?? 0.0)
              .toList();
        }
      } else if (widget.incomeType == "Other") {
        if ((service.selectedTaxYear == "2024/2025" || service.selectedTaxYear == "2025/2026") && selectedMonthIndex != null) {
          double monthTotal = monthlyDynamicCtrls[selectedMonthIndex!]
              .map((c) => double.tryParse(c.text) ?? 0.0)
              .fold(0.0, (sum, value) => sum + value);
          service.monthlyOtherTotals[selectedMonthIndex!] = monthTotal;
          service.monthlyOtherCategories[selectedMonthIndex!] = monthlyDynamicCtrls[selectedMonthIndex!]
              .map((c) => double.tryParse(c.text) ?? 0.0)
              .toList();
        }
      }
    }

    if ((service.selectedTaxYear == "2024/2025" || service.selectedTaxYear == "2025/2026") &&
        selectedMode == "Monthly" &&
        widget.incomeType == "Employment" &&
        selectedMonthIndex == null) {
      for (int i = 0; i < 12; i++) {
        double monthTotal = monthlyEmploymentCtrls[i].fold(
          0.0,
          (sum, catMap) => sum + (double.tryParse(catMap.values.first.text) ?? 0.0),
        );
        service.monthlyEmploymentTotals[i] = monthTotal;
        for (var catMap in monthlyEmploymentCtrls[i]) {
          final category = catMap.keys.first;
          final value = double.tryParse(catMap.values.first.text) ?? 0.0;
          service.monthlyEmploymentCategories[i][category] = value;
        }
      }
    }

    if ((service.selectedTaxYear == "2024/2025" || service.selectedTaxYear == "2025/2026") &&
        selectedMode == "Monthly" &&
        widget.incomeType == "Business" &&
        selectedMonthIndex == null) {
      for (int i = 0; i < 12; i++) {
        double monthTotal = monthlyBusinessCtrls[i].fold(
          0.0,
          (sum, catMap) => sum + (double.tryParse(catMap.values.first.text) ?? 0.0),
        );
        monthTotal += double.tryParse(monthlyRentBusinessIncomeCtrls[i].text) ?? 0.0;
        service.monthlyBusinessTotals[i] = monthTotal;
        for (var catMap in monthlyBusinessCtrls[i]) {
          final category = catMap.keys.first;
          final value = double.tryParse(catMap.values.first.text) ?? 0.0;
          service.monthlyBusinessCategories[i][category] = value;
        }
        service.monthlyRentBusinessIncome[i] = double.tryParse(monthlyRentBusinessIncomeCtrls[i].text) ?? 0.0;
        service.monthlyRentBusinessWht[i] = double.tryParse(monthlyRentBusinessWhtCtrls[i].text) ?? 0.0;
        service.monthlyRentMaintainedByUser[i] = monthlyRentMaintainedByUser[i];
      }
    }

    if ((service.selectedTaxYear == "2024/2025" || service.selectedTaxYear == "2025/2026") &&
        selectedMode == "Monthly" &&
        investmentCategories.contains(widget.incomeType) &&
        selectedMonthIndex == null) {
      for (int i = 0; i < 12; i++) {
        double monthTotal = monthlyDynamicCtrls[i]
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .fold(0.0, (sum, value) => sum + value);
        service.monthlyInvestmentTotals[i] = monthTotal;
        service.monthlyInvestmentCategories[i][widget.incomeType] = monthlyDynamicCtrls[i]
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .toList();
      }
    }

    if ((service.selectedTaxYear == "2024/2025" || service.selectedTaxYear == "2025/2026") &&
        selectedMode == "Monthly" &&
        foreignCategories.contains(widget.incomeType) &&
        selectedMonthIndex == null) {
      for (int i = 0; i < 12; i++) {
        double monthTotal = monthlyDynamicCtrls[i]
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .fold(0.0, (sum, value) => sum + value);
        service.monthlyForeignTotals[i] = monthTotal;
        service.monthlyForeignCategories[i][widget.incomeType] = monthlyDynamicCtrls[i]
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .toList();
      }
    }

    if ((service.selectedTaxYear == "2024/2025" || service.selectedTaxYear == "2025/2026") &&
        selectedMode == "Monthly" &&
        widget.incomeType == "Other" &&
        selectedMonthIndex == null) {
      for (int i = 0; i < 12; i++) {
        double monthTotal = monthlyDynamicCtrls[i]
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .fold(0.0, (sum, value) => sum + value);
        service.monthlyOtherTotals[i] = monthTotal;
        service.monthlyOtherCategories[i] = monthlyDynamicCtrls[i]
            .map((c) => double.tryParse(c.text) ?? 0.0)
            .toList();
      }
    }

    if (widget.incomeType == "Employment") {
      service.totalEmploymentIncome = annual;
      service.apitAmount = apitAmount;
    } else if (widget.incomeType == "Business") {
      service.totalBusinessIncome = annual;
    } else if (widget.incomeType == "Investment") {
      service.investmentCategories[widget.incomeType] = annual;
      service.calculateTotalInvestmentIncome();
    } else if (widget.incomeType == "Rent Income") {
      service.totalRentIncome = annual;
    } else if (widget.incomeType == "Solar Income") {
      service.totalSolarIncome = annual;
    } else if (widget.incomeType == "Other") {
      service.totalOtherIncome = annual;
    } else if (widget.incomeType.startsWith("Foreign")) {
      service.foreignIncomeCategories[widget.incomeType] = annual;
      service.calculateTotalForeignIncome();
    } else {
      if (investmentCategories.contains(widget.incomeType)) {
        service.investmentCategories[widget.incomeType] = annual;
        service.calculateTotalInvestmentIncome();
      } else {
        service.totalDomesticIncome += annual;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Saved ${widget.incomeType} income: Rs. ${annual.toStringAsFixed(2)}",
              ),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    }

    try {
      await FirestoreService.saveCalculatorData(service.getAllDataAsMap());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save to Firestore: $e"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }

    if (mounted) Navigator.pop(context);
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
      total += monthlyRentBusinessIncomeCtrls
          .map((c) => double.tryParse(c.text) ?? 0.0)
          .fold(0.0, (a, b) => a + b);
      return total;
    } else {
      return IncomeCalculator.calculateAnnualDynamic(
        monthlyDynamicCtrls.map((monthCtrls) => monthCtrls.map((c) => double.tryParse(c.text) ?? 0.0).toList()).toList(),
      );
    }
  }

  Widget _buildModeToggle() {
    const primaryColor = Color(0xFF38E07B);
    const primaryDark = Color(0xFF2DD96A);
    const neutral300 = Color(0xFFdce5df);
    const neutral50 = Color(0xFFf8faf9);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: ["Annual", "Monthly"].map((mode) {
          final selected = selectedMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                selectedMode = mode;
                selectedMonthIndex = null;
              }),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  mode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthSelector() {
    const primaryColor = Color(0xFF38E07B);
    const primaryLight = Color(0xFF5FE896);
    const neutral50 = Color(0xFFf8faf9);
    const neutral900 = Color(0xFF111714);

    return Container(
      height: 70,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, i) {
          final selected = selectedMonthIndex == i;
          return GestureDetector(
            onTap: () => setState(() => selectedMonthIndex = i),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        colors: [primaryColor, primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected ? null : neutral50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? primaryColor : primaryColor.withOpacity(0.3),
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  months[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected ? Colors.white : neutral900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRentSection() {
    const primaryColor = Color(0xFF38E07B);
    const accentGreen = Color(0xFF10B981);
    const neutral300 = Color(0xFFdce5df);
    const neutral900 = Color(0xFF111714);

    final rentIncomeCtrl = selectedMode == "Monthly" && selectedMonthIndex != null
        ? monthlyRentBusinessIncomeCtrls[selectedMonthIndex!]
        : rentBusinessIncomeCtrl;
    final rentWhtCtrl = selectedMode == "Monthly" && selectedMonthIndex != null
        ? monthlyRentBusinessWhtCtrls[selectedMonthIndex!]
        : rentBusinessWhtCtrl;
    final maintainedByUser = selectedMode == "Monthly" && selectedMonthIndex != null
        ? monthlyRentMaintainedByUser[selectedMonthIndex!]
        : rentMaintainedByUser;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryColor, accentGreen]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.home_work, color: Colors.white, size: 18),
              ),
              SizedBox(width: 12),
              Text(
                "Rent for Business Purpose",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: neutral900,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          IncomeField(
            controller: rentIncomeCtrl,
            label: selectedMode == "Monthly" && selectedMonthIndex != null
                ? "Rent Income (${months[selectedMonthIndex!]})"
                : "Rent Income",
          ),
          SizedBox(height: 12),
          IncomeField(
            controller: rentWhtCtrl,
            label: selectedMode == "Monthly" && selectedMonthIndex != null
                ? "WHT Amount (${months[selectedMonthIndex!]})"
                : "WHT Amount",
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: neutral300),
            ),
            child: Row(
              children: [
                Text(
                  "Maintained by User? ",
                  style: TextStyle(
                    color: neutral900.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: maintainedByUser,
                    underline: SizedBox(),
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      color: neutral900,
                      fontWeight: FontWeight.w500,
                    ),
                    items: ["Yes", "No"].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                    onChanged: (val) => setState(() {
                      if (selectedMode == "Monthly" && selectedMonthIndex != null) {
                        monthlyRentMaintainedByUser[selectedMonthIndex!] = val ?? "No";
                      } else {
                        rentMaintainedByUser = val ?? "No";
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF38E07B);
    const primaryLight = Color(0xFF5FE896);
    const neutral50 = Color(0xFFf8faf9);
    const neutral900 = Color(0xFF111714);
    const accentGreen = Color(0xFF10B981);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              neutral50,
              primaryColor.withOpacity(0.05),
              primaryLight.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryColor.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.incomeType} Income",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: neutral900,
                              ),
                            ),
                            Text(
                              "Enter your income details",
                              style: TextStyle(
                                fontSize: 14,
                                color: accentGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                _buildModeToggle(),
                if (selectedMode == "Monthly") _buildMonthSelector(),

                Expanded(
                  child: selectedMode == "Annual"
                      ? _buildAnnualView()
                      : selectedMonthIndex != null
                          ? _buildMonthlyView()
                          : Center(
                              child: Container(
                                padding: EdgeInsets.all(32),
                                margin: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [primaryColor, accentGreen]),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.calendar_month_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Select a month to continue",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saveIncome,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        label: Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: Icon(Icons.save_rounded),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildAnnualView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: widget.incomeType == "Employment"
          ? Column(
              children: [
                ...annualEmploymentCtrls.keys.map(
                  (label) => Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: IncomeField(
                      controller: annualEmploymentCtrls[label]!,
                      label: label,
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  margin: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xFF38E07B), Colors.transparent],
                    ),
                  ),
                ),
                IncomeField(controller: annualApitCtrl, label: "APIT Amount"),
              ],
            )
          : widget.incomeType == "Business"
              ? Column(
                  children: [
                    ...annualBusinessCtrls.keys.map((label) {
                      if (label == "Rent for Business Purpose") return _buildRentSection();
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: IncomeField(
                          controller: annualBusinessCtrls[label]!,
                          label: label,
                        ),
                      );
                    }),
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
    );
  }

  Widget _buildMonthlyView() {
    const primaryColor = Color(0xFF38E07B);
    const accentGreen = Color(0xFF10B981);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: widget.incomeType == "Employment"
          ? Column(
              children: [
                ...monthlyEmploymentCtrls[selectedMonthIndex!].map((catMap) {
                  final label = catMap.keys.first;
                  final ctrl = catMap.values.first;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: IncomeField(controller: ctrl, label: label),
                  );
                }),
                Container(
                  height: 2,
                  margin: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, primaryColor, Colors.transparent],
                    ),
                  ),
                ),
                IncomeField(
                  controller: monthlyApitCtrls[selectedMonthIndex!],
                  label: "APIT Amount (${months[selectedMonthIndex!]})",
                ),
              ],
            )
          : widget.incomeType == "Business"
              ? Column(
                  children: [
                    ...monthlyBusinessCtrls[selectedMonthIndex!].map((catMap) {
                      final label = catMap.keys.first;
                      final ctrl = catMap.values.first;
                      if (label == "Rent for Business Purpose") return _buildRentSection();
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: IncomeField(controller: ctrl, label: label),
                      );
                    }),
                  ],
                )
              : Column(
                  children: [
                    ...List.generate(
                      monthlyDynamicCtrls[selectedMonthIndex!].length,
                      (j) => Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: IncomeField(
                          controller: monthlyDynamicCtrls[selectedMonthIndex!][j],
                          label: "${widget.incomeType} ${j + 1}",
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => addDynamicField(selectedMonthIndex!),
                      icon: Icon(Icons.add_circle_outline),
                      label: Text("Add ${widget.incomeType} Income"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
    );
  }
}