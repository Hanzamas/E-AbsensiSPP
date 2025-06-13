import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../provider/student_spp_provider.dart';
import '../data/models/spp_model.dart';
import 'package:flutter/services.dart';

class SppHistoryTab extends StatefulWidget {
  final StudentSppProvider provider;

  const SppHistoryTab({Key? key, required this.provider}) : super(key: key);

  @override
  State<SppHistoryTab> createState() => _SppHistoryTabState();
}

class _SppHistoryTabState extends State<SppHistoryTab> {
  bool _isFilterExpanded = false;
  String? _selectedYear;
  String? _selectedStatus;
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterSection(),
        Expanded(
          child: widget.provider.isLoadingHistory
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                  ),
                )
              : widget.provider.error != null
                  ? _buildErrorState()
                  : _buildContent(),
        ),
      ],
    );
  }

  // ✅ Filter Section - Scrollable & Expandable
  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Filter & Export',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Icon(
                  _isFilterExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),
          
          // Expandable Filter Content
          if (_isFilterExpanded) ...[
            const SizedBox(height: 16),
            
            // Scrollable Filter Area
            SizedBox(
              height: 250,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Year Filter
                    _buildDropdownField(
                      label: 'Tahun',
                      value: _selectedYear ?? 'Semua Tahun',
                      items: ['Semua Tahun', ...(_getAvailableYears())],
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value == 'Semua Tahun' ? null : value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Status Filter
                    _buildDropdownField(
                      label: 'Status',
                      value: _selectedStatus ?? 'Semua Status',
                      items: const ['Semua Status', 'Sukses', 'Pending', 'Gagal'],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value == 'Semua Status' ? null : value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Date Range Filter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rentang Tanggal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _selectDateRange(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDateRange != null
                                        ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                                        : 'Pilih rentang tanggal',
                                    style: TextStyle(
                                      color: _selectedDateRange != null 
                                          ? const Color(0xFF1E293B)
                                          : Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Terapkan Filter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Dropdown Field Helper
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Content Area
  Widget _buildContent() {
    final filteredHistory = _getFilteredHistory();
    
    if (widget.provider.paymentHistory.isEmpty) {
      return _buildEmptyState();
    }
    
    if (filteredHistory.isEmpty) {
      return _buildEmptyFilteredState();
    }

    return RefreshIndicator(
      onRefresh: () => widget.provider.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats
              _buildQuickStats(filteredHistory),
              const SizedBox(height: 16),
              
              // History List
              _buildHistoryList(filteredHistory),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // Quick Stats
  Widget _buildQuickStats(List<PaymentHistoryModel> history) {
    final totalPayments = history.length;
    final successPayments = history.where((p) => p.status.toLowerCase() == 'sukses').length;
    final pendingPayments = history.where((p) => p.status.toLowerCase() == 'pending').length;
    final failedPayments = history.where((p) => p.status.toLowerCase() == 'gagal').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ringkasan Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  totalPayments.toString(),
                  Icons.receipt_long,
                  const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Sukses',
                  successPayments.toString(),
                  Icons.check_circle,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  pendingPayments.toString(),
                  Icons.pending,
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Gagal',
                  failedPayments.toString(),
                  Icons.error,
                  const Color(0xFFE53E3E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Stat Card
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // History List
  Widget _buildHistoryList(List<PaymentHistoryModel> history) {
    return Column(
      children: history.map((payment) => _buildPaymentCard(payment)).toList(),
    );
  }

  // Payment Card
  Widget _buildPaymentCard(PaymentHistoryModel payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showPaymentDetail(payment),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${payment.monthName} ${payment.tahun}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(payment.tanggalBayar),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(payment.status),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Amount & Payment Method
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            _formatCurrency(payment.totalBayar),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Metode',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          payment.metodeBayar,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                if (payment.referenceId.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Ref: ${payment.referenceId}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Status Badge
  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String displayText;

    switch (status.toLowerCase()) {
      case 'sukses':
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        icon = Icons.check_circle;
        displayText = 'SUKSES';
        break;
      case 'pending':
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        icon = Icons.pending;
        displayText = 'PENDING';
        break;
      case 'gagal':
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        icon = Icons.error;
        displayText = 'GAGAL';
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.help_outline;
        displayText = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Payment Detail Modal
  void _showPaymentDetail(PaymentHistoryModel payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Detail Pembayaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildDetailRow('Periode', '${payment.monthName} ${payment.tahun}'),
            _buildDetailRow('Tanggal Bayar', _formatDateTime(payment.tanggalBayar)),
            _buildDetailRow('Total', _formatCurrency(payment.totalBayar)),
            _buildDetailRow('Metode', payment.metodeBayar),
            _buildDetailRow('Status', _getStatusText(payment.status)),
            if (payment.referenceId.isNotEmpty)
              _buildDetailRow('Referensi', payment.referenceId),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _copyReferenceId(payment.referenceId);
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Salin No. Referensi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(': ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Empty States
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Riwayat Pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Riwayat pembayaran SPP akan muncul di sini setelah Anda melakukan pembayaran',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilteredState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada riwayat pembayaran yang sesuai dengan filter yang dipilih',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetFilters,
              child: const Text('Reset Filter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => widget.provider.loadPaymentHistory(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  List<String> _getAvailableYears() {
    final years = widget.provider.paymentHistory
        .map((payment) => payment.tahun)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<PaymentHistoryModel> _getFilteredHistory() {
    List<PaymentHistoryModel> filtered = widget.provider.paymentHistory;

    if (_selectedYear != null) {
      filtered = filtered.where((p) => p.tahun == _selectedYear).toList();
    }

    if (_selectedStatus != null) {
      filtered = filtered.where((p) => 
        p.status.toLowerCase() == _selectedStatus!.toLowerCase()
      ).toList();
    }

    if (_selectedDateRange != null) {
      filtered = filtered.where((p) {
        return p.tanggalBayar.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
               p.tanggalBayar.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _applyFilters() {
    setState(() {});
  }

  void _resetFilters() {
    setState(() {
      _selectedYear = null;
      _selectedStatus = null;
      _selectedDateRange = null;
    });
  }

  void _copyReferenceId(String referenceId) {
    Clipboard.setData(ClipboardData(text: referenceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('No. referensi berhasil disalin'),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'sukses': return 'Sukses';
      case 'pending': return 'Pending';
      case 'gagal': return 'Gagal';
      default: return status.toUpperCase();
    }
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}