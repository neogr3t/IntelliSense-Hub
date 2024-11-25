import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFProcessingService {
  static const String apiKey = 'AIzaSyCcCoautZtOHqHdHORWJ01Cp9SMhNbapkI';
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      // Load the PDF document
      final PdfDocument document =
          PdfDocument(inputBytes: await pdfFile.readAsBytes());
      String extractedText = '';

      // Extract text from each page
      for (int i = 0; i < document.pages.count; i++) {
        // Get the current page
        final PdfPage page = document.pages[i];

        // Extract text from the page
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        String pageText = extractor.extractText(startPageIndex: i);

        // Add page text to the total extracted text
        extractedText += '$pageText\n\n';
      }

      // Clean up
      document.dispose();

      // Remove excessive whitespace and normalize line breaks
      extractedText = extractedText
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'\n\s*\n'), '\n\n')
          .trim();

      return extractedText;
    } catch (e) {
      throw Exception('Error extracting text from PDF: $e');
    }
  }

  Future<String> summarizeText(String text) async {
    try {
      // Split text into chunks if it's too long (Gemini has a token limit)
      final chunks = _splitTextIntoChunks(text);
      List<String> summaries = [];

      for (String chunk in chunks) {
        final response = await http.post(
          Uri.parse('$baseUrl?key=$apiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text':
                        '''Please provide a concise summary of the following text, 
                          highlighting the main points and key takeaways:
                          
                          $chunk'''
                  }
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.4,
              'topK': 32,
              'topP': 1,
              'maxOutputTokens': 1024,
            }
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          String chunkSummary =
              data['candidates'][0]['content']['parts'][0]['text'];
          summaries.add(chunkSummary);
        } else {
          throw Exception('Failed to get summary: ${response.statusCode}');
        }
      }

      // If we had multiple chunks, summarize the summaries
      if (summaries.length > 1) {
        final finalSummary = await _combineSummaries(summaries.join('\n\n'));
        return finalSummary;
      }

      return summaries.first;
    } catch (e) {
      throw Exception('Error summarizing text: $e');
    }
  }

  Future<String> _combineSummaries(String summaries) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''Please provide a unified, coherent summary of these collected summaries,
                        ensuring all key points are included and flow logically:
                        
                        $summaries'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to combine summaries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error combining summaries: $e');
    }
  }

  List<String> _splitTextIntoChunks(String text, {int chunkSize = 5000}) {
    List<String> chunks = [];

    // Split by paragraphs first
    List<String> paragraphs = text.split('\n\n');
    String currentChunk = '';

    for (String paragraph in paragraphs) {
      if ((currentChunk + paragraph).length > chunkSize) {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.trim());
        }
        currentChunk = paragraph;
      } else {
        currentChunk += '\n\n$paragraph';
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }

    return chunks;
  }
}
