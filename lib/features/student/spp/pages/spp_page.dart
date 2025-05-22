// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../../../shared/widgets/bottom_navbar.dart';
// import '../../../../core/constants/strings.dart';
// import '../../../shared/widgets/loading.dart';
// import '../../../shared/widgets/error_retry.dart';
// import '../provider/spp_provider.dart';

// class SppPage extends StatefulWidget {
//   const SppPage({Key? key}) : super(key: key);

//   @override
//   State<SppPage> createState() => _SppPageState();
// }

// class _SppPageState extends State<SppPage> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => _loadData());
//   }

//   Future<void> _loadData() async {
//     if (!mounted) return;
    
//     final provider = Provider.of<SppProvider>(context, listen: false);
//     await provider.loadSppHistory();
//   }

//   void _showMonthPicker() async {
//     final picked = await showModalBottomSheet<String>(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return ListView(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           children: Strings.SPPMonths.map((bulan) => ListTile(
//             title: Text(bulan, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
//             onTap: () => Navigator.pop(context, bulan),
//           )).toList(),
//         );
//       },
//     );
//     if (picked != null) {
//       final provider = Provider.of<SppProvider>(context, listen: false);
//       provider.setSelectedMonth(picked);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String userRole = 'student';
//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await _loadData();
//         },
//         child: Container(
//           width: double.infinity,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
//               stops: [0.0, 0.8],
//             ),
//           ),
//           child: SafeArea(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header konsisten dengan Dashboard
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Icon(
//                           Icons.credit_card,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Pembayaran SPP',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         GestureDetector(
//                           onTap: _showMonthPicker,
//                           child: Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Consumer<SppProvider>(
//                               builder: (context, provider, _) {
//                                 return Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       provider.selectedMonth ?? Strings.SPPMonthTitle,
//                                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                                     ),
//                                     const Icon(Icons.keyboard_arrow_down),
//                                   ],
//                                 );
//                               }
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         _buildSppHistory(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         currentIndex: 2,
//         userRole: userRole,
//         context: context,
//       ),
//     );
//   }

//   Widget _buildSppHistory() {
//     return Consumer<SppProvider>(
//       builder: (context, provider, _) {
//         final isLoading = provider.isLoading;
//         final error = provider.error;
//         final history = provider.sppHistory;

//         if (isLoading) {
//           return const Expanded(
//             child: Center(
//               child: DefaultLoading(),
//             ),
//           );
//         }

//         if (error != null) {
//           return Expanded(
//             child: ErrorRetry(
//               message: 'Gagal memuat data SPP: $error',
//               onRetry: _loadData,
//             ),
//           );
//         }

//         if (history.isEmpty) {
//           return const Expanded(
//             child: Center(
//               child: Text(
//                 'Tidak ada data pembayaran SPP.',
//                 style: TextStyle(
//                   color: Colors.grey,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           );
//         }

//         return Expanded(
//           child: Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF2196F3),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(12),
//                       topRight: Radius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     'Riwayat Pembayaran SPP',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(0),
//                     itemCount: history.length,
//                     itemBuilder: (context, index) {
//                       final item = history[index];
//                       return Container(
//                         decoration: BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(
//                               color: Colors.grey.shade200,
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: ListTile(
//                           title: Text(
//                             item.month,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           subtitle: Text('Rp ${item.amount}'),
//                           trailing: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: item.status == 'Lunas'
//                                   ? Colors.green.shade50
//                                   : Colors.red.shade50,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               item.status,
//                               style: TextStyle(
//                                 color: item.status == 'Lunas'
//                                     ? Colors.green
//                                     : Colors.red,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           onTap: () {
//                             // Navigate to detail page
//                             final id = item.id ?? 0;
//                             context.go('/student/spp/detail/$id');
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// } 