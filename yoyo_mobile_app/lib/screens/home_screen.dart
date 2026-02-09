import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import '../providers/yoyo_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/voice_wave.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _text = '';
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
  
  void _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
          _processVoiceCommand();
        }
      },
    );
  }
  
  void _initTts() async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2); // Voix légèrement plus aiguë pour une voix féminine
    
    // Sélectionner une voix féminine si disponible
    final voices = await _flutterTts.getVoices;
    for (final voice in voices) {
      if (voice is Map && voice['name'].toString().toLowerCase().contains('female')) {
        await _flutterTts.setVoice(voice['name']);
        break;
      }
    }
  }
  
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _text = '';
        });
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
          },
          localeId: 'fr_FR',
        );
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }
  
  void _processVoiceCommand() {
    if (_text.isNotEmpty) {
      final yoyoProvider = Provider.of<YoyoProvider>(context, listen: false);
      yoyoProvider.sendMessage(_text);
      _text = '';
    }
  }
  
  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoyo Assistant'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<YoyoProvider>(
              builder: (context, yoyoProvider, child) {
                if (yoyoProvider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/assistant_waiting.json',
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Bonjour, je suis Yoyo!\nComment puis-je vous aider?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: yoyoProvider.messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final message = yoyoProvider.messages[yoyoProvider.messages.length - 1 - index];
                    return MessageBubble(
                      message: message.text,
                      isUser: message.isUser,
                      timestamp: message.timestamp,
                    );
                  },
                );
              },
            ),
          ),
          if (_text.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceVariant,
              width: double.infinity,
              child: Text(
                _text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarGlow(
                  animate: _isListening,
                  glowColor: Theme.of(context).colorScheme.primary,
                  endRadius: 60.0,
                  duration: const Duration(milliseconds: 2000),
                  repeatPauseDuration: const Duration(milliseconds: 100),
                  repeat: true,
                  child: FloatingActionButton(
                    onPressed: _listen,
                    tooltip: 'Écouter',
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
