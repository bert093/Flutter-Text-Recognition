import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.cameras});
  final List<CameraDescription> cameras;
  
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late TextRecognizer _textRecognizer;
  String _recognizedText = 'Tekan capture untuk scan teks';
  bool _isProcessing = false;

  TextRecognitionScript _currentScript = TextRecognitionScript.latin;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    // _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _textRecognizer = TextRecognizer(script: _currentScript);
  }

  // Method untuk ganti bahasa
  void _changeLanguage(TextRecognitionScript newScript) {
    _textRecognizer.close();

    // buat recognizer baru dengan bahasa yang ingin dipilih
    setState(() {
      _currentScript = newScript;
      _textRecognizer = TextRecognizer(script: _currentScript);
    });
  }

  void _initializeCamera() async {
    _controller = CameraController(
      widget.cameras[0], 
      ResolutionPreset.max
    );
    
    await _controller.initialize();
    if (mounted) setState(() {});
  }

  void _captureAndRecognize() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _recognizedText = 'Memproses gambar...';
    });
    
    try {
      final XFile picture = await _controller.takePicture();
      await _processImageForTextRecognition(picture.path);
      final inputImage = InputImage.fromFilePath(picture.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String fullText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          fullText += '${line.text}\n';
        }
      }

      setState(() {
        _recognizedText = fullText.isEmpty ? 'Tidak ada teks terdeteksi' : fullText;
      });
    } catch (e) {
      setState(() {
        _recognizedText = 'Error: $e';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showLanguageSelection() { // Dialog Language Selection
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Bahasa'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text('English, Indonesia, dll'),
                  onTap: () {
                    Navigator.pop(context);
                    _changeLanguage(TextRecognitionScript.latin);
                  },
                ),
                ListTile(
                  title: Text('Chinese'),
                  onTap: () {
                    Navigator.pop(context);
                    _changeLanguage(TextRecognitionScript.chinese);
                  },
                ),
                ListTile(
                  title: Text('Devanagari'),
                  onTap: () {
                    Navigator.pop(context);
                    _changeLanguage(TextRecognitionScript.devanagiri);
                  },
                ),
                ListTile(
                  title: Text('Japanese'),
                  onTap: () {
                    Navigator.pop(context);
                    _changeLanguage(TextRecognitionScript.japanese);
                  },
                ),
                ListTile(
                  title: Text('Korean'),
                  onTap: () {
                    Navigator.pop(context);
                    _changeLanguage(TextRecognitionScript.korean);
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // memilih sumber gambar
  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Ambil Foto'),
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
        _processImageForTextRecognition(image.path);
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
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
        _processImageForTextRecognition(image.path);
      }
    } catch (e) {
      print('Error taking picture: $e');
      setState(() {
        _recognizedText = 'Error: Gagal mengambil gambar';
      });
    }
  }

  // memproses gambar dan print ke terminal
  Future<void> _processImageForTextRecognition(String imagePath) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _recognizedText = 'Memproses gambar...';
    });

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      String fullText = '';

      // Loop melalui semua blok teks yang terdeteksi
      for (TextBlock block in recognizedText.blocks) {
        print('=== BLOCK TEXT ===');
        print(block.text);
        print('==================');

        for (TextLine line in block.lines) {
          fullText += '${line.text}\n';

          // Print setiap line ke terminal
          print('Line: ${line.text}');

          // Jika ingin detail lebih lanjut, bisa print setiap element
          for (TextElement element in line.elements) {
            print('  Element: ${element.text}');
          }
        }
      }

      // Print keseluruhan teks ke terminal
      print('=== HASIL EKSTRAKSI TEKS LENGKAP ===');
      print(fullText);
      print('=====================================');

      setState(() {
        _recognizedText = fullText.isEmpty
            ? 'Tidak ada teks terdeteksi'
            : fullText;
      });

      // Tutup text recognizer untuk menghindari memory leak
      textRecognizer.close();
    } catch (e) {
      print('Error processing image: $e');
      setState(() {
        _recognizedText = 'Error: Gagal memproses gambar';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          DropdownButton<TextRecognitionScript>( //* Dropdown button untuk pilihan bahasa
            value: _currentScript,
            icon: Icon(Icons.language, color: Colors.black),
            dropdownColor: Colors.blue,
            onChanged: (TextRecognitionScript? newScript) {
              if (newScript != null) {
                _changeLanguage(newScript);
              }
            },
            items: [
              DropdownMenuItem(
                value: TextRecognitionScript.latin,
                child: Text('Latin', style: TextStyle(color: Colors.black)),
              ),
              DropdownMenuItem(
                value: TextRecognitionScript.chinese,
                child: Text('Chinese', style: TextStyle(color: Colors.black)),
              ),
              DropdownMenuItem(
                value: TextRecognitionScript.devanagiri,
                child: Text('Devanagiri', style: TextStyle(color: Colors.black)),
              ),
              DropdownMenuItem(
                value: TextRecognitionScript.japanese,
                child: Text('Japanese', style: TextStyle(color: Colors.black)),
              ),
              DropdownMenuItem(
                value: TextRecognitionScript.korean,
                child: Text('Korean', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: CameraPreview(_controller),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Text(
                  _recognizedText,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: _captureAndRecognize,
              backgroundColor: _isProcessing ? Colors.grey: Colors.blue,
              elevation: 20, // biar ada shadow effect pada icon
              child: _isProcessing
                  ? CircularProgressIndicator(color: Colors.white)
                  : Icon(Icons.camera)
            ),
            SizedBox(width: 20),
            FloatingActionButton(
              onPressed: _showImageSourceSelection,
              backgroundColor: Colors.green,
              child: Icon(Icons.photo_library)
            ),
            SizedBox(width: 20),
            FloatingActionButton(
              onPressed: _showLanguageSelection,
              backgroundColor: Colors.orange,
              child: Icon(Icons.language)
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textRecognizer.close();
    super.dispose();
  }
}