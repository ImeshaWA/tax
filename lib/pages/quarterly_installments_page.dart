//pages/quarterly_installment_page.dart 
import 'package:flutter/material.dart'; 
import '../services/tax_computation_service.dart'; 
import '../services/tax_data_service.dart'; 
import '../services/income_calculator.dart'; 
 
class QuarterlyInstallmentsPage extends StatefulWidget { 
  const QuarterlyInstallmentsPage({super.key}); 
 
  @override 
  State<QuarterlyInstallmentsPage> createState() => 
      _QuarterlyInstallmentsPageState(); 
} 
 
class _QuarterlyInstallmentsPageState extends 
State<QuarterlyInstallmentsPage> 
    with TickerProviderStateMixin { 
  late final TaxComputationService taxService; 
  late final IncomeCalculator incomeCalculator; 
  late AnimationController _fadeController; 
  late AnimationController _slideController; 
  late Animation<double> _fadeAnimation; 
  late Animation<Offset> _slideAnimation; 
  late List<AnimationController> _cardControllers; 
  late List<Animation<double>> _cardAnimations; 
 
  @override 
  void initState() { 
    super.initState(); 
    taxService = TaxComputationService(); 
    incomeCalculator = IncomeCalculator(); 
 
    _fadeController = AnimationController( 
      duration: Duration(milliseconds: 1000), 
      vsync: this, 
    ); 
    _slideController = AnimationController( 
      duration: Duration(milliseconds: 800), 
      vsync: this, 
    ); 
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate( 
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut), 
    ); 
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero) 
        .animate( 
          CurvedAnimation(parent: _slideController, curve: 
Curves.easeOutCubic), 
        ); 
 
    _cardControllers = List.generate( 
      4, 
      (index) => AnimationController( 
        duration: Duration(milliseconds: 800), 
        vsync: this, 
      ), 
    ); 
    _cardAnimations = _cardControllers 
        .map( 
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate( 
            CurvedAnimation(parent: controller, curve: Curves.easeOutBack), 
          ), 
        ) 
        .toList(); 
 
    _fadeController.forward(); 
    _slideController.forward(); 
 
    for (int i = 0; i < _cardControllers.length; i++) { 
      Future.delayed(Duration(milliseconds: 200 * i), () { 
        if (mounted) _cardControllers[i].forward(); 
      }); 
    } 
  } 
 
  @override 
  void dispose() { 
    _fadeController.dispose(); 
    _slideController.dispose(); 
    for (var controller in _cardControllers) { 
      controller.dispose(); 
    } 
    super.dispose(); 
  } 
 
  Widget _buildSectionCard({ 
    required String title, 
    required IconData icon, 
    required Color color, 
    required List<Widget> children, 
    required int animationIndex, 
  }) { 
    return FadeTransition( 
      opacity: _cardAnimations[animationIndex], 
      child: SlideTransition( 
        position: Tween<Offset>( 
          begin: Offset(0, 0.3), 
          end: Offset.zero, 
        ).animate(_cardControllers[animationIndex]), 
        child: Container( 
          margin: EdgeInsets.only(bottom: 20), 
          decoration: BoxDecoration( 
            color: Colors.white.withOpacity(0.95), 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: color.withOpacity(0.2)), 
            boxShadow: [ 
              BoxShadow( 
                color: Colors.black.withOpacity(0.05), 
                blurRadius: 15, 
                offset: Offset(0, 5), 
              ), 
            ], 
          ), 
          child: Column( 
            children: [ 
              Container( 
                padding: EdgeInsets.all(20), 
                decoration: BoxDecoration( 
                  gradient: LinearGradient( 
                    colors: [color.withOpacity(0.1), 
color.withOpacity(0.05)], 
                    begin: Alignment.topLeft, 
                    end: Alignment.bottomRight, 
                  ), 
                  borderRadius: BorderRadius.vertical(top: 
Radius.circular(20)), 
                ), 
                child: Row( 
                  children: [ 
                    Container( 
                      padding: EdgeInsets.all(12), 
                      decoration: BoxDecoration( 
                        color: color, 
                        borderRadius: BorderRadius.circular(12), 
                        boxShadow: [ 
                          BoxShadow( 
                            color: color.withOpacity(0.3), 
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
                          color: Color(0xFF111714), 
                          letterSpacing: -0.3, 
                        ), 
                      ), 
                    ), 
                  ], 
                ), 
              ), 
              Padding( 
                padding: EdgeInsets.all(20), 
                child: Column(children: children), 
              ), 
            ], 
          ), 
        ), 
      ), 
    ); 
  } 
 
  Widget summaryRow( 
    String label, 
    double value, { 
    bool isHighlight = false, 
    Color? valueColor, 
  }) { 
    const neutral900 = Color(0xFF111714); 
    const accentGreen = Color(0xFF10B981); 
 
    return Container( 
      margin: EdgeInsets.symmetric(vertical: 4), 
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), 
      decoration: BoxDecoration( 
        color: isHighlight ? accentGreen.withOpacity(0.1) : 
Colors.transparent, 
        borderRadius: BorderRadius.circular(12), 
        border: isHighlight 
            ? Border.all(color: accentGreen.withOpacity(0.3)) 
            : null, 
      ), 
      child: Row( 
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [ 
          Expanded( 
            child: Text( 
              label, 
              style: TextStyle( 
                fontSize: isHighlight ? 16 : 15, 
                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500, 
                color: neutral900, 
                height: 1.3, 
              ), 
            ), 
          ), 
          Text( 
            "Rs. ${value.toStringAsFixed(2)}", 
            style: TextStyle( 
              fontSize: isHighlight ? 16 : 15, 
              fontWeight: FontWeight.bold, 
              color: valueColor ?? (isHighlight ? accentGreen : neutral900), 
            ), 
          ), 
        ], 
      ), 
    ); 
  } 
 
  List<String> _getQuarterMonths(int quarter) { 
    switch (quarter) { 
      case 1: 
        return ['April', 'May', 'June']; 
      case 2: 
        return ['July', 'August', 'September']; 
      case 3: 
        return ['October', 'November', 'December']; 
      case 4: 
        return ['January', 'February', 'March']; 
      default: 
        return []; 
    } 
  } 
 
  double _calculateQuarterlyIncome(String category, int quarter) { 
    final service = taxService.service; 
    double annualIncome = 0.0; 
 
    if (category == 'employment' && service.selectedTaxYear == "2025/2026") { 
      if (quarter == 1) { 
        return service.monthlyEmploymentTotals[0] + 
            service.monthlyEmploymentTotals[1] + 
            service.monthlyEmploymentTotals[2]; 
      } 
      if (quarter == 2) { 
        return service.monthlyEmploymentTotals[3] + 
            service.monthlyEmploymentTotals[4] + 
            service.monthlyEmploymentTotals[5]; 
      } 
      if (quarter == 3) { 
        return service.monthlyEmploymentTotals[6] + 
            service.monthlyEmploymentTotals[7] + 
            service.monthlyEmploymentTotals[8]; 
      } 
      if (quarter == 4) { 
        return service.monthlyEmploymentTotals[9] + 
            service.monthlyEmploymentTotals[10] + 
            service.monthlyEmploymentTotals[11]; 
      } 
    } 
    if (category == 'business' && service.selectedTaxYear == "2025/2026") { 
      if (quarter == 1) { 
        return service.monthlyBusinessTotals[0] + 
            service.monthlyBusinessTotals[1] + 
            service.monthlyBusinessTotals[2]; 
      } 
      if (quarter == 2) { 
        return service.monthlyBusinessTotals[3] + 
            service.monthlyBusinessTotals[4] + 
            service.monthlyBusinessTotals[5]; 
      } 
      if (quarter == 3) { 
        return service.monthlyBusinessTotals[6] + 
            service.monthlyBusinessTotals[7] + 
            service.monthlyBusinessTotals[8]; 
      } 
      if (quarter == 4) { 
        return service.monthlyBusinessTotals[9] + 
            service.monthlyBusinessTotals[10] + 
            service.monthlyBusinessTotals[11]; 
      } 
    } 
    if (category == 'investment' && service.selectedTaxYear == "2025/2026") { 
      if (quarter == 1) { 
        return service.monthlyInvestmentTotals[0] + 
            service.monthlyInvestmentTotals[1] + 
            service.monthlyInvestmentTotals[2]; 
      } 
      if (quarter == 2) { 
        return service.monthlyInvestmentTotals[3] + 
            service.monthlyInvestmentTotals[4] + 
            service.monthlyInvestmentTotals[5]; 
      } 
      if (quarter == 3) { 
        return service.monthlyInvestmentTotals[6] + 
            service.monthlyInvestmentTotals[7] + 
            service.monthlyInvestmentTotals[8]; 
      } 
      if (quarter == 4) { 
        return service.monthlyInvestmentTotals[9] + 
            service.monthlyInvestmentTotals[10] + 
            service.monthlyInvestmentTotals[11]; 
      } 
    } 
    if (category == 'foreign' && service.selectedTaxYear == "2025/2026") { 
      if (quarter == 1) { 
        return service.monthlyForeignTotals[0] + 
            service.monthlyForeignTotals[1] + 
            service.monthlyForeignTotals[2]; 
      } 
      if (quarter == 2) { 
        return service.monthlyForeignTotals[3] + 
            service.monthlyForeignTotals[4] + 
            service.monthlyForeignTotals[5]; 
      } 
      if (quarter == 3) { 
        return service.monthlyForeignTotals[6] + 
            service.monthlyForeignTotals[7] + 
            service.monthlyForeignTotals[8]; 
      } 
      if (quarter == 4) { 
        return service.monthlyForeignTotals[9] + 
            service.monthlyForeignTotals[10] + 
            service.monthlyForeignTotals[11]; 
      } 
    } 
    if (category == 'other' && service.selectedTaxYear == "2025/2026") { 
      if (quarter == 1) { 
        return service.monthlyOtherTotals[0] + 
            service.monthlyOtherTotals[1] + 
            service.monthlyOtherTotals[2]; 
      } 
      if (quarter == 2) { 
        return service.monthlyOtherTotals[3] + 
            service.monthlyOtherTotals[4] + 
            service.monthlyOtherTotals[5]; 
      } 
      if (quarter == 3) { 
        return service.monthlyOtherTotals[6] + 
            service.monthlyOtherTotals[7] + 
            service.monthlyOtherTotals[8]; 
      } 
      if (quarter == 4) { 
        return service.monthlyOtherTotals[9] + 
            service.monthlyOtherTotals[10] + 
            service.monthlyOtherTotals[11]; 
      } 
    } 
 
    if (category == 'employment') { 
      annualIncome = service.totalEmploymentIncome; 
    } else if (category == 'business') { 
      annualIncome = service.totalBusinessIncome; 
    } else if (category == 'investment') { 
      annualIncome = service.calculateTotalInvestmentIncome(); 
    } else if (category == 'other') { 
      annualIncome = service.totalOtherIncome; 
    } else if (category == 'foreign') { 
      annualIncome = service.calculateTotalForeignIncome(); 
    } 
 
    return annualIncome / 4; 
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
                              "Quarterly Installments", 
                              style: TextStyle( 
                                fontSize: 20, 
                                fontWeight: FontWeight.bold, 
                                color: neutral900, 
                                letterSpacing: -0.5, 
                              ), 
                            ), 
                            Text( 
                              "Breakdown of quarterly income", 
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
 
                Expanded( 
                  child: SlideTransition( 
                    position: _slideAnimation, 
                    child: ListView( 
                      padding: EdgeInsets.symmetric(horizontal: 16), 
                      children: [ 
                        _buildSectionCard( 
                          title: "1st Quarterly Installment (April - June)", 
                          icon: Icons.calendar_today, 
                          color: primaryColor, 
                          animationIndex: 0, 
                          children: [ 
                            summaryRow( 
                              "Total 1st Installment Employment Income", 
                              _calculateQuarterlyIncome('employment', 1), 
                            ), 
                            summaryRow( 
                              "Total 1st Installment Business Income", 
                              _calculateQuarterlyIncome('business', 1), 
                            ), 
                            summaryRow( 
                              "Total 1st Installment Investment Income", 
                              _calculateQuarterlyIncome('investment', 1), 
                              isHighlight: true, 
                            ), 
                            summaryRow( 
                              "Total 1st Installment Other Income", 
                              _calculateQuarterlyIncome('other', 1), 
                            ), 
                            summaryRow( 
                              "Total 1st Installment Foreign Income", 
                              _calculateQuarterlyIncome('foreign', 1), 
                            ), 
                          ], 
                        ), 
                        _buildSectionCard( title: "2nd Quarterly Installment (July - September)", 
                          icon: Icons.calendar_today, 
                          color: primaryColor, 
                          animationIndex: 1, 
                          children: [ 
                            summaryRow( 
                              "Total 2nd Installment Employment Income", 
                              _calculateQuarterlyIncome('employment', 2), 
                            ), 
                            summaryRow( 
                              "Total 2nd Installment Business Income", 
                              _calculateQuarterlyIncome('business', 2), 
                            ), 
                            summaryRow( 
                              "Total 2nd Installment Investment Income", 
                              _calculateQuarterlyIncome('investment', 2), 
                            ), 
                            summaryRow( 
                              "Total 2nd Installment Other Income", 
                              _calculateQuarterlyIncome('other', 2), 
                            ), 
                            summaryRow( 
                              "Total 2nd Installment Foreign Income", 
                              _calculateQuarterlyIncome('foreign', 2), 
                            ), 
                          ], 
                        ), 
                        _buildSectionCard( title: "3rd Quarterly Installment (October - December)", 
                          icon: Icons.calendar_today, 
                          color: primaryColor, 
                          animationIndex: 2, 
                          children: [ 
                            summaryRow( 
                              "Total 3rd Installment Employment Income", 
                              _calculateQuarterlyIncome('employment', 3), 
                            ), 
                            summaryRow( 
                              "Total 3rd Installment Business Income", 
                              _calculateQuarterlyIncome('business', 3), 
                            ), 
                            summaryRow( 
                              "Total 3rd Installment Investment Income", 
                              _calculateQuarterlyIncome('investment', 3), 
                            ), 
                            summaryRow( 
                              "Total 3rd Installment Other Income", 
                              _calculateQuarterlyIncome('other', 3), 
                            ), 
                            summaryRow( 
                              "Total 3rd Installment Foreign Income", 
                              _calculateQuarterlyIncome('foreign', 3), 
                            ), 
                          ], 
                        ), 
                        _buildSectionCard( 
                          title: "4th Quarterly Installment (January - March)", 
                          icon: Icons.calendar_today, 
                          color: primaryColor, 
                          animationIndex: 3, 
                          children: [ 
                            summaryRow( 
                              "Total 4th Installment Employment Income", 
                              _calculateQuarterlyIncome('employment', 4), 
                            ), 
                            summaryRow( 
                              "Total 4th Installment Business Income", 
                              _calculateQuarterlyIncome('business', 4), 
                            ), 
                            summaryRow( 
                              "Total 4th Installment Investment Income", 
                              _calculateQuarterlyIncome('investment', 4), 
                            ), 
                            summaryRow( 
                              "Total 4th Installment Other Income", 
                              _calculateQuarterlyIncome('other', 4), 
                            ), 
                            summaryRow( 
                              "Total 4th Installment Foreign Income", 
                              _calculateQuarterlyIncome('foreign', 4), 
                            ), 
                          ], 
                        ), 
                      ], 
                    ), 
                  ), 
                ), 
              ], 
            ), 
          ), 
        ), 
      ), 
    ); 
  } 
}