// lib/features/users/widgets/filter_and_sort_widget.dart
import 'package:flutter/material.dart';

// Enum untuk mendefinisikan tipe urutan
enum SortOrder { az, za }

class FilterAndSortWidget extends StatefulWidget {
  final Function(String query, SortOrder order) onApplyFilter;
  final VoidCallback onResetFilter;

  const FilterAndSortWidget({
    Key? key,
    required this.onApplyFilter,
    required this.onResetFilter,
  }) : super(key: key);

  @override
  _FilterAndSortWidgetState createState() => _FilterAndSortWidgetState();
}

class _FilterAndSortWidgetState extends State<FilterAndSortWidget> {
  final _nameController = TextEditingController();
  SortOrder _selectedOrder = SortOrder.az;
  bool _isExpanded = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _apply() {
    widget.onApplyFilter(_nameController.text, _selectedOrder);
  }

  void _reset() {
    _nameController.clear();
    setState(() {
      _selectedOrder = SortOrder.az;
    });
    widget.onResetFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Filter & Urutkan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.filter_list, color: Color(0xFF2196F3)),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Cari berdasarkan Nama',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Urutkan berdasarkan Abjad',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              () =>
                                  setState(() => _selectedOrder = SortOrder.az),
                          icon: const Icon(Icons.sort_by_alpha),
                          label: const Text('A-Z'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                _selectedOrder == SortOrder.az
                                    ? const Color(0xFF2196F3).withOpacity(0.1)
                                    : Colors.transparent,
                            side: BorderSide(
                              color:
                                  _selectedOrder == SortOrder.az
                                      ? const Color(0xFF2196F3)
                                      : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              () =>
                                  setState(() => _selectedOrder = SortOrder.za),
                          icon: const Icon(Icons.sort_by_alpha),
                          label: const Text('Z-A'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                _selectedOrder == SortOrder.za
                                    ? const Color(0xFF2196F3).withOpacity(0.1)
                                    : Colors.transparent,
                            side: BorderSide(
                              color:
                                  _selectedOrder == SortOrder.za
                                      ? const Color(0xFF2196F3)
                                      : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _apply,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Terapkan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
