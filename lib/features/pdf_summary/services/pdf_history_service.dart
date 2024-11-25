import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pdf_history.dart';

class PDFHistoryService {
  static const String _historyKey = 'pdf_history';
  static const String _lastSummaryKey = 'last_pdf_summary';
  static const int _maxHistoryItems = 3;

  Future<void> saveToHistory(PDFHistory item) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing history
    List<PDFHistory> history = await getHistory();

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

    // Save as last summary
    await saveLastSummary(item);
  }

  Future<void> saveLastSummary(PDFHistory item) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSummaryKey, jsonEncode(item.toJson()));
  }

  Future<List<PDFHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];

    return historyJson
        .map((item) => PDFHistory.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<PDFHistory?> getLastSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSummaryJson = prefs.getString(_lastSummaryKey);

    if (lastSummaryJson != null) {
      return PDFHistory.fromJson(jsonDecode(lastSummaryJson));
    }
    return null;
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> clearLastSummary() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSummaryKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_lastSummaryKey);
  }
}
