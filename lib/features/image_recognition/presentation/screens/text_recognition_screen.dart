import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlapp/features/image_recognition/models/recognition_history.dart';

import 'package:mlapp/features/image_recognition/presentation/widgets/text_recognition_result.dart';
import 'package:mlapp/features/image_recognition/services/text_recog_history_service.dart';
import '../widgets/image_preview.dart';
import '../widgets/text_actions.dart';
import '../widgets/bottom_actions.dart';
import '../../services/image_text_recognition_service.dart';
import '../../../../shared/services/tts_service.dart';

class TextRecognitionScreen extends StatefulWidget {
  const TextRecognitionScreen({super.key});

  @override
  State<TextRecognitionScreen> createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  final ImageTextRecognitionService _recognitionService =
      ImageTextRecognitionService();
  final TextRecognitionHistoryService _historyService =
      TextRecognitionHistoryService();
  final TTSService _ttsService = TTSService();
  List<RecognitionHistory> history = [];
  File? pickedImage;
  String textData = '';
  bool isTextDetected = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadLastScan();
    await _loadHistory();
  }

  Future<void> _loadLastScan() async {
    final lastScan = await _historyService.getLastScan();
    if (lastScan != null) {
      setState(() {
        pickedImage = File(lastScan.imagePath);
        textData = lastScan.extractedText;
        isTextDetected = textData.isNotEmpty;
      });
    }
  }

  Future<void> _loadHistory() async {
    final loadedHistory = await _historyService.getHistory();
    setState(() {
      history = loadedHistory;
    });
  }

  Future<void> _clearCurrentScan() async {
    await _historyService.clearLastScan();
    setState(() {
      pickedImage = null;
      textData = '';
      isTextDetected = false;
    });
  }

  Future<void> _clearAll() async {
    await _historyService.clearAll();
    setState(() {
      history = [];
      pickedImage = null;
      textData = '';
      isTextDetected = false;
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      pickedImage = File(image.path);
      textData = "";
      isTextDetected = false;
      isLoading = true;
    });

    try {
      final extractedText = await _recognitionService.extractText(pickedImage!);
      final recognitionHistory = RecognitionHistory(
        imagePath: image.path,
        extractedText: extractedText.replaceAll('\n', ' '),
        timestamp: DateTime.now(),
      );

      await _historyService.saveToHistory(recognitionHistory);
      await _loadHistory(); // Reload history after saving

      setState(() {
        textData = recognitionHistory.extractedText;
        isTextDetected = textData.isNotEmpty;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        textData = "Error processing image";
        isLoading = false;
      });
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
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
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
                                'Text Recognition',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.history),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        _buildHistorySheet(theme),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload or take a photo to extract text',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ImagePreview(pickedImage: pickedImage),
                      ),
                    ),
                  ),
                  if (pickedImage != null)
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
                          child: isLoading
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: CircularProgressIndicator(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    TextRecognitionResult(text: textData),
                                    if (isTextDetected)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextButton.icon(
                                          onPressed: _clearCurrentScan,
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          label: const Text(
                                            'Clear Current Scan',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  if (isTextDetected)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextActions(
                          text: textData,
                          ttsService: _ttsService,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 180),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: BottomActions(
                    onCameraPressed: () => pickImage(ImageSource.camera),
                    onGalleryPressed: () => pickImage(ImageSource.gallery),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySheet(ThemeData theme) {
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
                'Recent Scans',
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
                          onPressed: () {
                            _clearAll();
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Close bottom sheet
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
          ...history
              .map((item) => ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        File(item.imagePath),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image),
                      ),
                    ),
                    title: Text(
                      item.extractedText.length > 50
                          ? '${item.extractedText.substring(0, 50)}...'
                          : item.extractedText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _formatDate(item.timestamp),
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () {
                      setState(() {
                        pickedImage = File(item.imagePath);
                        textData = item.extractedText;
                        isTextDetected = true;
                      });
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
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
}
