import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/audio_history.dart';

class AudioHistoryService {
  static const String _historyKey = 'audio_history';
  static const String _lastTranscriptionKey = 'last_transcription';
  static const int _maxHistoryItems = 3;

  Future<void> saveToHistory(AudioHistory item) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing history
    List<AudioHistory> history = await getHistory();

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

    // Save as last transcription
    await saveLastTranscription(item);
  }

  Future<void> saveLastTranscription(AudioHistory item) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastTranscriptionKey, jsonEncode(item.toJson()));
  }

  Future<List<AudioHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];

    return historyJson
        .map((item) => AudioHistory.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<AudioHistory?> getLastTranscription() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTranscriptionJson = prefs.getString(_lastTranscriptionKey);

    if (lastTranscriptionJson != null) {
      return AudioHistory.fromJson(jsonDecode(lastTranscriptionJson));
    }
    return null;
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> clearLastTranscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastTranscriptionKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_lastTranscriptionKey);
  }
}
