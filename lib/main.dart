import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() => runApp(SpeechSampleApp());

class SpeechSampleApp extends StatefulWidget {
  @override
  _SpeechSampleAppState createState() => _SpeechSampleAppState();
}

class _SpeechSampleAppState extends State<SpeechSampleApp> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speech = stt.SpeechToText();
    await _speech.initialize();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _isListening ? stopListening : startListening,
          child: Icon(_isListening ? Icons.stop : Icons.mic),
        ),
        body: Column(
          children: [
            const TextField(
                decoration: InputDecoration(
              hintText: 'Enter text here',
            )),
            TextField(
              controller: TextEditingController(text: _text),
            ),
          ],
        ),
      ),
    );
  }

  _listenVoice() {
    if (_speech.isListening) return;

    _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        debugPrint(result.recognizedWords);
        setState(() {
          _text = result.recognizedWords;
        });
      },
      //listenMode: ListenMode.dictation,
      //listenFor: Duration(seconds: 100),
      onDevice: false,
      cancelOnError: false,
      // onError: (error) {
      //   setState(() {
      //     // handle error
      //   });
      // },
      onSoundLevelChange: (level) {
        // update UI with sound level
      },
    );
  }

  void startListening() async {
    bool microphonePermissionGranted =
        await Permission.microphone.request().isGranted;
    if (!microphonePermissionGranted) {
      debugPrint('No mic');
      // handle microphone permission not granted
      return;
    }
    debugPrint('Yes mic');
    setState(() {
      _isListening = true;
    });

    _listenVoice();
    if (Platform.isAndroid) {
      Timer.periodic(Duration(seconds: 2), ((Timer t) async {
        if (_isListening) {
          _listenVoice();
        }
      }));
    }
  }

  void stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }
}
