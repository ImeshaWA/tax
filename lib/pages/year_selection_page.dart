//pages/year_selection_page.dart
import 'package:flutter/material.dart';
import 'mode_selection_page.dart';
import '../services/tax_data_service.dart';

import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YearSelectionPage extends StatefulWidget {
  const YearSelectionPage({super.key});

  @override
  State<YearSelectionPage> createState() => _YearSelectionPageState();
}

class _YearSelectionPageState extends State<YearSelectionPage>
    with TickerProviderStateMixin {
  String? selectedYear;
  final List<String> taxYears = ["2024/2025", "2025/2026"];
  final TaxDataService service = TaxDataService();
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _listAnimation;
  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();

    FirestoreService.getUserData().listen((snapshot) {
  if (snapshot.exists) {
    final data = snapshot.data() as Map<String, dynamic>;
    // Update TaxDataService with loaded data
    service.selectedTaxYear = data['selectedTaxYear'] ?? '2024/2025';
    service.charity = (data['charity'] as num?)?.toDouble() ?? 0.0;
    service.govDonations = (data['govDonations'] as num?)?.toDouble() ?? 0.0;
    service.presidentsFund = (data['presidentsFund'] as num?)?.toDouble() ?? 0.0;
    service.femaleShop = (data['femaleShop'] as num?)?.toDouble() ?? 0.0;
    service.filmExpenditure = (data['filmExpenditure'] as num?)?.toDouble() ?? 0.0;
    service.cinemaNew = (data['cinemaNew'] as num?)?.toDouble() ?? 0.0;
    service.cinemaUpgrade = (data['cinemaUpgrade'] as num?)?.toDouble() ?? 0.0;
    service.exemptIncome = (data['exemptIncome'] as num?)?.toDouble() ?? 0.0;
    service.foreignTaxCredits = (data['foreignTaxCredits'] as num?)?.toDouble() ?? 0.0;
    service.totalDomesticIncome = (data['totalDomesticIncome'] as num?)?.toDouble() ?? 0.0;
    service.totalForeignIncome = (data['totalForeignIncome'] as num?)?.toDouble() ?? 0.0;
    service.totalEmploymentIncome = (data['totalEmploymentIncome'] as num?)?.toDouble() ?? 0.0;
    service.totalBusinessIncome = (data['totalBusinessIncome'] as num?)?.toDouble() ?? 0.0;
    service.totalInvestmentIncome = (data['totalInvestmentIncome'] as num?)?.toDouble() ?? 0.0;
    service.totalRentIncome = (data['totalRentIncome'] as num?)?.toDouble() ?? 0.0;
    service.rentBusinessIncome = (data['rentBusinessIncome'] as num?)?.toDouble() ?? 0.0;
    service.rentBusinessWht = (data['rentBusinessWht'] as num?)?.toDouble() ?? 0.0;
    service.totalSolarIncome = (data['totalSolarIncome'] as num?)?.toDouble() ?? 0.0;
    service.totalOtherIncome = (data['totalOtherIncome'] as num?)?.toDouble() ?? 0.0;
    service.employmentCategories = Map<String, double>.from(data['employmentCategories'] ?? {});
    service.businessCategories = Map<String, double>.from(data['businessCategories'] ?? {});
    service.investmentCategories = Map<String, double>.from(data['investmentCategories'] ?? {});
    service.foreignIncomeCategories = Map<String, double>.from(data['foreignIncomeCategories'] ?? {});
    service.apitAmount = (data['apitAmount'] as num?)?.toDouble() ?? 0.0;
    service.rentMaintainedByUser = data['rentMaintainedByUser'] ?? false;
    service.solarInstallCost = (data['solarInstallCost'] as num?)?.toDouble() ?? 0.0;
    service.solarReliefCount = (data['solarReliefCount'] as num?)?.toInt() ?? 0;
    service.rentRelief = (data['rentRelief'] as num?)?.toDouble() ?? 0.0;
    service.solarPanel = (data['solarPanel'] as num?)?.toDouble() ?? 0.0;
    service.isMaintainedByUser = data['isMaintainedByUser'];
    setState(() {});  // Refresh UI if needed
  }
});


    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listController, curve: Curves.easeOutBack),
    );

    // Create individual animations for each tax year item
    _itemControllers = taxYears
        .map(
          (year) => AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
          ),
        )
        .toList();

    _itemAnimations = _itemControllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 1.05).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _listController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleYearSelection() async {
    if (selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text("Please select a tax year"),
            ],
          ),
          backgroundColor: Colors.orange.shade500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Save selected year to TaxDataService
    service.selectedTaxYear = selectedYear!;

    // Simulate processing delay for better UX
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _isLoading = false;
    });

    // Navigate to ModeSelectionPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ModeSelectionPage()),
    );
  }

  void _onYearTap(String year, int index) {
    setState(() => selectedYear = year);

    // Animate the tapped item
    _itemControllers[index].forward().then((_) {
      _itemControllers[index].reverse();
    });

    // Provide haptic feedback
    // HapticFeedback.selectionClick(); // Uncomment if you want haptic feedback
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF38E07B);
    const primaryDark = Color(0xFF2DD96A);
    const primaryLight = Color(0xFF5FE896);
    const neutral900 = Color(0xFF111714);
    const neutral300 = Color(0xFFdce5df);
    const neutral50 = Color(0xFFf8faf9);
    const accentGreen = Color(0xFF10B981);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.08),
              neutral50,
              primaryLight.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tax Year Selection",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: neutral900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Choose your assessment year",
                              style: TextStyle(
                                fontSize: 14,
                                color: neutral900.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Step 1 - Completed
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      Expanded(
                        child: Container(height: 2, color: primaryColor),
                      ),
                      // Step 2 - Current
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            "2",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: Container(height: 2, color: neutral300)),
                      // Step 3 - Pending
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: neutral300,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            "3",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Available Tax Years",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: neutral900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Select the tax year for your income calculation",
                              style: TextStyle(
                                fontSize: 14,
                                color: neutral900.withOpacity(0.7),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tax Years List
                      Expanded(
                        child: ScaleTransition(
                          scale: _listAnimation,
                          child: ListView.builder(
                            itemCount: taxYears.length,
                            itemBuilder: (context, index) {
                              final year = taxYears[index];
                              final selected = selectedYear == year;

                              return AnimatedBuilder(
                                animation: _itemAnimations[index],
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _itemAnimations[index].value,
                                    child: GestureDetector(
                                      onTap: () => _onYearTap(year, index),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? primaryColor.withOpacity(0.1)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: selected
                                                ? primaryColor
                                                : neutral300,
                                            width: selected ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: selected
                                                  ? primaryColor.withOpacity(
                                                      0.15,
                                                    )
                                                  : Colors.black.withOpacity(
                                                      0.05,
                                                    ),
                                              blurRadius: selected ? 15 : 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Calendar Icon
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: selected
                                                    ? primaryColor.withOpacity(
                                                        0.2,
                                                      )
                                                    : neutral300.withOpacity(
                                                        0.3,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.calendar_today_rounded,
                                                color: selected
                                                    ? primaryColor
                                                    : neutral900.withOpacity(
                                                        0.7,
                                                      ),
                                                size: 20,
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            // Year Text
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Tax Year $year",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: selected
                                                          ? FontWeight.bold
                                                          : FontWeight.w600,
                                                      color: neutral900,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "Assessment Year $year",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: neutral900
                                                          .withOpacity(0.6),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Selection Indicator
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              height: 28,
                                              width: 28,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: selected
                                                      ? primaryColor
                                                      : neutral300,
                                                  width: 2,
                                                ),
                                                color: selected
                                                    ? primaryColor
                                                    : Colors.white,
                                              ),
                                              child: selected
                                                  ? const Icon(
                                                      Icons.check_rounded,
                                                      size: 16,
                                                      color: Colors.white,
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Continue Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleYearSelection,
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor: selectedYear != null
                                ? primaryColor
                                : neutral300,
                            foregroundColor: selectedYear != null
                                ? Colors.white
                                : neutral900.withOpacity(0.5),
                            elevation: selectedYear != null ? 4 : 0,
                            shadowColor: primaryColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ).copyWith(
                            elevation: WidgetStateProperty.resolveWith<double>((
                              Set<WidgetState> states,
                            ) {
                              if (selectedYear == null) return 0;
                              if (states.contains(WidgetState.pressed))
                                return 2;
                              if (states.contains(WidgetState.hovered))
                                return 8;
                              return 4;
                            }),
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  Set<WidgetState> states,
                                ) {
                                  if (selectedYear == null) return neutral300;
                                  if (states.contains(WidgetState.pressed))
                                    return primaryDark;
                                  return primaryColor;
                                }),
                          ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Processing...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Continue",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                  color: selectedYear != null
                                      ? Colors.white
                                      : neutral900.withOpacity(0.5),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
