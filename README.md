# IntelliSense Hub 🚀

IntelliSense Hub is a mobile application that uses AI to help users process and understand different types of content. The app currently focuses on PDF analysis, audio processing, image recognition, and speech translation capabilities, providing an intuitive interface for content understanding.

**APK Link for android** [Download apk](https://drive.google.com/file/d/1ySh8cOGKmqNaiQ3jpwxXR_OsIAQAS3Mp/view?usp=sharing)

## Core Features 🎯

### 1. PDF Analysis 📄

- Generate intelligent summaries from PDF documents
- Built-in PDF preview functionality
- Text-to-speech capability for summaries
- Save and manage analysis history
- Export summaries for sharing
- Markdown rendering support for formatted summaries

### 2. Audio Processing 🎙️

- Transcribe audio files to text
- Process audio from both files and URLs
- Built-in transcription history management
- Text-to-speech playback of transcriptions
- Share and export transcriptions

### 3. Image Recognition 📸

- Extract text from images using OCR
- Support for camera and gallery image sources
- Real-time text extraction with progress indicator
- View and manage scan history
- Text-to-speech capability for extracted text
- Share and copy extracted text
- Preview scanned images
- Clear current scan or entire history

### 4. Speech Translation 🗣️

- Real-time speech-to-text conversion
- Support for multiple languages
- Bidirectional translation between languages
- Text-to-speech playback in source and target languages
- Confidence level indicator for speech recognition
- Copy translated text to clipboard
- Manual text input option
- Language swap functionality
- Auto-speak settings for translations

## Technical Architecture 🏗️

The project follows a feature-based architecture with clear separation of concerns:

```
lib/
├── features/
│   ├── pdf_summary/
│   │   ├── models/
│   │   ├── presentation/
│   │   └── services/
│   ├── audio_processing/
│   │   ├── models/
│   │   ├── presentation/
│   │   └── services/
│   ├── image_recognition/
│   │   ├── models/
│   │   ├── presentation/
│   │   └── services/
│   └── speech_translation/
│       ├── models/
│       ├── presentation/
│       └── services/
└── shared/
    ├── services/
    │   └── tts_service.dart
    └── utils/
        └── clipboard_util.dart
```

## Prerequisites 📋

Before you begin, ensure you have met the following requirements:

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio / VS Code
- API Keys for configured

## Installation 🛠️

1. **Clone the repository**

```bash
git clone https://github.com/neogr3t/intellisense-hub.git
cd intellisense-hub
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Create environment file**
   Create a `.env` file in the root directory with the following content:

```
DEEPGRAM_API_KEY=your_deepgram_api_key
GEMINI_API_KEY=your_gemini_api_key
```

4. **Run the app**

```bash
flutter run
```

## Feature Details 🔄

### PDF Analysis Flow:

1. **File Selection**

   - Upload PDF documents through the file picker
   - Preview PDF content before processing

2. **Processing**

   - Extract text content from PDF
   - Generate intelligent summaries
   - Display progress indicators during processing

3. **Results Management**
   - View formatted summaries with Markdown support
   - Listen to summaries via text-to-speech
   - Share or export summaries
   - Access historical summaries

### Audio Processing Flow:

1. **Input Methods**

   - Upload audio files through file picker
   - Process audio from URLs
   - Support for multiple audio formats

2. **Transcription**

   - Convert audio to text
   - Display progress during processing
   - Show real-time status updates

3. **Results Management**
   - View transcribed text
   - Listen to transcriptions via text-to-speech
   - Share transcriptions
   - Access historical transcriptions

### Image Recognition Flow:

1. **Image Capture**

   - Take photos using device camera
   - Select images from gallery
   - Preview selected images

2. **Text Recognition**

   - Extract text using OCR
   - Show progress during processing
   - Display confidence levels

3. **Results Management**
   - View extracted text
   - Listen to text via text-to-speech
   - Copy text to clipboard
   - Access scan history
   - Clear individual scans or entire history

### Speech Translation Flow:

1. **Input Methods**

   - Real-time speech recognition
   - Manual text input
   - Language selection for source and target

2. **Translation**

   - Real-time translation between languages
   - Support for multiple language pairs
   - Display confidence levels for speech recognition

3. **Results Management**
   - View translated text
   - Listen to translations via text-to-speech
   - Copy translations to clipboard
   - Language swap functionality
   - Configurable auto-speak settings

## Key Components 🔧

### PDF Summary Module

- `PDFSummaryScreen`: Main UI for PDF processing
- `PDFProcessingService`: Handles PDF text extraction and summarization
- `PDFHistoryService`: Manages PDF processing history
- `PDFPreview`: Component for PDF file preview

### Audio Processing Module

- `AudioProcessingScreen`: Main UI for audio transcription
- `AudioProcessingService`: Handles audio file transcription
- `AudioHistoryService`: Manages transcription history
- `TTSService`: Shared text-to-speech functionality

### Image Recognition Module

- `TextRecognitionScreen`: Main UI for image text extraction
- `ImageTextRecognitionService`: Handles OCR processing
- `TextRecognitionHistoryService`: Manages scan history
- `ImagePreview`: Component for image preview
- `TextActions`: Component for text-related actions

### Speech Translation Module

- `SpeechTranslationScreen`: Main UI for speech translation
- `SpeechService`: Handles speech recognition
- `TranslationService`: Handles text translation
- `ConfidenceIndicator`: Shows speech recognition confidence
- `SpeechActions`: Component for speech-related actions

## Dependencies 📦

Key packages used in the project:

- `file_picker`: For file selection
- `flutter_markdown`: For rendering markdown content
- `intl`: For date formatting
- `uuid`: For generating unique identifiers
- `share_plus`: For sharing content
- `path_provider`: For file system access
- `image_picker`: For camera and gallery image selection

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
