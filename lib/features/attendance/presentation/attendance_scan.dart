import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class AttendanceQr extends StatefulWidget {
  const AttendanceQr({Key? key}) : super(key: key);

  @override
  _AttendanceqrState createState() => _AttendanceqrState();
}

class _AttendanceqrState extends State<AttendanceQr> {
  final MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  double zoom = 1.0;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _processBarcode(String code) {
    debugPrint('QR Code detected: $code');
    // TODO: implementasikan logic absensi di sini
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Absensi berhasil: $code')));
    // Setelah pemrosesan, bisa stop kamera atau kembali
    cameraController.stop();
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
          onPressed: () {
            context.go('/attendance');
          },
        ),
        title: const Text('Scan QR', style: TextStyle(color: Colors.white)),
        centerTitle: true,
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
                  break; // hanya process kode pertama
                }
              }
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              // Top controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.white),
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
                    icon: const Icon(Icons.cameraswitch, color: Colors.white),
                    onPressed: () => cameraController.switchCamera(),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              // Instruction
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Pindai Kode QR untuk absensi',
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
              // Capture button
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: GestureDetector(
                  onTap: () {
                    // Manual capture or focus
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // "Absensi"
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'SPP'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (idx) {
          // TODO: Handle bottom nav tap
        },
      ),
    );
  }
}
