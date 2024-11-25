class RecognitionHistory {
  final String imagePath;
  final String extractedText;
  final DateTime timestamp;

  RecognitionHistory({
    required this.imagePath,
    required this.extractedText,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'extractedText': extractedText,
        'timestamp': timestamp.toIso8601String(),
      };

  factory RecognitionHistory.fromJson(Map<String, dynamic> json) {
    return RecognitionHistory(
      imagePath: json['imagePath'],
      extractedText: json['extractedText'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
