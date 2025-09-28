//pages/qualifying_payment_page.dart
//pages/qualifying_payment_page.dart
import 'package:flutter/material.dart';
import '../widgets/income_field.dart';
import '../services/tax_data_service.dart';
import 'exempt_income_page.dart';
import '../services/firestore_service.dart';

class QualifyingPaymentsPage extends StatefulWidget {
  const QualifyingPaymentsPage({super.key});

  @override
  State<QualifyingPaymentsPage> createState() => _QualifyingPaymentsPageState();
}

class _QualifyingPaymentsPageState extends State<QualifyingPaymentsPage>
    with TickerProviderStateMixin {
  final TaxDataService service = TaxDataService();

  final TextEditingController charityCtrl = TextEditingController();
  final TextEditingController govDonationsCtrl = TextEditingController();
  final TextEditingController presidentsFundCtrl = TextEditingController();
  final TextEditingController femaleShopCtrl = TextEditingController();
  final TextEditingController filmExpenditureCtrl = TextEditingController();
  final TextEditingController cinemaNewCtrl = TextEditingController();
  final TextEditingController cinemaUpgradeCtrl = TextEditingController();

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

    charityCtrl.text = service.charity.toString();
    govDonationsCtrl.text = service.govDonations.toString();
    presidentsFundCtrl.text = service.presidentsFund.toString();
    femaleShopCtrl.text = service.femaleShop.toString();
    filmExpenditureCtrl.text = service.filmExpenditure.toString();
    cinemaNewCtrl.text = service.cinemaNew.toString();
    cinemaUpgradeCtrl.text = service.cinemaUpgrade.toString();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    charityCtrl.dispose();
    govDonationsCtrl.dispose();
    presidentsFundCtrl.dispose();
    femaleShopCtrl.dispose();
    filmExpenditureCtrl.dispose();
    cinemaNewCtrl.dispose();
    cinemaUpgradeCtrl.dispose();
    super.dispose();
  }

  void savePayments() async {
    service.charity = double.tryParse(charityCtrl.text) ?? 0.0;
    service.govDonations = double.tryParse(govDonationsCtrl.text) ?? 0.0;
    service.presidentsFund = double.tryParse(presidentsFundCtrl.text) ?? 0.0;
    service.femaleShop = double.tryParse(femaleShopCtrl.text) ?? 0.0;
    service.filmExpenditure = double.tryParse(filmExpenditureCtrl.text) ?? 0.0;
    service.cinemaNew = double.tryParse(cinemaNewCtrl.text) ?? 0.0;
    service.cinemaUpgrade = double.tryParse(cinemaUpgradeCtrl.text) ?? 0.0;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Payments saved successfully"),
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
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    const primaryColor = Color(0xFF38E07B);
    const accentGreen = Color(0xFF10B981);
    const neutral900 = Color(0xFF111714);

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(24),
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
                child: Icon(icon, color: Colors.white, size: 24),
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildExemptIncomeButton() {
    const primaryColor = Color(0xFF38E07B);
    const primaryDark = Color(0xFF2DD96A);
    const accentGreen = Color(0xFF10B981);
    const neutral900 = Color(0xFF111714);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.1),
            accentGreen.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExemptIncomePage(),
                      ),
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.account_balance_outlined),
                  label: Text("Enter Exempt Income"),
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((
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
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.savings, color: accentGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  "Saved Amount:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: neutral900.withOpacity(0.7),
                  ),
                ),
                Spacer(),
                Text(
                  "Rs. ${service.exemptIncome.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentGreen,
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
                              "Qualifying Payments",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: neutral900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Enter your eligible deductions",
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

                // Content
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Qualifying Payments Section
                          _buildSectionCard(
                            title: "Qualifying Payments",
                            icon: Icons.payment_rounded,
                            children: [
                              IncomeField(
                                controller: charityCtrl,
                                label: "Donations to Charity",
                              ),
                              SizedBox(height: 12),
                              IncomeField(
                                controller: govDonationsCtrl,
                                label: "Donations to Govt/Institutions",
                              ),
                              SizedBox(height: 12),
                              IncomeField(
                                controller: presidentsFundCtrl,
                                label: "Profits to President's Fund",
                              ),
                              SizedBox(height: 12),
                              IncomeField(
                                controller: femaleShopCtrl,
                                label: "Contribution for Female Shop",
                              ),
                              SizedBox(height: 12),
                              IncomeField(
                                controller: filmExpenditureCtrl,
                                label: "Film Production Expenditure",
                              ),
                              SizedBox(height: 12),
                              IncomeField(
                                controller: cinemaNewCtrl,
                                label: "New Cinema Construction",
                              ),
                              SizedBox(height: 12),
                              IncomeField(
                                controller: cinemaUpgradeCtrl,
                                label: "Cinema Upgrade Expenditure",
                              ),
                            ],
                          ),

                          // Other Declarations Section
                          _buildSectionCard(
                            title: "Other Declarations",
                            icon: Icons.description_rounded,
                            children: [_buildExemptIncomeButton()],
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
        onPressed: savePayments,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        label: Text(
          "Save Payments",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: Icon(Icons.save_rounded),
      ),
    );
  }
}
