import 'dart:convert';

class GeneratedReport {
  GeneratedReport({
    required this.id,
    required this.filename,
    required this.path,
    required this.frequency,
    required this.createdAt,
  });

  final String id;
  final String filename;
  final String path;
  final String frequency;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'path': path,
        'frequency': frequency,
        'createdAt': createdAt.toIso8601String(),
      };

  static GeneratedReport fromJson(Map<String, dynamic> json) {
    return GeneratedReport(
      id: json['id'] as String,
      filename: json['filename'] as String,
      path: json['path'] as String,
      frequency: json['frequency'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static List<GeneratedReport> listFromJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final list = json.decode(jsonStr) as List<dynamic>;
    return list.map((e) => GeneratedReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<GeneratedReport> items) => json.encode(items.map((e) => e.toJson()).toList());
}
