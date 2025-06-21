import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart'; // ✅ Use gal instead of image_gallery_saver
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../data/models/spp_model.dart';

class QrisPaymentWidget extends StatefulWidget {
  final QrisPaymentModel qris;
  final SppBillModel bill;
  final VoidCallback onClose;
  final Duration timeRemaining;

  const QrisPaymentWidget({
    Key? key,
    required this.qris,
    required this.bill,
    required this.onClose,
    required this.timeRemaining,
  }) : super(key: key);

  @override
  State<QrisPaymentWidget> createState() => _QrisPaymentWidgetState();
}

class _QrisPaymentWidgetState extends State<QrisPaymentWidget> {
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPaymentInfo(),
                  const SizedBox(height: 20),
                  _buildQrCode(),
                  const SizedBox(height: 20),
                  _buildTimer(),
                  const SizedBox(height: 20),
                  _buildActions(),
                  const SizedBox(height: 20),
                  _buildInstructions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2196F3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pembayaran QRIS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Pembayaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Periode', '${widget.bill.monthName} ${widget.bill.tahun}'),
          _buildDetailRow('Nominal SPP', _formatCurrency(widget.bill.nominal)),
          if (widget.bill.denda > 0)
            _buildDetailRow('Denda', _formatCurrency(widget.bill.denda)),
          const Divider(),
          _buildDetailRow(
            'Total Bayar', 
            _formatCurrency(widget.bill.totalAmount),
            isTotal: true,
          ),
          _buildDetailRow('Referensi', widget.qris.referenceId),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 14 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.blue.shade800 : Colors.blue.shade700,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 14 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? Colors.blue.shade800 : Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildQrCode() {
  return Screenshot(
    controller: _screenshotController,
    child: Container(
      constraints: const BoxConstraints(
        maxWidth: 300,
        minWidth: 280,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20), // ✅ ADD: Margin
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Scan QR Code untuk Pembayaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // ✅ FIXED: AspectRatio untuk memastikan square
          AspectRatio(
            aspectRatio: 1.0, // Perfect square
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 200,
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: QrImageView(
                  data: widget.qris.qrString,
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  gapless: true,
                  semanticsLabel: 'QR Code SPP',
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          Text(
            widget.qris.referenceId,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTimer() {
    final minutes = widget.timeRemaining.inMinutes;
    final seconds = widget.timeRemaining.inSeconds % 60;
    final isExpiring = widget.timeRemaining.inMinutes < 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExpiring ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isExpiring ? Colors.red.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: isExpiring ? Colors.red.shade600 : Colors.orange.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Kode akan kedaluwarsa dalam: ',
            style: TextStyle(
              fontSize: 12,
              color: isExpiring ? Colors.red.shade700 : Colors.orange.shade700,
            ),
          ),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isExpiring ? Colors.red.shade800 : Colors.orange.shade800,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveQrCode,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Simpan QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        // const SizedBox(height: 8),
        // SizedBox(
        //   width: double.infinity,
        //   child: OutlinedButton.icon(
        //     onPressed: _copyQrString,
        //     icon: const Icon(Icons.copy, size: 18),
        //     label: const Text('Salin Kode QR'),
        //     style: OutlinedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 12),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 8),
              Text(
                'Cara Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionStep('1', 'Buka aplikasi e-wallet (DANA, OVO, GoPay, dll)'),
          _buildInstructionStep('2', 'Pilih menu "Scan QR" atau "Bayar"'),
          _buildInstructionStep('3', 'Scan QR Code di atas'),
          _buildInstructionStep('4', 'Konfirmasi pembayaran'),
          _buildInstructionStep('5', 'Pembayaran akan dikonfirmasi otomatis'),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ENHANCED: Save QR code method with proper orientation
  Future<void> _saveQrCode() async {
    try {
      // Show loading
      _showSnackBar('Menyimpan QR Code...', isError: false);
      
      // Check if we have permission
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final hasPermission = await Gal.requestAccess();
        if (!hasPermission) {
          _showSnackBar('Permission ditolak', isError: true);
          return;
        }
      }

      // ✅ Wait a bit for UI to settle
      await Future.delayed(const Duration(milliseconds: 300));

      // Capture screenshot with proper format
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100), // ✅ ADD: Delay for rendering
        pixelRatio: 2.0, // ✅ ADD: Higher quality
      );
      
      if (imageBytes == null) {
        _showSnackBar('Gagal mengambil screenshot', isError: true);
        return;
      }

      // ✅ Generate timestamp for unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'qris_spp_${widget.qris.referenceId}_$timestamp';

      // Save to gallery using gal package
      await Gal.putImageBytes(
        imageBytes,
        name: filename,
      );

      _showSnackBar('QR Code berhasil disimpan ke galeri');
    } catch (e) {
      debugPrint('Error saving QR Code: $e');
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _copyQrString() async {
    await Clipboard.setData(ClipboardData(text: widget.qris.qrString));
    _showSnackBar('Kode QR berhasil disalin');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }
}