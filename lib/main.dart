import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intellisensehub/features/audio_processing/presentation/screens/audio_processing_screen.dart';
import 'package:intellisensehub/features/image_recognition/presentation/screens/text_recognition_screen.dart';
import 'package:intellisensehub/features/onboarding/screens/splash_screen.dart';
import 'package:intellisensehub/features/speech_translator/presentation/screens/speech_translation_screen.dart';
import 'package:intellisensehub/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'config/env_config.dart';
import 'data/services/preferences_service.dart';
import 'features/home/home_screen.dart';
import 'features/pdf_summary/screen/pdf_summary_screen.dart';

void main() async {
  await EnvConfig.initialize();

  WidgetsFlutterBinding.ensureInitialized();
  final preferencesService = PreferencesService();
  await preferencesService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multimodal Recognition App',
      theme: context.watch<ThemeProvider>().currentTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AudioProcessingScreen(),
    const TextRecognitionScreen(),
    const PDFSummaryScreen(),
    const SpeechTranslationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                    1, Icons.audio_file_outlined, Icons.audio_file, 'Audio'),
                _buildNavItem(2, Icons.document_scanner_outlined,
                    Icons.document_scanner, 'Text'),
                _buildHomeButton(),
                _buildNavItem(3, Icons.picture_as_pdf_outlined,
                    Icons.picture_as_pdf, 'PDF'),
                _buildNavItem(
                    4, Icons.translate_outlined, Icons.translate, 'Translate'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton() {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedIndex = 0; // This now correctly points to HomeScreen
      }),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.home,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() {
        _selectedIndex = index;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.grey[800] : Colors.grey[100])
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected
                  ? theme.colorScheme.primary
                  : isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? theme.colorScheme.primary
                    : isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
