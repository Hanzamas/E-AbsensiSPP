import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../provider/student_attendance_provider.dart';

class StudentQrScanPage extends StatefulWidget {
  const StudentQrScanPage({Key? key}) : super(key: key);

  @override
  _StudentQrScanPageState createState() => _StudentQrScanPageState();
}

class _StudentQrScanPageState extends State<StudentQrScanPage> {
  final int _selectedIndex = 1;
  final String userRole = 'siswa';
  final MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  double _zoom = 1.0;
  bool _isScanned = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // ✅ IMPROVED: Keep original logic with better error handling
  Future<void> _processBarcode(String code) async {
    if (_isScanned || _isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _isScanned = true;
    });
    
    // Hentikan kamera sementara
    cameraController.stop();
    
    try {
      final provider = Provider.of<StudentAttendanceProvider>(context, listen: false);
      
      // ✅ KEEP: Use original submitAttendance method (SUDAH PERFECT)
      final success = await provider.submitAttendance(code);
      
      if (success && mounted) {
        final data = provider.getSubmissionData();
        
        // ✅ KEEP: Navigate to success page with data (SUDAH BAGUS)
        context.go('/student/attendance/success', extra: {
          'subject': data?['subject'] ?? data?['mapel'] ?? 'Mata Pelajaran',
          'date': data?['date'] ?? data?['tanggal'] ?? _formatDate(DateTime.now()),
          'time': data?['time'] ?? data?['waktu_scan'] ?? _formatTime(DateTime.now()),
          'status': data?['status'] ?? 'Hadir',
        });
        return;
      }
      
      // ✅ IMPROVED: Better error handling
      if (mounted) {
        final errorMessage = provider.error ?? 'QR Code tidak valid atau sudah pernah digunakan';
        
        _showErrorMessage(errorMessage);
        
        // Reset dan restart camera setelah delay
        await Future.delayed(const Duration(milliseconds: 1500));
        _resetScanning();
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Terjadi kesalahan: $e');
        
        await Future.delayed(const Duration(milliseconds: 1500));
        _resetScanning();
      }
    }
  }

  // ✅ NEW: Better error message display
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  // ✅ KEEP: Reset scanning state (SUDAH BAGUS)
  void _resetScanning() {
    if (mounted) {
      setState(() {
        _isScanned = false;
        _isProcessing = false;
      });
      cameraController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/student/attendance'),
        ),
        title: const Text(
          'Scan QR Code', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ✅ KEEP: Camera view (PERFECT)
          MobileScanner(
            controller: cameraController,
            fit: BoxFit.cover,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final code = barcode.rawValue;
                if (code != null && !_isProcessing) {
                  _processBarcode(code);
                  break;
                }
              }
            },
          ),
          
          // ✅ IMPROVED: Better overlay design
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          
          // ✅ IMPROVED: Better UI Controls
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 40),
              
              // ✅ IMPROVED: Top controls with better design
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: ValueListenableBuilder<TorchState>(
                          valueListenable: cameraController.torchState,
                          builder: (context, state, _) {
                            return Icon(
                              state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                              color: state == TorchState.on ? Colors.yellow : Colors.white,
                              size: 24,
                            );
                          },
                        ),
                        onPressed: _isProcessing ? null : () => cameraController.toggleTorch(),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 24),
                        onPressed: _isProcessing ? null : () => cameraController.switchCamera(),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // ✅ IMPROVED: Scanning area with animation
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isProcessing 
                                ? Colors.orange 
                                : Colors.white,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: (_isProcessing ? Colors.orange : Colors.white).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: _isProcessing
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 3,
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        'Memproses QR Code...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Mohon tunggu sebentar',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(21),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // ✅ IMPROVED: Instruction text with better design
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isProcessing ? Icons.hourglass_top : Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isProcessing
                          ? 'Sedang memproses QR Code...'
                          : 'Arahkan kamera ke QR Code',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!_isProcessing) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Pastikan QR Code terlihat jelas dalam frame',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // ✅ IMPROVED: Zoom slider with better design
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.zoom_out, color: Colors.white, size: 20),
                    Expanded(
                      child: Slider(
                        value: _zoom,
                        min: 1.0,
                        max: 5.0,
                        divisions: 20,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.white38,
                        onChanged: _isProcessing ? null : (value) {
                          setState(() => _zoom = value);
                        },
                        onChangeEnd: _isProcessing ? null : (value) {
                          cameraController.setZoomScale(value);
                        },
                      ),
                    ),
                    const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        userRole: userRole,
        context: context,
      ),
    );
  }

  // ✅ KEEP: Helper methods (PERFECT)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}