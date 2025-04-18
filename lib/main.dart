import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
// 音声設定参考：　https://hash-code.net/flutter/flutter-how-to-use-a-microphone-with-an-android-emulator/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DETECT DOG',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 212, 119, 52)),
      ),
      home: const MyHomePageDogName(title: 'DOG DETECT'),
    );
  }
}

class MyHomePageDogName extends StatefulWidget {
  const MyHomePageDogName({super.key, required this.title});
  final String title;

  @override
  State<MyHomePageDogName> createState() => _MyHomePageDogNameState();
}

class _MyHomePageDogNameState extends State<MyHomePageDogName> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _dogName = '';
  String? _dogImage;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    requestPermission();
  }

  Future<void> requestPermission() async {
    var status = await Permission.microphone.status;
    if(!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print("Error: $error"),
      debugLogging: true,
    );
    if(available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _dogName = result.recognizedWords;
            _updateDogImage(_dogName);
          });
        }
      );
    }
  }
  void _updateDogImage(String name) {
    String normalized = name.toLowerCase();
    if(normalized.contains('りき') || normalized.contains('riki')) {
      _dogImage = 'assets/images/riki.jpg';
    } else if(normalized.contains('じゃっく') || normalized.contains('jack')) {
      _dogImage = 'assets/images/jack.jpg';
    } else {
      _dogImage = null;
    }
  }

  void stopListening() {
    if(_speech.isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('認識された名前: $_dogName'),
            const SizedBox(height: 20),
            _dogImage != null ? Image.asset(_dogImage!, height: 200) : const Text('犬の画像が見つかりません'),
          ],
        ),
      ), 
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if(_isListening) {
            stopListening();
          } else if(await _speech.hasPermission && _speech.isNotListening) {
              await startListening();
          }
        },
        tooltip: 'Mic',
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}