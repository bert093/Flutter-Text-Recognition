import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class TextRecognitionScreen extends StatefulWidget {
  const TextRecognitionScreen({super.key});
  
  @override
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  late TextRecognizer _textRecognizer;
  String _recognizedText = 'Pilih gambar untuk memulai scan teks';
  bool _isProcessing = false;

  TextRecognitionScript _currentScript = TextRecognitionScript.latin;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: _currentScript);
  }

  // Method untuk ganti bahasa
  void _changeLanguage(TextRecognitionScript newScript) {
    _textRecognizer.close();

    setState(() {
      _currentScript = newScript;
      _textRecognizer = TextRecognizer(script: _currentScript);
    });
  }

  void _showLanguageSelection() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            title: const Text('Pilih Bahasa'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('English, Indonesia, dll'),
                    onTap: () {
                      Navigator.pop(context);
                      _changeLanguage(TextRecognitionScript.latin);
                    },
                  ),
                  ListTile(
                    title: const Text('Chinese'),
                    onTap: () {
                      Navigator.pop(context);
                      _changeLanguage(TextRecognitionScript.chinese);
                    },
                  ),
                  ListTile(
                    title: const Text('Devanagari'),
                    onTap: () {
                      Navigator.pop(context);
                      _changeLanguage(TextRecognitionScript.devanagiri);
                    },
                  ),
                  ListTile(
                    title: const Text('Japanese'),
                    onTap: () {
                      Navigator.pop(context);
                      _changeLanguage(TextRecognitionScript.japanese);
                    },
                  ),
                  ListTile(
                    title: const Text('Korean'),
                    onTap: () {
                      Navigator.pop(context);
                      _changeLanguage(TextRecognitionScript.korean);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  // memilih sumber gambar (galeri atau camera)
  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // memilih gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        await _processImageForTextRecognition(image.path);
      }
    } catch (e) {
      setState(() {
        _recognizedText = 'Error: Gagal memilih gambar dari galeri';
      });
    }
  }

  // memilih gambar dari kamera
  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        await _processImageForTextRecognition(image.path);
      }
    } catch (e) {
      setState(() {
        _recognizedText = 'Error: Gagal mengambil gambar';
      });
    }
  }

  // memproses gambar
  Future<void> _processImageForTextRecognition(String imagePath) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _recognizedText = 'Memproses gambar...';
    });

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      String fullText = '';

      // gunakan variable recognizedText untuk ekstraksi teks
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          fullText += '${line.text}\n';
        }
      }

      setState(() {
        _recognizedText = fullText.isEmpty
            ? 'Tidak ada teks terdeteksi'
            : fullText;
      });

    } catch (e) {
      setState(() {
        _recognizedText = 'Error: Gagal memproses gambar';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          DropdownButton<TextRecognitionScript>(
            value: _currentScript,
            icon: const Icon(Icons.language, color: Colors.black),
            dropdownColor: Colors.white,
            onChanged: (TextRecognitionScript? newScript) {
              if (newScript != null) {
                _changeLanguage(newScript);
              }
            },
            items: [
              const DropdownMenuItem(
                value: TextRecognitionScript.latin,
                child: Text('Latin', style: TextStyle(color: Colors.black)),
              ),
              const DropdownMenuItem(
                value: TextRecognitionScript.chinese,
                child: Text('Chinese', style: TextStyle(color: Colors.black)),
              ),
              const DropdownMenuItem(
                value: TextRecognitionScript.devanagiri,
                child: Text('Devanagiri', style: TextStyle(color: Colors.black)),
              ),
              const DropdownMenuItem(
                value: TextRecognitionScript.japanese,
                child: Text('Japanese', style: TextStyle(color: Colors.black)),
              ),
              const DropdownMenuItem(
                value: TextRecognitionScript.korean,
                child: Text('Korean', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Header dengan instruksi
          Container(
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                SizedBox(height: 8),
                Text(
                  'Pilih gambar dari galeri atau ambil foto baru untuk mengekstrak teks',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Area hasil teks
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _recognizedText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 20),
            FloatingActionButton(
              onPressed: _showImageSourceSelection,
              backgroundColor: Colors.blue,
              elevation: 10,
              child: const Icon(Icons.add_photo_alternate, color: Colors.black)
            ),
            const SizedBox(width: 20),
            FloatingActionButton(
              onPressed: _showLanguageSelection,
              backgroundColor: Colors.orange,
              elevation: 10,
              child: const Icon(Icons.language, color: Colors.black)
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }
}