import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'receipt_parser.dart';
import 'receipt_result_screen.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({Key? key}) : super(key: key);

  @override
  _ReceiptScannerScreenState createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessingImage = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Mock progress for UI
  double _scanningProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid 
            ? ImageFormatGroup.nv21 
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});

      _startImageStream();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startImageStream() {
    _cameraController?.startImageStream((CameraImage image) async {
      if (_isProcessingImage) return;
      _isProcessingImage = true;

      // Update mock progress
      setState(() {
        _scanningProgress += 0.05;
        if (_scanningProgress > 1.0) _scanningProgress = 0.0;
      });

      try {
        final WriteBuffer allBytes = WriteBuffer();
        for (final Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        final Size imageSize =
            Size(image.width.toDouble(), image.height.toDouble());

        final camera = _cameraController!.description;
        final imageRotation =
            InputImageRotationValue.fromRawValue(camera.sensorOrientation);
        
        if (imageRotation == null) {
           _isProcessingImage = false;
           return;
        }

        final inputImageFormat =
            InputImageFormatValue.fromRawValue(image.format.raw);
            
        if (inputImageFormat == null) {
           _isProcessingImage = false;
           return;
        }

        final planeData = image.planes.map(
          (Plane plane) {
            return InputImageMetadata(
              size: imageSize,
              rotation: imageRotation,
              format: inputImageFormat,
              bytesPerRow: plane.bytesPerRow,
            );
          },
        ).toList();

        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: planeData.first,
        );
        
        final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
        
        // Basic check if it looks like a receipt (has some amounts and text)
        if (recognizedText.text.contains(RegExp(r'\d+\.\d{2}')) && recognizedText.text.length > 20) {
           _cameraController?.stopImageStream();
           
           setState(() {
             _scanningProgress = 1.0;
           });
           
           final receiptData = ReceiptParser.parse(recognizedText);
           
           if (!mounted) return;
           Navigator.of(context).pushReplacement(
             MaterialPageRoute(
               builder: (context) => ReceiptResultScreen(receiptData: receiptData),
             ),
           );
           return; // Stop processing further
        }

      } catch (e) {
        print('Error processing image: $e');
      } finally {
        _isProcessingImage = false;
      }
    });
  }
  
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // TODO: Process gallery image
      final inputImage = InputImage.fromFilePath(image.path);
      _processInputImage(inputImage);
    }
  }

  Future<void> _processInputImage(InputImage inputImage) async {
    setState(() {
      _scanningProgress = 0.5;
    });
    
    try {
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      setState(() {
        _scanningProgress = 1.0;
      });
      
      // Parse the recognized text
      final receiptData = ReceiptParser.parse(recognizedText);
      
      // Stop camera if running
      _cameraController?.stopImageStream();
      
      // Navigate to results
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ReceiptResultScreen(receiptData: receiptData),
        ),
      );
      
    } catch(e) {
       print("Error scanning: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(_cameraController!),

          // Overlay Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        onPressed: _pickImageFromGallery,
                      ),
                    ],
                  ),
                ),

                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _scanningProgress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Scanning ${(_scanningProgress * 100).toInt()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Scanning Frame
                SizedBox(
                  width: size.width * 0.8,
                  height: size.height * 0.5,
                  child: CustomPaint(
                    painter: ScannerOverlayPainter(animationValue: _animation.value),
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double animationValue;

  ScannerOverlayPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paintRect = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final double cornerRadius = 30.0;
    final double lineLength = size.width * 0.2;

    // Top Left
    canvas.drawArc(
        Rect.fromCircle(center: Offset(cornerRadius, cornerRadius), radius: cornerRadius),
        3.14, 1.57, false, paintRect);
    canvas.drawLine(Offset(0, cornerRadius), Offset(0, lineLength + cornerRadius), paintRect);
    canvas.drawLine(Offset(cornerRadius, 0), Offset(lineLength + cornerRadius, 0), paintRect);

    // Top Right
    canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width - cornerRadius, cornerRadius), radius: cornerRadius),
        -1.57, 1.57, false, paintRect);
    canvas.drawLine(Offset(size.width, cornerRadius), Offset(size.width, lineLength + cornerRadius), paintRect);
    canvas.drawLine(Offset(size.width - cornerRadius, 0), Offset(size.width - lineLength - cornerRadius, 0), paintRect);

    // Bottom Left
    canvas.drawArc(
        Rect.fromCircle(center: Offset(cornerRadius, size.height - cornerRadius), radius: cornerRadius),
        1.57, 1.57, false, paintRect);
    canvas.drawLine(Offset(0, size.height - cornerRadius), Offset(0, size.height - lineLength - cornerRadius), paintRect);
    canvas.drawLine(Offset(cornerRadius, size.height), Offset(lineLength + cornerRadius, size.height), paintRect);

    // Bottom Right
    canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width - cornerRadius, size.height - cornerRadius), radius: cornerRadius),
        0, 1.57, false, paintRect);
    canvas.drawLine(Offset(size.width, size.height - cornerRadius), Offset(size.width, size.height - lineLength - cornerRadius), paintRect);
    canvas.drawLine(Offset(size.width - cornerRadius, size.height), Offset(size.width - lineLength - cornerRadius, size.height), paintRect);

    // Animated sweeping line
    final sweepY = size.height * animationValue;
    final sweepPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(0, sweepY), Offset(size.width, sweepY), sweepPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
