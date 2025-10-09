//pages/solar_income_page.dart 
import 'package:flutter/material.dart'; 
import '../services/tax_data_service.dart'; 
import '../widgets/income_field.dart'; 
import '../services/firestore_service.dart'; 
 
class SolarIncomePage extends StatefulWidget { 
  const SolarIncomePage({super.key}); 
 
  @override 
  State<SolarIncomePage> createState() => SolarIncomePageState(); 
} 
 
class SolarIncomePageState extends State<SolarIncomePage> 
    with TickerProviderStateMixin { 
  final TaxDataService service = TaxDataService(); 
 
  final TextEditingController installCostCtrl = TextEditingController(); 
  final TextEditingController reliefCountCtrl = TextEditingController(); 
  final TextEditingController solarIncomeCtrl = TextEditingController(); 
 
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
          CurvedAnimation(parent: _slideController, curve: 
Curves.easeOutCubic), 
        ); 
 
    _fadeController.forward(); 
    _slideController.forward(); 
 
    installCostCtrl.text = service.solarInstallCost.toString(); 
    reliefCountCtrl.text = service.solarReliefCount.toString(); 
    solarIncomeCtrl.text = service.totalSolarIncome.toString(); 
  } 
 
  @override 
  void dispose() { 
    _fadeController.dispose(); 
    _slideController.dispose(); 
    installCostCtrl.dispose(); 
    reliefCountCtrl.dispose(); 
    solarIncomeCtrl.dispose(); 
    super.dispose(); 
  } 
 
  void saveSolarDetails() async { 
    service.solarInstallCost = double.tryParse(installCostCtrl.text) ?? 0.0; 
    service.solarReliefCount = int.tryParse(reliefCountCtrl.text) ?? 0; 
    service.totalSolarIncome = double.tryParse(solarIncomeCtrl.text) ?? 0.0; 
 
    if (mounted) { 
      ScaffoldMessenger.of(context).showSnackBar( 
        SnackBar( 
          content: Row( 
            children: [ 
              Icon(Icons.check_circle, color: Colors.white), 
              SizedBox(width: 8), 
              Text("Solar income details saved"), 
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
      await FirestoreService.saveTaxYearData(service.selectedTaxYear, service.getAllDataAsMap()); 
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
 
  Widget _buildInfoCard() { 
    const primaryColor = Color(0xFF38E07B); 
    const accentGreen = Color(0xFF10B981); 
    const neutral900 = Color(0xFF111714); 
 
    return Container( 
      margin: EdgeInsets.only(bottom: 24), 
      padding: EdgeInsets.all(20), 
      decoration: BoxDecoration( 
        gradient: LinearGradient( 
          colors: [ 
            Color(0xFFFFF3CD).withOpacity(0.8), 
            Color(0xFFFFE69C).withOpacity(0.6), 
          ], 
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight, 
        ), 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Color(0xFFFFC107).withOpacity(0.3)), 
        boxShadow: [ 
          BoxShadow( 
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: Offset(0, 3), 
          ), 
        ], 
      ), 
      child: Row( 
        children: [ 
          Container( 
            padding: EdgeInsets.all(12), 
            decoration: BoxDecoration( 
              color: Color(0xFFFFC107), 
              borderRadius: BorderRadius.circular(12), 
              boxShadow: [ 
                BoxShadow( 
                  color: Color(0xFFFFC107).withOpacity(0.3), 
                  blurRadius: 6, 
                  offset: Offset(0, 2), 
                ), 
              ], 
            ), 
            child: Icon(Icons.info_outline, color: Colors.white, size: 24), 
          ), 
          SizedBox(width: 16), 
          Expanded( 
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [ 
                Text( 
                  "Important Notice", 
                  style: TextStyle( 
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF856404), 
                  ), 
                ), 
                SizedBox(height: 4), 
                Text( 
                  "Solar system must be connected to the national grid", 
                  style: TextStyle( 
                    fontSize: 14, 
                    color: Color(0xFF856404), 
                    height: 1.3, 
                  ), 
                ), 
              ], 
            ), 
          ), 
        ], 
      ), 
    ); 
  } 
 
  Widget _buildSolarDetailsCard() { 
    const primaryColor = Color(0xFF38E07B); 
    const accentGreen = Color(0xFF10B981); 
    const neutral900 = Color(0xFF111714); 
 
    return Container( 
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
                child: Icon( 
                  Icons.wb_sunny_outlined, 
                  color: Colors.white, 
                  size: 24, 
                ), 
              ), 
              SizedBox(width: 16), 
              Expanded( 
                child: Text( 
                  "Solar Income Details", 
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
          SizedBox(height: 24), 
 
          IncomeField( 
            controller: installCostCtrl, 
            label: "Total Solar Installation Cost", 
          ), 
          SizedBox(height: 16), 
 
          IncomeField( 
            controller: reliefCountCtrl, 
            label: "No. of Times Relief Availed", 
          ), 
          SizedBox(height: 16), 
 
          IncomeField( 
            controller: solarIncomeCtrl, 
            label: "Annual Solar Income", 
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
                              "Solar Income", 
                              style: TextStyle( 
                                fontSize: 20, 
                                fontWeight: FontWeight.bold, 
                                color: neutral900, 
                                letterSpacing: -0.5, 
                              ), 
                            ), 
                            Text( 
                              "Enter your solar panel income", 
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
                              Icons.wb_sunny_rounded, 
                              color: Colors.white, 
                              size: 24, 
                            ), 
                          ), 
                          SizedBox(width: 12), 
                          Text( 
                            "Solar Energy Income", 
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
                        "Track your renewable energy earnings and tax benefits", 
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
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [ 
                          _buildInfoCard(), 
                          _buildSolarDetailsCard(), 
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
        onPressed: saveSolarDetails, 
        backgroundColor: primaryColor, 
        foregroundColor: Colors.white, 
        elevation: 8, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
        label: Text( 
          "Save Solar Income", 
          style: TextStyle(fontWeight: FontWeight.bold), 
        ), 
        icon: Icon(Icons.save_rounded), 
      ), 
    ); 
  } 
} 
