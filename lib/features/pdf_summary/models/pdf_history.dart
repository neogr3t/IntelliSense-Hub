class PDFHistory {
  final String id;
  final String filePath;
  final String summary;
  final DateTime timestamp;

  PDFHistory({
    required this.id,
    required this.filePath,
    required this.summary,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'summary': summary,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PDFHistory.fromJson(Map<String, dynamic> json) {
    return PDFHistory(
      id: json['id'],
      filePath: json['filePath'],
      summary: json['summary'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
