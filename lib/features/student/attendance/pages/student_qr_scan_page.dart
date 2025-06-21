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

class _StudentQrScanPageState extends State<StudentQrScanPage>
    with TickerProviderStateMixin {
  final int _selectedIndex = 1;
  final String userRole = 'siswa';
  
  late MobileScannerController cameraController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  double _zoom = 1.0;
  bool _isScanned = false;
  bool _isProcessing = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    
    // Initialize camera controller
    cameraController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
    );
    
    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(String code) async {
    // Prevent duplicate processing
    if (_isScanned || _isProcessing || code == _lastScannedCode) return;
    
    _lastScannedCode = code;
    
    setState(() {
      _isProcessing = true;
      _isScanned = true;
    });
    
    // Stop camera while processing
    await cameraController.stop();
    
    try {
      final provider = Provider.of<StudentAttendanceProvider>(context, listen: false);
      
      print('🔍 Processing QR code: $code');
      
      // ✅ FIXED: Use scanQRCode method with qr_token
      final success = await provider.scanQRCode(code);
      
      if (success && mounted) {
        final data = provider.getSubmissionData();
        
        print('🔍 Scan successful, data: $data');
        
        // Navigate to success page
        context.go('/student/attendance/success', extra: {
          'subject': data?['mapel'] ?? 'Mata Pelajaran',
          'date': _formatDate(DateTime.now()),
          'time': _formatTime(DateTime.now()),
          'status': data?['status'] ?? 'Hadir',
        });
        return;
      }
      
      // Handle error
      if (mounted) {
        final errorMessage = provider.error ?? 'QR Code tidak valid';
        _showErrorMessage(_getReadableError(errorMessage));
        
        await Future.delayed(const Duration(seconds: 2));
        _resetScanning();
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Terjadi kesalahan: ${_getReadableError(e.toString())}');
        
        await Future.delayed(const Duration(seconds: 2));
        _resetScanning();
      }
    }
  }

  String _getReadableError(String error) {
    if (error.contains('qr_token is required')) {
      return 'QR Code tidak valid atau rusak';
    } else if (error.contains('already used')) {
      return 'QR Code sudah pernah digunakan';
    } else if (error.contains('expired')) {
      return 'QR Code sudah kadaluarsa';
    } else if (error.contains('not found')) {
      return 'QR Code tidak ditemukan';
    } else if (error.contains('connection')) {
      return 'Tidak ada koneksi internet';
    } else if (error.contains('timeout')) {
      return 'Koneksi timeout, coba lagi';
    }
    return 'QR Code tidak valid';
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    
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
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _resetScanning() {
    if (!mounted) return;
    
    setState(() {
      _isScanned = false;
      _isProcessing = false;
      _lastScannedCode = null;
    });
    
    cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          // Camera view
          MobileScanner(
            controller: cameraController,
            fit: BoxFit.cover,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final code = barcode.rawValue;
                if (code != null && code.isNotEmpty) {
                  _processBarcode(code);
                  break;
                }
              }
            },
          ),
          
          // Overlay
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
          
          // UI Controls
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 40),
              
              // Top controls
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
                      // Flash toggle
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
                      
                      // Camera switch
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 24),
                        onPressed: _isProcessing ? null : () => cameraController.switchCamera(),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Scanning area
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isProcessing ? Colors.orange : Colors.white,
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(21),
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
                              : Stack(
                                  children: [
                                    // Scanning line animation
                                    AnimatedBuilder(
                                      animation: _animation,
                                      builder: (context, child) {
                                        return Positioned(
                                          top: _animation.value * 250,
                                          left: 20,
                                          right: 20,
                                          child: Container(
                                            height: 2,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.red.withOpacity(0.5),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    
                                    // Corner indicators
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: Colors.white, width: 3),
                                            left: BorderSide(color: Colors.white, width: 3),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: Colors.white, width: 3),
                                            right: BorderSide(color: Colors.white, width: 3),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 10,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.white, width: 3),
                                            left: BorderSide(color: Colors.white, width: 3),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.white, width: 3),
                                            right: BorderSide(color: Colors.white, width: 3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Instruction text
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
              
              // Zoom slider
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

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}