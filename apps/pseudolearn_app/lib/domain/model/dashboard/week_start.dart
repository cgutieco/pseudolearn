DateTime weekStartOf(DateTime moment) {
  final day = DateTime(moment.year, moment.month, moment.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}
