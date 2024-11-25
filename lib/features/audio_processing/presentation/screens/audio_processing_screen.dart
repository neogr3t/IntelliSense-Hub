import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../image_recognition/presentation/widgets/text_actions.dart';
import '../../services/audio_processing_service.dart';
import '../../services/audio_history_service.dart';
import '../../models/audio_history.dart';
import '../../../../shared/services/tts_service.dart';

class AudioProcessingScreen extends StatefulWidget {
  const AudioProcessingScreen({Key? key}) : super(key: key);

  @override
  State<AudioProcessingScreen> createState() => _AudioProcessingScreenState();
}

class _AudioProcessingScreenState extends State<AudioProcessingScreen> {
  final AudioProcessingService _audioService = AudioProcessingService(
    apiKey: 'df4411b69b5ab13d54c07c5b37430b90e49bb338',
  );
  final AudioHistoryService _historyService = AudioHistoryService();
  final TTSService _ttsService = TTSService();
  final TextEditingController _urlController = TextEditingController();
  final _uuid = const Uuid();

  String? _audioPath;
  String? _transcript;
  bool _isProcessing = false;
  List<AudioHistory> _history = [];
  StreamSubscription<String>? _transcriptionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeTTSService();
    _loadInitialData();
  }

  Future<void> _initializeTTSService() async {
    await _ttsService.initialize();
  }

  Future<void> _loadInitialData() async {
    await _loadLastTranscription();
    await _loadHistory();
  }

  Future<void> _loadLastTranscription() async {
    final lastTranscription = await _historyService.getLastTranscription();
    if (lastTranscription != null) {
      setState(() {
        if (lastTranscription.isUrl) {
          _urlController.text = lastTranscription.sourcePath;
          _audioPath = null;
        } else {
          _audioPath = lastTranscription.sourcePath;
          _urlController.clear();
        }
        _transcript = lastTranscription.transcript;
      });
    }
  }

  Future<void> _clearCurrentTranscription() async {
    await _historyService.clearLastTranscription();
    setState(() {
      _transcript = null;
      _audioPath = null;
      _urlController.clear();
    });
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.getHistory();
    setState(() {
      _history = history;
    });
  }

  @override
  void dispose() {
    _transcriptionSubscription?.cancel();
    _urlController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _audioPath = result.files.single.path;
        _transcript = null;
      });
      await _processFile();
    }
  }

  Future<void> _processFile() async {
    if (_audioPath == null) return;

    setState(() {
      _isProcessing = true;
      _transcript = null;
    });

    try {
      final transcript = await _audioService.transcribeFile(_audioPath!);
      final historyItem = AudioHistory(
        id: _uuid.v4(),
        sourcePath: _audioPath!,
        transcript: transcript,
        timestamp: DateTime.now(),
        isUrl: false,
      );

      await _historyService.saveToHistory(historyItem);
      await _loadHistory();

      setState(() {
        _transcript = transcript;
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processUrl() async {
    if (_urlController.text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _transcript = null;
    });

    try {
      final transcript = await _audioService.transcribeUrl(_urlController.text);
      final historyItem = AudioHistory(
        id: _uuid.v4(),
        sourcePath: _urlController.text,
        transcript: transcript,
        timestamp: DateTime.now(),
        isUrl: true,
      );

      await _historyService.saveToHistory(historyItem);
      await _loadHistory();

      setState(() {
        _transcript = transcript;
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _loadHistoryItem(AudioHistory item) async {
    setState(() {
      _transcript = item.transcript;
      if (item.isUrl) {
        _urlController.text = item.sourcePath;
        _audioPath = null;
      } else {
        _audioPath = item.sourcePath;
        _urlController.clear();
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  Widget _buildHistoryBottomSheet(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transcriptions',
                style: theme.textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear History'),
                      content: const Text(
                          'Are you sure you want to clear all history?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _historyService.clearAll();
                            await _loadHistory();
                            if (mounted) {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Close bottom sheet
                            }
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return ListTile(
                  leading: Icon(
                    item.isUrl ? Icons.link : Icons.audio_file,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    item.isUrl
                        ? item.sourcePath
                        : item.sourcePath.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.transcript.length > 50
                            ? '${item.transcript.substring(0, 50)}...'
                            : item.transcript,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatTimestamp(item.timestamp),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  onTap: () {
                    _loadHistoryItem(item);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildHistoryBottomSheet(Theme.of(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Audio Processing',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.history),
                            onPressed: _showHistoryBottomSheet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload audio file or provide URL to transcribe',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // URL Input Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            labelText: 'Audio URL',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _processUrl,
                          icon: const Icon(Icons.link),
                          label: const Text('Process URL'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // File Upload Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Upload Audio File',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isProcessing ? null : _pickAudioFile,
                          child: const Text('Select File'),
                        ),
                        if (_audioPath != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Selected: ${_audioPath!.split('/').last}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Processing Indicator
              if (_isProcessing)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                        SizedBox(height: 16),
                        Text("Transcribing audio...")
                      ],
                    ),
                  ),
                ),

              // Transcript Display
              if (_transcript != null && !_isProcessing)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transcript',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          Text(_transcript!),
                          if (_transcript != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: TextButton.icon(
                                  onPressed: _clearCurrentTranscription,
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    'Clear Current Transription',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          TextActions(
                            text: _transcript!,
                            ttsService: _ttsService,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
