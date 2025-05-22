// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../provider/profile_provider.dart';

// class AccountEditPage extends StatefulWidget {
//   final String userRole;
  
//   const AccountEditPage({Key? key, required this.userRole}) : super(key: key);

//   @override
//   State<AccountEditPage> createState() => _AccountEditPageState();
// }

// class _AccountEditPageState extends State<AccountEditPage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _oldPasswordController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     Future.microtask(() => _loadData());
//   }

//   Future<void> _loadData() async {
//     if (!mounted) return;
    
//     final provider = Provider.of<ProfileProvider>(context, listen: false);
//     await provider.loadProfile();
    
//     setState(() {
//       _usernameController.text = provider.profileData?['username'] ?? '';
//       _emailController.text = provider.profileData?['email'] ?? '';
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _usernameController.dispose();
//     _emailController.dispose();
//     _oldPasswordController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _updateAccount(BuildContext context, ProfileProvider provider) async {
//     if (_usernameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Username tidak boleh kosong'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (_emailController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Email tidak boleh kosong'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final result = await provider.updateAccount(
//       username: _usernameController.text.trim(),
//       email: _emailController.text.trim(),
//     );

//     if (!mounted) return;

//     if (result) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Akun berhasil diperbarui'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(provider.error ?? 'Gagal memperbarui akun'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _updatePassword(BuildContext context, ProfileProvider provider) async {
//     if (_oldPasswordController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Password lama tidak boleh kosong'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (_newPasswordController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Password baru tidak boleh kosong'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (_newPasswordController.text != _confirmPasswordController.text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Konfirmasi password tidak sesuai'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final result = await provider.updatePassword(
//       oldPassword: _oldPasswordController.text,
//       newPassword: _newPasswordController.text,
//       confirmPassword: _confirmPasswordController.text,
//     );

//     if (!mounted) return;

//     if (result) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Password berhasil diperbarui'),
//           backgroundColor: Colors.green,
//         ),
//       );
      
//       // Reset form setelah berhasil
//       _oldPasswordController.clear();
//       _newPasswordController.clear();
//       _confirmPasswordController.clear();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(provider.error ?? 'Gagal memperbarui password'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Akun', style: TextStyle(color: Colors.white)),
//         backgroundColor: const Color(0xFF2196F3),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => context.go('/${widget.userRole}/profile'),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           tabs: const [
//             Tab(text: 'Profil Akun'),
//             Tab(text: 'Password'),
//           ],
//         ),
//       ),
//       body: Consumer<ProfileProvider>(
//         builder: (context, provider, child) {
//           final isLoading = provider.isLoading;
          
//           return SafeArea(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 // Tab Edit Profil Akun
//                 SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _usernameController,
//                         decoration: const InputDecoration(
//                           labelText: 'Username',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.person),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _emailController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: const InputDecoration(
//                           labelText: 'Email',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.email),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       ElevatedButton(
//                         onPressed: isLoading
//                             ? null
//                             : () => _updateAccount(context, provider),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF2196F3),
//                           minimumSize: const Size(double.infinity, 48),
//                         ),
//                         child: isLoading
//                             ? const CircularProgressIndicator(color: Colors.white)
//                             : const Text(
//                                 'Simpan Perubahan',
//                                 style: TextStyle(fontSize: 16, color: Colors.white),
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 // Tab Password
//                 SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _oldPasswordController,
//                         obscureText: true,
//                         decoration: const InputDecoration(
//                           labelText: 'Password Lama',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.lock),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _newPasswordController,
//                         obscureText: true,
//                         decoration: const InputDecoration(
//                           labelText: 'Password Baru',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.lock_outline),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _confirmPasswordController,
//                         obscureText: true,
//                         decoration: const InputDecoration(
//                           labelText: 'Konfirmasi Password Baru',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.lock_outline),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       ElevatedButton(
//                         onPressed: isLoading
//                             ? null
//                             : () => _updatePassword(context, provider),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF2196F3),
//                           minimumSize: const Size(double.infinity, 48),
//                         ),
//                         child: isLoading
//                             ? const CircularProgressIndicator(color: Colors.white)
//                             : const Text(
//                                 'Ubah Password',
//                                 style: TextStyle(fontSize: 16, color: Colors.white),
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// } 