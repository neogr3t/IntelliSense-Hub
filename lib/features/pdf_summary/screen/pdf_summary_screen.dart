import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:mlapp/features/pdf_summary/services/pdf_history_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/services/tts_service.dart';
import '../../image_recognition/presentation/widgets/text_actions.dart';
import '../models/pdf_history.dart';
import '../services/pdf_processing_service.dart';
import '../widgets/pdf_preview.dart';

class PDFSummaryScreen extends StatefulWidget {
  const PDFSummaryScreen({Key? key}) : super(key: key);

  @override
  State<PDFSummaryScreen> createState() => _PDFSummaryScreenState();
}

class _PDFSummaryScreenState extends State<PDFSummaryScreen> {
  final _pdfService = PDFProcessingService();
  final _historyService = PDFHistoryService();
  final _ttsService = TTSService();
  final _uuid = const Uuid();

  File? _pdfFile;
  String _summary = '';
  bool _isProcessing = false;
  bool _isSpeaking = false;
  String _processingStatus = '';
  List<PDFHistory> _history = [];

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _loadInitialData();
  }

  Future<void> _initializeTTS() async {
    try {
      await _ttsService.initialize();
    } catch (e) {
      if (mounted) {
        _showError('Failed to initialize text-to-speech: $e');
      }
    }
  }

  Future<void> _toggleSpeech() async {
    if (_summary.isEmpty) return;

    try {
      if (_ttsService.isPlaying) {
        bool result = await _ttsService.pause();
        if (result) {
          setState(() {
            _isSpeaking = false;
          });
        }
      } else if (_ttsService.isPaused) {
        bool result = await _ttsService.resume();
        if (result) {
          setState(() {
            _isSpeaking = true;
          });
        }
      } else {
        bool result = await _ttsService.speak(
          _summary,
          () {
            if (mounted) {
              setState(() {
                _isSpeaking = false;
              });
            }
          },
          feature: TTSFeature.pdfSummary,
        );

        if (result) {
          setState(() {
            _isSpeaking = true;
          });
        }
      }
    } catch (e) {
      print('Toggle speech error: $e');
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  // Build TTS Control Button
  Widget _buildTTSButton() {
    return IconButton(
      icon: Icon(_isSpeaking ? Icons.stop : Icons.play_arrow),
      onPressed: _toggleSpeech,
      tooltip: _isSpeaking ? 'Stop Speaking' : 'Read Summary',
    );
  }

  Future<void> _loadInitialData() async {
    await _loadLastSummary();
    await _loadHistory();
  }

  Future<void> _loadLastSummary() async {
    final lastSummary = await _historyService.getLastSummary();
    if (lastSummary != null) {
      setState(() {
        _pdfFile = File(lastSummary.filePath);
        _summary = lastSummary.summary;
      });
    }
  }

  Future<void> _clearCurrentSummary() async {
    await _historyService.clearLastSummary();
    setState(() {
      _summary = '';
      _pdfFile = null;
    });
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.getHistory();
    setState(() {
      _history = history;
    });
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _pdfFile = File(result.files.single.path!);
          _summary = '';
        });
        await _processPDF();
      }
    } catch (e) {
      _showError('Error picking PDF: $e');
    }
  }

  Future<void> _processPDF() async {
    if (_pdfFile == null) return;

    setState(() {
      _isProcessing = true;
      _processingStatus = 'Extracting text from PDF...';
    });

    try {
      final text = await _pdfService.extractTextFromPDF(_pdfFile!);

      setState(() {
        _processingStatus = 'Generating summary...';
      });

      final summary = await _pdfService.summarizeText(text);

      // Save to history
      final historyItem = PDFHistory(
        id: _uuid.v4(),
        filePath: _pdfFile!.path,
        summary: summary,
        timestamp: DateTime.now(),
      );

      await _historyService.saveToHistory(historyItem);
      await _loadHistory();

      setState(() {
        _summary = summary;
        _isProcessing = false;
        _processingStatus = '';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _processingStatus = '';
      });
      _showError(_getErrorMessage(e.toString()));
    }
  }

  Future<void> _loadHistoryItem(PDFHistory item) async {
    setState(() {
      _pdfFile = File(item.filePath);
      _summary = item.summary;
    });
  }

  Widget _buildSummarySection(ThemeData theme) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.summarize, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Summary', style: theme.textTheme.titleMedium),
                const Spacer(),
                _buildTTSButton(),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _exportSummary,
                  tooltip: 'Share Summary',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: MarkdownBody(
              data: _summary,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ],
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
                'Recent Summaries',
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
                    Icons.picture_as_pdf,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    item.filePath.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.summary.length > 50
                            ? '${item.summary.substring(0, 50)}...'
                            : item.summary,
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

  void _showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildHistoryBottomSheet(Theme.of(context)),
    );
  }

  String _getErrorMessage(String error) {
    if (error.contains('token limit')) {
      return 'The PDF is too large to process. Try a smaller document.';
    }
    if (error.contains('API key')) {
      return 'API key configuration error. Please check settings.';
    }
    return 'Error processing PDF: $error';
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

  Future<void> _exportSummary() async {
    if (_summary.isEmpty || _pdfFile == null) return;

    try {
      final fileName =
          'summary_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.txt';
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(_summary);
      await Share.shareXFiles([XFile(file.path)], subject: 'PDF Summary');
    } catch (e) {
      _showError('Error exporting summary: $e');
    }
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
                            'PDF Summary',
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
                        'Upload a PDF to get an instant summary',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select PDF Document',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _pickPDF,
                          icon: const Icon(Icons.upload_file),
                          label: Text(
                              _isProcessing ? 'Processing...' : 'Upload PDF'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        if (_pdfFile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Selected: ${_pdfFile!.path.split('/').last}',
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // PDF Preview
              if (_pdfFile != null && !_isProcessing)
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.preview,
                                    color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text('Preview',
                                    style: theme.textTheme.titleMedium),
                              ],
                            ),
                          ),
                          PDFPreview(file: _pdfFile!),
                        ],
                      ),
                    ),
                  ),
                ),

              // Processing Indicator
              if (_isProcessing)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _processingStatus,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        if (_summary.isNotEmpty && !_isProcessing)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: _buildSummarySection(theme),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // Summary Section
              if (_summary.isNotEmpty && !_isProcessing)
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.summarize,
                                    color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text('Summary',
                                    style: theme.textTheme.titleMedium),
                                const Spacer(),
                                TextActions(
                                  text: _summary,
                                  ttsService: _ttsService,
                                  // onShare: _exportSummary,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: MarkdownBody(
                              data: _summary,
                              styleSheet:
                                  MarkdownStyleSheet.fromTheme(theme).copyWith(
                                p: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
