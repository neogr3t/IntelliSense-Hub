class AudioHistory {
  final String id;
  final String sourcePath;
  final String transcript;
  final DateTime timestamp;
  final bool isUrl;

  AudioHistory({
    required this.id,
    required this.sourcePath,
    required this.transcript,
    required this.timestamp,
    required this.isUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourcePath': sourcePath,
      'transcript': transcript,
      'timestamp': timestamp.toIso8601String(),
      'isUrl': isUrl,
    };
  }

  factory AudioHistory.fromJson(Map<String, dynamic> json) {
    return AudioHistory(
      id: json['id'],
      sourcePath: json['sourcePath'],
      transcript: json['transcript'],
      timestamp: DateTime.parse(json['timestamp']),
      isUrl: json['isUrl'],
    );
  }
}
