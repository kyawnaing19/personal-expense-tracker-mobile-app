// import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
// import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
// import 'package:expense_tracker/features/auth/presentation/screens/MainNavigationScreen.dart';
// import 'package:expense_tracker/features/auth/presentation/screens/budget_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:share_plus/share_plus.dart';
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({Key? key}) : super(key: key);

//   String _getInitials(String name) {
//     if (name.isEmpty) return 'U';
//     return name[0].toUpperCase();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, state) {
//         String userName = "User";
//         String userEmail = "email@example.com";

//         if (state is AuthAuthenticated) {
//           userName = state.user['name'] ?? "User";
//           userEmail = state.user['email'] ?? "email@example.com";
//         }

//         return Scaffold(
//           backgroundColor: const Color(0xFFEDE7F6),
//           body: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 30,
//                         backgroundColor: const Color(0xFF6200EE),
//                         child: Text(
//                           _getInitials(userName),
//                           style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       const SizedBox(width: 15),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                             Text(userEmail, style: TextStyle(color: Colors.grey[700])),
//                           ],
//                         ),
//                       ),
                     
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   Container(
//                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
//                     child: Column(
//                       children: [
//                         _buildMenuTile(context, Icons.thumb_up_alt_outlined, "Recommend To Friends", onTap: () async {const String message = "This app is really great to use, give it a try!";
//                         await Share.share(message);}),
//                         _buildMenuTile(context, Icons.grid_view_rounded, "Categories", onTap: () {
//     // Navigator.push(context, ...); // ဒါကို ဖြုတ်ပါ
    
//     // Bottom Nav Bar index ကို 2 (Categories) သို့ပြောင်းရန်
//     final mainNav = context.findAncestorStateOfType<MainNavigationScreenState>();
//     if (mainNav != null) {
//       mainNav.onTabTapped(2); 
//     }
//   },),
//                         _buildMenuTile(context, Icons.account_balance_wallet_outlined, "Budget", onTap: () {  Navigator.push(context, MaterialPageRoute(builder: (_) => BudgetScreen())); }),
//                         _buildMenuTile(context, Icons.task_alt_outlined, "Recurring Transactions", onTap: () { /* Navigator.push(context, MaterialPageRoute(builder: (_) => RecurringTransactionsScreen())); */ }),
//                         _buildMenuTile(context, Icons.groups_outlined, "Create New Group", onTap: () { /* Navigator.push(context, MaterialPageRoute(builder: (_) => CreateGroupScreen())); */ }),
//                         _buildMenuTile(context, Icons.logout_outlined, "Logout", isLogout: true, onTap: () {
//                           context.read<AuthBloc>().add(LogoutRequested());
//                         }),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMenuTile(BuildContext context, IconData icon, String title, {bool isLogout = false, required VoidCallback onTap}) {
//     return Column(
//       children: [
//         ListTile(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
//           leading: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(color: const Color(0xFFEDE7F6), borderRadius: BorderRadius.circular(10)),
//             child: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF6200EE), size: 24),
//           ),
//           title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
//           onTap: onTap,
//         ),
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20.0),
//           child: Divider(height: 1, thickness: 0.5, color: Colors.grey),
//         ),
//       ],
//     );
//   }
// }


import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/screens/MainNavigationScreen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = "User";
        String userEmail = "email@example.com";
        String? userAvatar;

        if (state is AuthAuthenticated) {
          userName = state.user['name'] ?? "User";
          userEmail = state.user['email'] ?? "email@example.com";
          userAvatar = state.user['avatar']; // API ကပြန်ပေးတဲ့ avatar URL
        }

        return Scaffold(
          backgroundColor: const Color(0xFFEDE7F6),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF6200EE),
                        backgroundImage: (userAvatar != null && userAvatar.isNotEmpty)
                            ? NetworkImage(userAvatar)
                            : null,
                        // avatar image ရှိရင် ပုံပြပါမယ်၊ မရှိ (သို့) load မရရင် initials ကို child မှာပြပါမယ်
                        onBackgroundImageError: (userAvatar != null && userAvatar.isNotEmpty)
                            ? (exception, stackTrace) {
                                // image load မရရင် error ကို silently handle လုပ်ပြီး initials ပြန်ပြပါမယ်
                              }
                            : null,
                        child: (userAvatar == null || userAvatar.isEmpty)
                            ? Text(
                                _getInitials(userName),
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(userEmail, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      ),
                     
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        _buildMenuTile(context, Icons.thumb_up_alt_outlined, "Recommend To Friends", onTap: () async {const String message = "This app is really great to use, give it a try!";
                        await Share.share(message);}),
                        _buildMenuTile(context, Icons.grid_view_rounded, "Categories", onTap: () {
    // Navigator.push(context, ...); // ဒါကို ဖြုတ်ပါ
    
    // Bottom Nav Bar index ကို 2 (Categories) သို့ပြောင်းရန်
    final mainNav = context.findAncestorStateOfType<MainNavigationScreenState>();
    if (mainNav != null) {
      mainNav.onTabTapped(2); 
    }
  },),
                        _buildMenuTile(context, Icons.account_balance_wallet_outlined, "Budget", onTap: () {  Navigator.push(context, MaterialPageRoute(builder: (_) => BudgetScreen())); }),
                        _buildMenuTile(context, Icons.task_alt_outlined, "Recurring Transactions", onTap: () { /* Navigator.push(context, MaterialPageRoute(builder: (_) => RecurringTransactionsScreen())); */ }),
                        _buildMenuTile(context, Icons.groups_outlined, "Create New Group", onTap: () { /* Navigator.push(context, MaterialPageRoute(builder: (_) => CreateGroupScreen())); */ }),
                        _buildMenuTile(context, Icons.logout_outlined, "Logout", isLogout: true, onTap: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, {bool isLogout = false, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFEDE7F6), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF6200EE), size: 24),
          ),
          title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
          onTap: onTap,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Divider(height: 1, thickness: 0.5, color: Colors.grey),
        ),
      ],
    );
  }
}