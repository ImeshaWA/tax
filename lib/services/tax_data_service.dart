//services/tax_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';


class TaxDataService {
  static final TaxDataService _instance = TaxDataService._internal();
  factory TaxDataService() => _instance;
  TaxDataService._internal();

  String selectedTaxYear = "2024/2025"; // Default value

  // Qualifying Payments
  double charity = 0.0;
  double govDonations = 0.0;
  double presidentsFund = 0.0;
  double femaleShop = 0.0;
  double filmExpenditure = 0.0;
  double cinemaNew = 0.0;
  double cinemaUpgrade = 0.0;
  double exemptIncome = 0.0;
  double foreignTaxCredits = 0.0;

  // Incomes
  double totalDomesticIncome = 0.0;
  double totalForeignIncome = 0.0;
  double totalEmploymentIncome = 0.0;
  double totalBusinessIncome = 0.0;
  double totalInvestmentIncome = 0.0;
  double totalRentIncome = 0.0;
  double rentBusinessIncome = 0.0;
  double rentBusinessWht = 0.0;
  double totalSolarIncome = 0.0;
  double totalOtherIncome = 0.0;

  // Employment Categories
  Map<String, double> employmentCategories = {
    "Salary / Wages": 0.0,
    "Allowances": 0.0,
    "Expense Reimbursements": 0.0,
    "Agreement Payments": 0.0,
    "Termination Payments": 0.0,
    "Retirement Contributions & Payments": 0.0,
    "Payments on Your Behalf": 0.0,
    "Benefits in Kind": 0.0,
    "Employee Share Schemes": 0.0,
  };

  // Business Categories
  Map<String, double> businessCategories = {
    "Service Fees": 0.0,
    "Sales of Trading Stock": 0.0,
    "Capital Gains from Assets/Liabilities": 0.0,
    "Realisation of Depreciable Assets": 0.0,
    "Payments for Restrictions": 0.0,
    "Other Business Income": 0.0,
    "Rent for Business Purpose": 0.0,
  };

  // Investment Categories
  Map<String, double> investmentCategories = {
    "Dividends": 0.0,
    "Rebates, Fees, Premiums": 0.0,
    "Natural Resource Payments": 0.0,
    "Residential Rental Income": 0.0,
    "Premiums": 0.0,
    "Royalties": 0.0,
    "Gains from Sale of Investment Assets": 0.0,
    "Payments for Restricting Investment Activities": 0.0,
    "Lottery, Betting, Gambling Winnings": 0.0,
    "Solar Income": 0.0,
    "Interest Income": 0.0,
    "Other Investments": 0.0,
  };

  // Foreign Income Categories
  Map<String, double> foreignIncomeCategories = {
    "Foreign Employment": 0.0,
    "Foreign Business": 0.0,
    "Foreign Investment": 0.0,
    "Foreign Other": 0.0,
  };

  double apitAmount = 0.0;
  bool rentMaintainedByUser = false;

  // Solar Specific
  double solarInstallCost = 0.0;
  int solarReliefCount = 0;

  // Tax Reliefs
  double rentRelief = 0.0;
  double solarPanel = 0.0;

  // Rent Specific
  bool? isMaintainedByUser;

  double totalQualifyingPayments() {
    return [
      charity,
      govDonations,
      presidentsFund,
      femaleShop,
      filmExpenditure,
      cinemaNew,
      cinemaUpgrade,
    ].reduce((a, b) => a + b);
  }

  double totalReliefs() {
    return rentRelief + solarPanel;
  }

  // Calculate total investment income
  double calculateTotalInvestmentIncome() {
    double total = totalRentIncome + totalSolarIncome;
    total += investmentCategories.values.reduce((a, b) => a + b);
    totalInvestmentIncome = total;
    return total;
  }

  // Calculate total foreign income
  double calculateTotalForeignIncome() {
    double total = foreignIncomeCategories.values.reduce((a, b) => a + b);
    totalForeignIncome = total;
    return total;
  }

  Map<String, dynamic> getAllDataAsMap() {
  return {
    'selectedTaxYear': selectedTaxYear,
    'charity': charity,
    'govDonations': govDonations,
    'presidentsFund': presidentsFund,
    'femaleShop': femaleShop,
    'filmExpenditure': filmExpenditure,
    'cinemaNew': cinemaNew,
    'cinemaUpgrade': cinemaUpgrade,
    'exemptIncome': exemptIncome,
    'foreignTaxCredits': foreignTaxCredits,
    'totalDomesticIncome': totalDomesticIncome,
    'totalForeignIncome': totalForeignIncome,
    'totalEmploymentIncome': totalEmploymentIncome,
    'totalBusinessIncome': totalBusinessIncome,
    'totalInvestmentIncome': totalInvestmentIncome,
    'totalRentIncome': totalRentIncome,
    'rentBusinessIncome': rentBusinessIncome,
    'rentBusinessWht': rentBusinessWht,
    'totalSolarIncome': totalSolarIncome,
    'totalOtherIncome': totalOtherIncome,
    'employmentCategories': employmentCategories,
    'businessCategories': businessCategories,
    'investmentCategories': investmentCategories,
    'foreignIncomeCategories': foreignIncomeCategories,
    'apitAmount': apitAmount,
    'rentMaintainedByUser': rentMaintainedByUser,
    'solarInstallCost': solarInstallCost,
    'solarReliefCount': solarReliefCount,
    'rentRelief': rentRelief,
    'solarPanel': solarPanel,
    'isMaintainedByUser': isMaintainedByUser,
    'updatedAt': FieldValue.serverTimestamp(),  // Auto-add timestamp
  };
}

}