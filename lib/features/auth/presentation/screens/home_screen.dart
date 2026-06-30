import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'record_history_screen.dart';
import 'category_screen.dart'; // 🎯 CategoryScreen အတွက် Import

// 🎯 အစ်မရဲ့ Bottom Nav ကုဒ်ထဲက _currentState အတွက် လိုအပ်သော enum ကို သတ်မှတ်ခြင်း
enum CategoryState { view, add, edit }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0; 
  CategoryState _currentState = CategoryState.view; // 🎯 အစ်မရဲ့ State variables
  
  bool _isBalanceVisible = true;
  String _transactionFilter = 'All';
  final String _currentUserName = "Sofia"; 

  // 🎯 Bottom Navigation Bar နှိပ်လျှင် ချိတ်ဆက်ပြသပေးမည့် မျက်နှာပြင်များ
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomeDashboard(),                                                         // Index 0: Home UI
      const Center(child: Text("Pie Chart / Analytics Screen", style: TextStyle(fontSize: 18))), // Index 1: Analytics
      const CategoryScreen(),                                                        // Index 2: Category UI
      const SizedBox.shrink(), // Index 3: ပုံသေမပြဘဲ Navigator.push နဲ့ သွားမှာဖြစ်လို့ (SizedBox သာ ထားပါသည်)
      const Center(child: Text("Profile Screen", style: TextStyle(fontSize: 18))),              // Index 4: Profile
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6), 
      body: SafeArea(
        child: _currentTabIndex == 3 
            ? _buildHomeDashboard() // 🎯 Index 3 (History) က ပြန်ထွက်လာရင် Home Dashboard ကို ပြန်ပြရန်
            : IndexedStack(
                index: _currentTabIndex,
                children: _pages,
              ),
      ),
     
    );
  }

  // 🛠️ Main Dashboard Component
  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            const SizedBox(height: 20),
            _buildTotalBalanceCard(),
            const SizedBox(height: 24),
            _buildUpcomingAlertsSection(),
            const SizedBox(height: 24),
            _buildRecentTransactionsSection(),
          ],
        ),
      ),
    );
  }

  
  // 🛠️ UI Sub-Components (App Bar, Balance Card, Alerts, Transactions)
  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.menu, size: 22, color: Colors.black87),
        ),
        const Text("Expense Tracker", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.notifications_none_outlined, size: 22, color: Colors.black87),
                ),
                const Positioned(
                  right: 4, top: 4,
                  child: CircleAvatar(
                    radius: 8, backgroundColor: Colors.red,
                    child: Text("2", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.calendar_month_outlined, size: 22, color: Colors.black87),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTotalBalanceCard() {
    double currentBalance = 150000;
    double totalIncome = 600000;
    double totalExpense = 450000;
    final formatter = NumberFormat('#,##0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9F75FF), Color(0xFF7C3AED)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26, backgroundColor: Colors.white24,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150'), 
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Good Morning,", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(_currentUserName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Current Balance", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                child: Icon(_isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70, size: 16),
              )
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _isBalanceVisible ? formatter.format(currentBalance) : "•••••",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const CircleAvatar(radius: 14, backgroundColor: Colors.white24, child: Icon(Icons.arrow_upward, size: 14, color: Colors.greenAccent)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Income", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(formatter.format(totalIncome), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(radius: 14, backgroundColor: Colors.white24, child: Icon(Icons.arrow_downward, size: 14, color: Colors.redAccent)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Expense", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(formatter.format(totalExpense), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUpcomingAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Upcoming Alerts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const SizedBox(width: 6),
            const CircleAvatar(
              radius: 9, backgroundColor: Color(0xFF7C3AED),
              child: Text("2", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 12),
        _buildAlertCard(
          icon: Icons.wifi_outlined, iconColor: Colors.orange, bgColor: Colors.orange.shade50, borderColor: Colors.orange.shade300,
          title: "Wi-Fi Bill", subtitle: "25,000 MMK payment due July 30", tag: "DUE TOMORROW", tagBg: const Color(0xFFFEF3C7), tagTextColor: Colors.amber.shade900,
        ),
        const SizedBox(height: 10),
        _buildAlertCard(
          icon: Icons.access_time_outlined, iconColor: Colors.purple, bgColor: Colors.purple.shade50, borderColor: Colors.purple.shade300,
          title: "Log Daily Expense", subtitle: "Keep your daily budget accurate", tag: "REMINDER", tagBg: const Color(0xFFF3E8FF), tagTextColor: Colors.purple.shade900,
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon, required Color iconColor, required Color bgColor, required Color borderColor,
    required String title, required String subtitle, required String tag, required Color tagBg, required Color tagTextColor
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: borderColor, width: 5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18, backgroundColor: bgColor, child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(tag, style: TextStyle(color: tagTextColor, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.close, size: 14, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Recent Transactions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            GestureDetector(
              onTap: () async {
                setState(() => _currentTabIndex = 3);
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordHistoryScreen()));
                setState(() {
                  _currentTabIndex = 2;
                  _currentState = CategoryState.view;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: const [
                    Text("See all", style: TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w600)),
                    Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF7C3AED)),
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: ['All', 'Expense', 'Income'].map((tab) {
            bool isSelected = _transactionFilter == tab;
            return GestureDetector(
              onTap: () => setState(() => _transactionFilter = tab),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tab, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        _buildStaticTransactionTile(title: "Top Up", dateStr: "22/07  07:29:09", amountStr: "-2,000", isExpense: true, icon: Icons.phone_android, iconColor: Colors.red),
        const SizedBox(height: 10),
        _buildStaticTransactionTile(title: "Shopping", dateStr: "21/07  09:21:01", amountStr: "-50,000", isExpense: true, icon: Icons.shopping_cart_outlined, iconColor: Colors.blue),
        const SizedBox(height: 10),
        _buildStaticTransactionTile(title: "Pocket Money", dateStr: "20/07  08:29:09", amountStr: "+100,000", isExpense: false, icon: Icons.money, iconColor: Colors.green),
      ],
    );
  }

  Widget _buildStaticTransactionTile({required String title, required String dateStr, required String amountStr, required bool isExpense, required IconData icon, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: iconColor.withOpacity(0.15), child: Icon(icon, color: iconColor, size: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amountStr, style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: isExpense ? const Color(0xFFFFE4E6) : const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                child: Text(isExpense ? "expense" : "income", style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
