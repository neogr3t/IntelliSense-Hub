import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recognition_history.dart';

class TextRecognitionHistoryService {
  static const String _historyKey = 'text_recognition_history';
  static const String _lastScanKey = 'text_recognition_last_scan';
  static const int _maxHistoryItems = 3;

  Future<void> saveToHistory(RecognitionHistory item) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing history
    List<RecognitionHistory> history = await getHistory();

    // Add new item at the beginning
    history.insert(0, item);

    // Keep only last 3 items
    if (history.length > _maxHistoryItems) {
      history = history.take(_maxHistoryItems).toList();
    }

    // Save to SharedPreferences
    final historyJson =
        history.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_historyKey, historyJson);

    // Save as last scan
    await saveLastScan(item);
  }

  Future<void> saveLastScan(RecognitionHistory item) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastScanKey, jsonEncode(item.toJson()));
  }

  Future<List<RecognitionHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];

    return historyJson
        .map((item) => RecognitionHistory.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<RecognitionHistory?> getLastScan() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScanJson = prefs.getString(_lastScanKey);

    if (lastScanJson != null) {
      return RecognitionHistory.fromJson(jsonDecode(lastScanJson));
    }
    return null;
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> clearLastScan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastScanKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_lastScanKey);
  }
}
