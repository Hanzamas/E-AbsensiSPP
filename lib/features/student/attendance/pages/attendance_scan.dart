import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../../../../core/constants/strings.dart';

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
  bool _isScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _processBarcode(String code) {
    if (_isScanned) return;
    _isScanned = true;
    
    // Tampilkan snackbar bahwa scan berhasil
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Absensi berhasil: $code'))
    );
    
    // Hentikan kamera
    cameraController.stop();
    
    // Navigasi ke halaman success dengan data
    context.go('/student/attendance/success', extra: {
      'subject': 'Matematika',
      'date': '15/10/2023',
      'time': '08:30',
      'status': 'Hadir',
    });
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
        title: const Text(Strings.AttendanceScanTitle, style: TextStyle(color: Colors.white)),
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
                      IconButton(
                        icon: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  Strings.InstructionScan,
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
                        value: zoom,
                        min: 1.0,
                        max: 3.0,
                        divisions: 20,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.white54,
                        onChanged: (value) {
                          setState(() {
                            zoom = value;
                            cameraController.setZoomScale(zoom);
                          });
                        },
                      ),
                    ),
                    const Icon(Icons.add, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Camera icon purely decorative
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 36,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 32),
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
