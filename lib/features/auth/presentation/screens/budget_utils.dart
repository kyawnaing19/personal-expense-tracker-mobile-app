import 'package:intl/intl.dart';

const List<String> kMonthNamesShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const List<String> kMonthNamesFull = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String formatAmount(num value) {
  final formatter = NumberFormat('#,##0');
  return formatter.format(value);
}


List<int> selectableYears(int currentYear, {int spanForward = 4}) {
  return List.generate(spanForward + 1, (i) => currentYear + i);
}

List<int> filterableYears(int currentYear, {int spanBack = 3, int spanForward = 4}) {
  return List.generate(spanBack + spanForward + 1, (i) => currentYear - spanBack + i);
}

List<int> selectableMonths({
  required int selectedYear,
  required int currentMonth,
  required int currentYear,
}) {
  if (selectedYear == currentYear) {
    return List.generate(12 - currentMonth + 1, (i) => currentMonth + i);
  } else if (selectedYear > currentYear) {
    return List.generate(12, (i) => i + 1);
  }
  return [currentMonth];
}