import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/features/Scan/Provider/scan_receipt_provider.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';

/// Screen 1 — Camera preview + capture + OCR.
/// Mirrors the Figma mockup: receipt frame overlay, corner brackets, scan line,
/// and a loading overlay with animated progress while OCR runs.
class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen>
    with TickerProviderStateMixin {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _cameraReady = false;
  String? _initError;

  // Animated scan line
  late final AnimationController _scanLineCtrl;
  late final Animation<double>   _scanLineAnim;
  // Fake progress for UX while OCR runs
  late final AnimationController _progressCtrl;
  late final Animation<double>   _progressAnim;

  @override
  void initState() {
    super.initState();

    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut),
    );

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0.85).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _initError = 'No camera found on this device.');
        return;
      }
      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (e) {
      if (mounted) setState(() => _initError = 'Camera error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanLineCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  Future<void> _captureAndScan() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final xFile    = await _controller!.takePicture();
      final imageFile = File(xFile.path);
      _progressCtrl.forward(from: 0);
      await ref.read(scanReceiptProvider.notifier).scanImage(imageFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker     = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _progressCtrl.forward(from: 0);
        await ref
            .read(scanReceiptProvider.notifier)
            .scanImage(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery selection failed: $e')),
        );
      }
    }
  }

  void _handleStateChange(ScanReceiptState state) {
    if (state is ScanParsed) {
      _progressCtrl.stop();
      if (mounted) {
        context.push('/scan-result', extra: state.data);
        ref.read(scanReceiptProvider.notifier).reset();
      }
    } else if (state is ScanError) {
      _progressCtrl.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.expense,
          ),
        );
        ref.read(scanReceiptProvider.notifier).reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanReceiptProvider);
    ref.listen(scanReceiptProvider, (_, next) => _handleStateChange(next));
    final isScanning = scanState is ScanScanning;

    return Scaffold(
      // Camera screen is intentionally always-black (overlay on live feed)
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview or error
          if (_initError != null)
            _ErrorPlaceholder(message: _initError!)
          else if (!_cameraReady)
            const Center(
              child: CircularProgressIndicator(color: AppColors.scanAccent),
            )
          else
            CameraPreview(_controller!),

          // Receipt frame overlay
          if (_cameraReady && _initError == null)
            _ReceiptFrameOverlay(scanLineAnim: _scanLineAnim),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TopBarButton(
                    icon: Icons.chevron_left,
                    onTap: () => context.pop(),
                  ),
                  _TopBarButton(
                    icon: Icons.document_scanner_outlined,
                    onTap: null,
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (isScanning) _ScanLoadingOverlay(progressAnim: _progressAnim),

          // Bottom capture & gallery buttons
          if (_cameraReady && !isScanning)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 56),
                  const Spacer(),
                  // Capture button
                  GestureDetector(
                    onTap: _captureAndScan,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.scanAccent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.scanAccent.withValues(alpha: 0.45),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Gallery button
                  GestureDetector(
                    onTap: _pickFromGallery,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black45,
                      ),
                      child: const Icon(
                        Icons.photo_library_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

class _ReceiptFrameOverlay extends StatelessWidget {
  const _ReceiptFrameOverlay({required this.scanLineAnim});
  final Animation<double> scanLineAnim;

  @override
  Widget build(BuildContext context) {
    final size     = MediaQuery.of(context).size;
    const frameW   = 240.0;
    const frameH   = 380.0;
    final frameLeft = (size.width  - frameW) / 2;
    final frameTop  = (size.height - frameH) / 2 - 24;

    return Stack(
      children: [
        // Dark vignette outside frame
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.55),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(color: Colors.transparent),
              Positioned(
                left: frameLeft,
                top: frameTop,
                width: frameW,
                height: frameH,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scan-accent corner brackets
        Positioned(
          left: frameLeft,
          top: frameTop,
          child: _FrameCorners(width: frameW, height: frameH),
        ),

        // Animated scan line
        AnimatedBuilder(
          animation: scanLineAnim,
          builder: (_, __) {
            final lineY = frameTop + 2 + scanLineAnim.value * (frameH - 4);
            return Positioned(
              left: frameLeft + 8,
              top: lineY,
              child: Container(
                width: frameW - 16,
                height: 2.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.scanAccent.withValues(alpha: 0.9),
                      AppColors.scanAccent,
                      AppColors.scanAccent.withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          },
        ),

        // Helper text
        Positioned(
          left: 0,
          right: 0,
          top: frameTop + frameH + 20,
          child: const Text(
            'Place the receipt inside the frame',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FrameCorners extends StatelessWidget {
  const _FrameCorners({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    const corner    = 22.0;
    const thickness = 3.0;
    const color     = AppColors.scanAccent;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(left: 0,  top: 0,    child: _Corner(hDir:  1, vDir:  1, size: corner, thickness: thickness, color: color)),
          Positioned(right: 0, top: 0,    child: _Corner(hDir: -1, vDir:  1, size: corner, thickness: thickness, color: color)),
          Positioned(left: 0,  bottom: 0, child: _Corner(hDir:  1, vDir: -1, size: corner, thickness: thickness, color: color)),
          Positioned(right: 0, bottom: 0, child: _Corner(hDir: -1, vDir: -1, size: corner, thickness: thickness, color: color)),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({
    required this.hDir,
    required this.vDir,
    required this.size,
    required this.thickness,
    required this.color,
  });
  final double hDir, vDir, size, thickness;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          hDir: hDir, vDir: vDir, thickness: thickness, color: color,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({
    required this.hDir,
    required this.vDir,
    required this.thickness,
    required this.color,
  });
  final double hDir, vDir, thickness;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = hDir > 0 ? 0.0 : size.width;
    final y = vDir > 0 ? 0.0 : size.height;

    canvas.drawLine(Offset(x, y), Offset(x + hDir * size.width, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + vDir * size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Loading overlay while OCR runs — themed card over the camera feed.
class _ScanLoadingOverlay extends StatelessWidget {
  const _ScanLoadingOverlay({required this.progressAnim});
  final Animation<double> progressAnim;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          decoration: BoxDecoration(
            // Uses theme surface so it adapts to light/dark mode
            color: context.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              AnimatedBuilder(
                animation: progressAnim,
                builder: (_, __) {
                  final pct = (progressAnim.value * 100).round();
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.scanAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Scanning $pct%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progressAnim.value,
                          minHeight: 8,
                          backgroundColor:
                              context.colors.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.scanAccent,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Reading your receipt…',
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when camera cannot be initialised.
class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white54,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
