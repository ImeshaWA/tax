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
 
class _ModeSelectionPageState extends State<ModeSelectionPage> 
    with TickerProviderStateMixin { 
  String? selectedType; 
  final TaxDataService service = TaxDataService(); 
 
  final List<String> incomeTypes = [ 
    "Employment", 
    "Business", 
    "Investment", 
    "Other", 
    "Foreign", 
  ]; 
 
  late AnimationController _fadeController; 
  late AnimationController _slideController; 
  late Animation<double> _fadeAnimation; 
  late Animation<Offset> _slideAnimation; 
  late List<AnimationController> _itemControllers; 
  late List<Animation<double>> _itemAnimations; 
 
  // Income type icons mapping 
  final Map<String, IconData> incomeIcons = { 
    "Employment": Icons.work_rounded, 
    "Business": Icons.business_rounded, 
    "Investment": Icons.trending_up_rounded, 
    "Other": Icons.more_horiz_rounded, 
    "Foreign": Icons.public_rounded, 
  }; 
 
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
          CurvedAnimation(parent: _slideController, curve: 
Curves.easeOutCubic), 
        ); 
 
    // Staggered animations for income type cards 
    _itemControllers = List.generate( 
      incomeTypes.length, 
      (index) => AnimationController( 
        duration: Duration(milliseconds: 600), 
        vsync: this, 
      ), 
    ); 
    _itemAnimations = _itemControllers 
        .map( 
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate( 
            CurvedAnimation(parent: controller, curve: Curves.easeOutBack), 
          ), 
        ) 
        .toList(); 
 
    _fadeController.forward(); 
    _slideController.forward(); 
 
    // Staggered animation for cards 
    for (int i = 0; i < _itemControllers.length; i++) { 
      Future.delayed(Duration(milliseconds: 100 * i), () { 
        if (mounted) _itemControllers[i].forward(); 
      }); 
    } 
  } 
 
  @override 
  void dispose() { 
    _fadeController.dispose(); 
    _slideController.dispose(); 
    for (var controller in _itemControllers) { 
      controller.dispose(); 
    } 
    super.dispose(); 
  } 
 
  void goToNextPage() { 
    const primaryColor = Color(0xFF38E07B); 
 
    if (selectedType == null) { 
      ScaffoldMessenger.of(context).showSnackBar( 
        SnackBar( 
          content: Row( 
            children: [ 
              Icon(Icons.warning_rounded, color: Colors.white), 
              SizedBox(width: 8), 
              Text("Please choose an income type"), 
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
 
  Widget _buildIncomeTypeCard(String type, int index) { 
    const primaryColor = Color(0xFF38E07B); 
    const primaryLight = Color(0xFF5FE896); 
    const accentGreen = Color(0xFF10B981); 
    const neutral900 = Color(0xFF111714); 
    const neutral50 = Color(0xFFf8faf9); 
 
    final selected = selectedType == type; 
 
    return FadeTransition( 
      opacity: _itemAnimations[index], 
      child: SlideTransition( 
        position: Tween<Offset>( 
          begin: Offset(0, 0.5), 
          end: Offset.zero, 
        ).animate(_itemControllers[index]), 
        child: GestureDetector( 
          onTap: () { 
            setState(() => selectedType = type); 
          }, 
          child: AnimatedContainer( 
            duration: Duration(milliseconds: 300), 
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4), 
            padding: EdgeInsets.all(20), 
            decoration: BoxDecoration( 
              gradient: selected 
                  ? LinearGradient( 
                      colors: [primaryColor, accentGreen], 
                      begin: Alignment.topLeft, 
                      end: Alignment.bottomRight, 
                    ) 
                  : null, 
              color: selected ? null : Colors.white.withOpacity(0.9), 
              borderRadius: BorderRadius.circular(16), 
              border: Border.all( 
                color: selected ? primaryColor : 
primaryColor.withOpacity(0.2), 
                width: selected ? 2 : 1, 
              ), 
              boxShadow: [ 
                BoxShadow( 
                  color: selected 
                      ? primaryColor.withOpacity(0.3) 
                      : Colors.black.withOpacity(0.05), 
                  blurRadius: selected ? 15 : 8, 
                  offset: Offset(0, selected ? 6 : 2), 
                ), 
              ], 
            ), 
            child: Row( 
              children: [ 
                Container( 
                  padding: EdgeInsets.all(12), 
                  decoration: BoxDecoration( 
                    color: selected 
                        ? Colors.white.withOpacity(0.2) 
                        : primaryColor.withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(12), 
                    boxShadow: selected 
                        ? [ 
                            BoxShadow( 
                              color: Colors.white.withOpacity(0.1), 
                              blurRadius: 4, 
                              offset: Offset(0, 2), 
                            ), 
                          ] 
                        : null, 
                  ), 
                  child: Icon( 
                    incomeIcons[type] ?? Icons.account_balance_wallet, 
                    color: selected ? Colors.white : primaryColor, 
                    size: 24, 
                  ), 
                ), 
                SizedBox(width: 16), 
                Expanded( 
                  child: Text( 
                    type, 
                    style: TextStyle( 
                      fontSize: 18, 
                      fontWeight: selected ? FontWeight.bold : 
FontWeight.w600, 
                      color: selected ? Colors.white : neutral900, 
                      letterSpacing: 0.3, 
                    ), 
                  ), 
                ), 
                AnimatedContainer( 
                  duration: Duration(milliseconds: 200), 
                  height: 28, 
                  width: 28, 
                  decoration: BoxDecoration( 
                    shape: BoxShape.circle, 
                    border: Border.all( 
                      color: selected 
                          ? Colors.white 
                          : primaryColor.withOpacity(0.5), 
                      width: 2, 
                    ), 
                    color: selected ? Colors.white : Colors.transparent, 
                  ), 
                  child: selected 
                      ? Icon(Icons.check_rounded, size: 18, color: 
primaryColor) 
                      : null, 
                ), 
              ], 
            ), 
          ), 
        ), 
      ), 
    ); 
  } 
 
  Widget _buildActionButton({ 
    required String title, 
    required VoidCallback onPressed, 
    required Color backgroundColor, 
    required IconData icon, 
    Color? foregroundColor, 
  }) { 
    return Container( 
      margin: EdgeInsets.symmetric(vertical: 6), 
      child: ElevatedButton( 
        onPressed: onPressed, 
        style: 
            ElevatedButton.styleFrom( 
              backgroundColor: backgroundColor, 
              foregroundColor: foregroundColor ?? Colors.white, 
              padding: EdgeInsets.symmetric(vertical: 18), 
              elevation: 4, 
              shadowColor: backgroundColor.withOpacity(0.3), 
              shape: RoundedRectangleBorder( 
                borderRadius: BorderRadius.circular(16), 
              ), 
            ).copyWith( 
              elevation: WidgetStateProperty.resolveWith<double>(( 
                Set<WidgetState> states, 
              ) { 
                if (states.contains(WidgetState.pressed)) return 2; 
                if (states.contains(WidgetState.hovered)) return 8; 
                return 4; 
              }), 
            ), 
        child: Row( 
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [ 
            Icon(icon, size: 20), 
            SizedBox(width: 8), 
            Text( 
              title, 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    const primaryColor = Color(0xFF38E07B); 
    const primaryLight = Color(0xFF5FE896); 
    const neutral900 = Color(0xFF111714); 
    const neutral50 = Color(0xFFf8faf9); 
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
            child: SlideTransition( 
              position: _slideAnimation, 
              child: Column( 
                children: [ 
                  // Custom App Bar 
                  Container( 
                    padding: EdgeInsets.all(20), 
                    child: Row( 
                      children: [ 
                        GestureDetector( 
                          onTap: () => Navigator.pushReplacement( 
                            context, 
                            MaterialPageRoute( 
                              builder: (_) => const YearSelectionPage(), 
                            ), 
                          ), 
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
                          child: Text( 
                            "Income Tax Calculator", 
                            style: TextStyle( 
                              fontSize: 20, 
                              fontWeight: FontWeight.bold, 
                              color: neutral900, 
                              letterSpacing: -0.5, 
                            ), 
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
                                Icons.account_balance_wallet, 
                                color: Colors.white, 
                                size: 24, 
                              ), 
                            ), 
                            SizedBox(width: 12), 
                            Text( 
                              "Select Income Type", 
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
                          "Choose your primary income source to get started", 
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
 
                  // Income Types List 
                  Expanded( 
                    child: ListView( 
                      padding: EdgeInsets.symmetric(horizontal: 16), 
                      children: [ 
                        ...incomeTypes.asMap().entries.map( 
                          (entry) => 
                              _buildIncomeTypeCard(entry.value, entry.key), 
                        ), 
 
                        SizedBox(height: 24), 
 
                        // Action Buttons Section 
                        Container( 
                          padding: EdgeInsets.all(20), 
                          decoration: BoxDecoration( 
                            color: Colors.white.withOpacity(0.9), 
                            borderRadius: BorderRadius.circular(20), 
                            border: Border.all( 
                              color: primaryColor.withOpacity(0.2), 
                            ), 
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
                              Text( 
                                "Additional Options", 
                                style: TextStyle( 
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold, 
                                  color: neutral900, 
                                  letterSpacing: -0.3, 
                                ), 
                              ), 
                              SizedBox(height: 16), 
 
                              _buildActionButton( 
                                title: "Enter Qualifying Payments", 
                                onPressed: () => Navigator.push( 
                                  context, 
                                  MaterialPageRoute( 
                                    builder: (_) => 
                                        const QualifyingPaymentsPage(), 
                                  ), 
                                ), 
                                backgroundColor: Color(0xFFFF6B35), 
                                icon: Icons.payment_rounded, 
                              ), 
 
                              _buildActionButton( 
                                title: "View Tax Summary", 
                                onPressed: () => Navigator.push( 
                                  context, 
                                  MaterialPageRoute( 
                                    builder: (_) => const EstimatedTaxPage(), 
                                  ), 
                                ), 
                                backgroundColor: primaryColor, 
                                icon: Icons.assessment_rounded, 
                              ), 
                            ], 
                          ), 
                        ), 
 
                        SizedBox(height: 100), // Space for bottom button 
                      ], 
                    ), 
                  ), 
                ], 
              ), 
            ), 
          ), 
        ), 
      ), 
      bottomNavigationBar: Container( 
        padding: EdgeInsets.all(20), 
        decoration: BoxDecoration( 
          color: Colors.white.withOpacity(0.95), 
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)), 
          border: Border(top: BorderSide(color: 
primaryColor.withOpacity(0.2))), 
          boxShadow: [ 
            BoxShadow( 
              color: Colors.black.withOpacity(0.1), 
              blurRadius: 20, 
              offset: Offset(0, -5), 
            ), 
          ], 
        ), 
        child: SafeArea( 
          child: ElevatedButton( 
            onPressed: goToNextPage, 
            style: 
                ElevatedButton.styleFrom( 
                  backgroundColor: primaryColor, 
                  foregroundColor: Colors.white, 
                  padding: EdgeInsets.symmetric(vertical: 18), 
                  elevation: 6, 
                  shadowColor: primaryColor.withOpacity(0.4), 
                  shape: RoundedRectangleBorder( 
                    borderRadius: BorderRadius.circular(16), 
                  ), 
                ).copyWith( 
                  elevation: WidgetStateProperty.resolveWith<double>(( 
                    Set<WidgetState> states, 
                  ) { 
                    if (states.contains(WidgetState.pressed)) return 2; 
                    if (states.contains(WidgetState.hovered)) return 10; 
                    return 6; 
                  }), 
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(( 
                    Set<WidgetState> states, 
                  ) { 
                    if (states.contains(WidgetState.pressed)) 
                      return Color(0xFF2DD96A); 
                    return primaryColor; 
                  }), 
                ), 
            child: Row( 
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [ 
                Text( 
                  "Continue", 
                  style: TextStyle( 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 0.5, 
                  ), 
                ), 
                SizedBox(width: 8), 
                Icon(Icons.arrow_forward_rounded, size: 20), 
              ], 
            ), 
          ), 
        ), 
      ), 
    ); 
  } 
}