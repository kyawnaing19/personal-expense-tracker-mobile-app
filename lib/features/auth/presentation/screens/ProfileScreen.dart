import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // User Avatar & Name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF7C3AED),
                      child: const Icon(Icons.person, size: 55, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Moe Pa Pa Aung",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "moepapaaung@ucstt.edu.mm",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Settings Option Menu Placeholder
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    _buildMenuTile(Icons.account_balance_wallet_outlined, "My Wallets"),
                    const Divider(height: 1),
                    _buildMenuTile(Icons.notifications_none_rounded, "Notifications"),
                    const Divider(height: 1),
                    _buildMenuTile(Icons.lock_outline_rounded, "Security"),
                    const Divider(height: 1),
                    _buildMenuTile(Icons.help_outline_rounded, "Help & Support"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF7C3AED)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}