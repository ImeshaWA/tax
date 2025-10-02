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

class InterestIncomePageState extends State<InterestIncomePage>
    with TickerProviderStateMixin {
  final TaxDataService service = TaxDataService();

  // List of months for dropdown
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

  // Each account holds: [interest controller, selected month, WHT controller]
  List<List<dynamic>> fixedDepositAccounts = [];
  List<List<dynamic>> savingAccounts = [];

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
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();

    // Add one default account for each category
    fixedDepositAccounts.add([
      TextEditingController(),
      months[0], // Default to first month
      TextEditingController(),
    ]);
    savingAccounts.add([
      TextEditingController(),
      months[0], // Default to first month
      TextEditingController(),
    ]);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    // Dispose only interest and WHT controllers
    for (var acc in fixedDepositAccounts) {
      acc[0].dispose(); // Interest controller
      acc[2].dispose(); // WHT controller
    }
    for (var acc in savingAccounts) {
      acc[0].dispose(); // Interest controller
      acc[2].dispose(); // WHT controller
    }
    super.dispose();
  }

  void addFixedDepositAccount() {
    setState(() {
      fixedDepositAccounts.add([
        TextEditingController(),
        months[0], // Default to first month
        TextEditingController(),
      ]);
    });
  }

  void addSavingAccount() {
    setState(() {
      savingAccounts.add([
        TextEditingController(),
        months[0], // Default to first month
        TextEditingController(),
      ]);
    });
  }

  void saveInterestIncome() async {
    double total = 0.0;

    // Initialize monthly investment totals for the tax year 2025/2026
    if (service.selectedTaxYear == "2025/2026") {
      for (int i = 0; i < 12; i++) {
        service.monthlyInvestmentTotals[i] = 0.0; // Reset to avoid accumulation
      }
    }

    // Fixed Deposit Income
    for (var acc in fixedDepositAccounts) {
      double amount = double.tryParse(acc[0].text) ?? 0.0;
      total += amount;
      if (service.selectedTaxYear == "2025/2026") {
        int monthIndex = months.indexOf(acc[1]);
        service.monthlyInvestmentTotals[monthIndex] += amount;
      }
    }

    // Saving Account Income
    for (var acc in savingAccounts) {
      double amount = double.tryParse(acc[0].text) ?? 0.0;
      total += amount;
      if (service.selectedTaxYear == "2025/2026") {
        int monthIndex = months.indexOf(acc[1]);
        service.monthlyInvestmentTotals[monthIndex] += amount;
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Interest income saved"),
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
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text("Failed to save to Firestore: $e")),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
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
    List<List<dynamic>> accounts,
    VoidCallback onAdd,
  ) {
    const primaryColor = Color(0xFF38E07B);
    const primaryDark = Color(0xFF2DD96A);
    const accentGreen = Color(0xFF10B981);
    const neutral900 = Color(0xFF111714);
    const neutral300 = Color(0xFFdce5df);

    return Container(
      margin: EdgeInsets.only(bottom: 24),
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
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, accentGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  title == "Fixed Deposit"
                      ? Icons.savings
                      : Icons.account_balance,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: neutral900,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.05),
                      accentGreen.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Account ${index + 1}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    IncomeField(
                      controller: accounts[index][0],
                      label: "$title ${index + 1} - Interest Income (Gross)",
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: neutral300),
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              "Month income received?",
                              style: TextStyle(
                                color: neutral900.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: accounts[index][1],
                              underline: SizedBox(),
                              dropdownColor: Colors.white,
                              style: TextStyle(
                                color: neutral900,
                                fontWeight: FontWeight.w500,
                              ),
                              items: months
                                  .map(
                                    (val) => DropdownMenuItem(
                                      value: val,
                                      child: Text(val),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) => setState(() {
                                accounts[index][1] = val ?? months[0];
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    IncomeField(
                      controller: accounts[index][2],
                      label: "$title ${index + 1} - WHT Amount",
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add_circle_outline),
              label: Text("Add Another $title Account"),
              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: primaryColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.pressed))
                        return primaryDark;
                      return primaryColor;
                    }),
                  ),
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
                // Custom App Bar
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
                            border: Border.all(
                              color: primaryColor.withOpacity(0.2),
                            ),
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
                              "Interest Income",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: neutral900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Enter your interest income details",
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

                // Header Section
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, accentGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
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
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.savings_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Interest Income Details",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Add your fixed deposit and savings account interest income",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Content
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
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
                          SizedBox(height: 100), // Space for floating button
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
        onPressed: saveInterestIncome,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        label: Text(
          "Save Interest Income",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: Icon(Icons.save_rounded),
      ),
    );
  }
}
