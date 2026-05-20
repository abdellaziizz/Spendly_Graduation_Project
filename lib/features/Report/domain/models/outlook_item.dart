class OutlookItem {
  const OutlookItem({
    required this.name,
    required this.description,
    required this.now,
    required this.nextMonth,
    required this.change,
  });

  final String name;
  final String description;
  final double now;
  final double nextMonth;
  final double change;
}
