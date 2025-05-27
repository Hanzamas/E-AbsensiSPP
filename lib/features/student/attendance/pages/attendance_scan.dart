import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/bottom_navbar.dart';
import '../../../../core/constants/feature_strings.dart';
import '../provider/attendance_provider.dart';

class AttendanceQr extends StatefulWidget {
  const AttendanceQr({Key? key}) : super(key: key);

  @override
  _AttendanceQrState createState() => _AttendanceQrState();
}

class _AttendanceQrState extends State<AttendanceQr> {
  final int _selectedIndex = 1;
  final String userRole = 'siswa';
  final MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  double zoom = 1.0;
  double _zoom = 1.0;
  bool _isScanned = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(String code) async {
    if (_isScanned || _isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    // Hentikan kamera
    cameraController.stop();
    
    try {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      final success = await provider.submitAttendance(code);
      
      if (success) {
        final data = provider.getSubmissionData();
        if (data != null && mounted) {
          context.go('/student/attendance/success', extra: {
            'subject': data['subject'] ?? 'Tidak diketahui',
            'date': data['date'] ?? '-',
            'time': data['time'] ?? '-',
            'status': data['status'] ?? 'Hadir',
          });
        } else {
          // Fallback jika data tidak ada
          context.go('/student/attendance/success', extra: {
            'subject': 'Mata Pelajaran',
            'date': DateTime.now().toString().substring(0, 10),
            'time': DateTime.now().toString().substring(11, 16),
            'status': 'Hadir',
          });
        }
      } else {
        // Jika gagal, tampilkan pesan error dan buka kamera lagi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal melakukan absensi: ${provider.error}'))
          );
          setState(() {
            _isScanned = false;
            _isProcessing = false;
          });
          cameraController.start();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'))
        );
        setState(() {
          _isScanned = false;
          _isProcessing = false;
        });
        cameraController.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/student/attendance');
          },
        ),
        title: const Text(FeatureStrings.attendanceScanTitle, style: TextStyle(color: Colors.white)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            fit: BoxFit.cover,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final code = barcode.rawValue;
                if (code != null) {
                  _processBarcode(code);
                  break;
                }
              }
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 62),
              // Top controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // IconButton(
                      //   icon: const Icon(
                      //     Icons.photo_library,
                      //     color: Colors.white,
                      //   ),
                      //   onPressed: () {},
                      // ),
                      IconButton(
                        icon: ValueListenableBuilder<TorchState>(
                          valueListenable: cameraController.torchState,
                          builder: (context, state, _) {
                            return Icon(
                              state == TorchState.on
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              color: Colors.white,
                            );
                          },
                        ),
                        onPressed: () => cameraController.toggleTorch(),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.cameraswitch,
                          color: Colors.white,
                        ),
                        onPressed: () => cameraController.switchCamera(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ), // ← ditambah
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  FeatureStrings.instructionScan,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Zoom slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    const Icon(Icons.remove, color: Colors.white),
                     Expanded(
                      child: Slider(
                        value: _zoom,
                        min: 1.0,
                        max: 8.0,
                        divisions: 20,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.white54,
                        onChanged: (value) {
                          setState(() {
                            _zoom = value;
                          });
                        },
                        onChangeEnd: (value) {
                          setState(() {
                            _zoom = value;
                          });
                          cameraController.setZoomScale(_zoom);
                        },
                      ),
                    ),
                    const Icon(Icons.add, color: Colors.white),
                  ],
                ),
              ),
              // const SizedBox(height: 24),
              // // Camera icon purely decorative
              // CircleAvatar(
              //   backgroundColor: Colors.blue,
              //   radius: 36,
              //   child: const Icon(
              //     Icons.camera_alt,
              //     color: Colors.white,
              //     size: 32,
              //   ),
              // ),
              const SizedBox(height: 62),
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
}
