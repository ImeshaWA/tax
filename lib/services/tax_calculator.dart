//services/tax_calculator.dart
import 'tax_data_service.dart';
import 'income_calculator.dart';

class TaxCalculator {
  final TaxDataService _service = TaxDataService();

  // Calculate Total Annual Employment Income
  double calculateTotalEmploymentIncome() {
    return _service.employmentCategories.values.fold(0.0, (sum, val) => sum + val);
  }

  // Calculate Total Annual Business Income
  double calculateTotalBusinessIncome() {
    return _service.businessCategories.values.fold(0.0, (sum, val) => sum + val);
  }

  // Calculate Total Annual Investment Income
  double calculateTotalInvestmentIncome() {
    double total = _service.investmentCategories.values.fold(0.0, (sum, val) => sum + val);
    total += _service.totalRentIncome + _service.totalSolarIncome;
    return total;
  }

  // Calculate Total Annual Foreign Income
  double calculateTotalForeignIncome() {
    return _service.foreignIncomeCategories.values.fold(0.0, (sum, val) => sum + val);
  }

  // Calculate Total Annual Qualifying Payments
  double calculateTotalQualifyingPayments() {
    return _service.charity +
        _service.govDonations +
        _service.presidentsFund +
        _service.femaleShop +
        _service.filmExpenditure +
        _service.cinemaNew +
        _service.cinemaUpgrade;
  }

  // Calculate Total Assessable Income
  double calculateTotalAssessableIncome() {
    return calculateTotalEmploymentIncome() +
        calculateTotalBusinessIncome() +
        calculateTotalInvestmentIncome() +
        calculateTotalForeignIncome() +
        _service.totalOtherIncome;
  }

  // Calculate Rent Relief
  double calculateRentRelief() {
    if (_service.isMaintainedByUser == true || _service.rentMaintainedByUser == true) {
      return (_service.totalRentIncome * 0.25) + (_service.rentBusinessIncome * 0.25);
    }
    return 0.0;
  }

  // Calculate Solar Relief
  double calculateSolarRelief() {
    double solarBalance = _service.solarInstallCost - (600000 * _service.solarReliefCount);
    return solarBalance >= 600000 ? 600000 : solarBalance;
  }

  // Calculate Total Relief
  double calculateTotalRelief() {
    const double personalRelief = 1800000;
    return personalRelief + calculateRentRelief() + calculateSolarRelief();
  }

  // Calculate Taxable Income
  double calculateTaxableIncome() {
    double assessableIncome = calculateTotalAssessableIncome();
    if (assessableIncome <= 1800000) return 0.0;
    return assessableIncome - calculateTotalQualifyingPayments() - calculateTotalRelief();
  }

  // Calculate Taxable Income Without Foreign
  double calculateTaxableIncomeWithoutForeign() {
    double taxableIncome = calculateTaxableIncome();
    double foreignIncome = calculateTotalForeignIncome();
    return taxableIncome - foreignIncome < 0 ? 0 : taxableIncome - foreignIncome;
  }

  // Calculate Tax Liability Without Foreign
  double calculateTaxLiabilityWithoutForeign() {
    double taxableIncome = calculateTaxableIncomeWithoutForeign();
    double tax = 0.0;

    if (taxableIncome <= 0) return 0.0;

    // First 1,000,000 at 6%
    if (taxableIncome <= 1000000) {
      return taxableIncome * 0.06;
    }
    tax += 1000000 * 0.06;
    taxableIncome -= 1000000;

    // Next 500,000 at 18%
    if (taxableIncome <= 500000) {
      return tax + (taxableIncome * 0.18);
    }
    tax += 500000 * 0.18;
    taxableIncome -= 500000;

    // Next 500,000 at 24%
    if (taxableIncome <= 500000) {
      return tax + (taxableIncome * 0.24);
    }
    tax += 500000 * 0.24;
    taxableIncome -= 500000;

    // Next 500,000 at 30%
    if (taxableIncome <= 500000) {
      return tax + (taxableIncome * 0.30);
    }
    tax += 500000 * 0.30;
    taxableIncome -= 500000;

    // Balance at 36%
    return tax + (taxableIncome * 0.36);
  }

  // Calculate Tax Liability Foreign
  double calculateTaxLiabilityForeign() {
    return calculateTotalForeignIncome() * 0.15;
  }

  // Calculate Final Tax Liability
  double calculateFinalTaxLiability() {
    return calculateTaxLiabilityWithoutForeign() + calculateTaxLiabilityForeign();
  }

  // Calculate Annual APIT
  double calculateAnnualAPIT() {
    return _service.apitAmount;
  }

  // Calculate Tax Payable
  double calculateTaxPayable() {
    double payable = calculateFinalTaxLiability() - calculateAnnualAPIT() - _service.foreignTaxCredits;
    return payable < 0 ? 0 : payable;
  }

  // Get All Calculations
  Map<String, double> getAllCalculations() {
    return {
      'employmentIncome': calculateTotalEmploymentIncome(),
      'businessIncome': calculateTotalBusinessIncome(),
      'investmentIncome': calculateTotalInvestmentIncome(),
      'foreignIncome': calculateTotalForeignIncome(),
      'qualifyingPayments': calculateTotalQualifyingPayments(),
      'assessableIncome': calculateTotalAssessableIncome(),
      'personalRelief': 1800000,
      'rentRelief': calculateRentRelief(),
      'solarRelief': calculateSolarRelief(),
      'totalRelief': calculateTotalRelief(),
      'taxableIncome': calculateTaxableIncome(),
      'taxableIncomeWithoutForeign': calculateTaxableIncomeWithoutForeign(),
      'taxLiabilityWithoutForeign': calculateTaxLiabilityWithoutForeign(),
      'taxLiabilityForeign': calculateTaxLiabilityForeign(),
      'finalTaxLiability': calculateFinalTaxLiability(),
      'taxPayable': calculateTaxPayable(),
    };
  }
}