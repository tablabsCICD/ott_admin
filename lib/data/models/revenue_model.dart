import 'package:fl_chart/fl_chart.dart';

class RevenueData {
  static List<FlSpot> getWeekData() {
    return [
      FlSpot(0, 3937), // Sat
      FlSpot(1, 3826), // Sun
      FlSpot(2, 2539), // Mon
      FlSpot(3, 2453), // Tue
      FlSpot(4, 1356), // Wed
      FlSpot(5, 2451), // Thu
      FlSpot(6, 3623), // Fri
    ];
  }

  static List<FlSpot> getMonthData() {
    return [
      FlSpot(0, 74639), // Jan
      FlSpot(1, 64736), // Feb
      FlSpot(2, 73626), // Mar
      FlSpot(3, 77523), // Apr
      FlSpot(4, 95263), // May
      FlSpot(5, 79367), // Jun
      FlSpot(6, 81900), // Jul
      FlSpot(7, 84765), // Aug
      FlSpot(8, 82734), // Sep
      FlSpot(9, 74582), // Oct
      FlSpot(10, 88735), // Nov
      FlSpot(11, 97253), // Dec
    ];
  }

  static List<FlSpot> getYearData() {
    return [
      FlSpot(0, 650837), // 2019
      FlSpot(1, 680205), // 2020
      FlSpot(2, 663735), // 2021
      FlSpot(3, 523744), // 2022
      FlSpot(4, 554673), // 2023
      FlSpot(5, 619203), // 2024
      FlSpot(6, 856483), // 2025
      FlSpot(7, 872563), // 2026
    ];
  }
}
