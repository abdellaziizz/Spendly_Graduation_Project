class TimeBucket {
  const TimeBucket({
    required this.label,
    required this.total,
    required this.count,
    required this.categories,
  });

  final String label;
  final double total;
  final int count;
  final Map<String, double> categories;
}
