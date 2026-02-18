import 'package:finance_management/screens/more/add_transaction.dart';
import 'package:finance_management/screens/more/check_balance.dart';
import 'package:flutter/material.dart';

import '../../data/session_manager.dart';
import '../../models/user_profile.dart';
import '../more/check_borrowed_balance.dart';
import '../more/credit_card_balance.dart';
import 'recent_transactions_page.dart';
import 'widgets/app_drawer.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/section_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.sessionManager,
    required this.user,
  });

  final SessionManager sessionManager;
  final UserProfile user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _DashboardTab(user: widget.user),
      const RecentTransactionsPage(),
      const _SettingsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Management'),
      ),
      drawer: AppDrawer(
        user: widget.user,
        onLogout: widget.sessionManager.logout,
      ),
      floatingActionButton: ElevatedButton(onPressed: (){
        // Navigate to Add Transactions page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransaction()),
        );
      }, child: Text("Add New +")),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          title: 'Welcome, ${user.name}',
          subtitle: 'Role: ${user.role}',
          icon: Icons.verified_user_outlined,
        ),
        const SizedBox(height: 16),
        SectionCard(
          onTap: (){
            // Navigate to Recent Transactions page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreditCardBalance()),
            );
          },
          title: 'Credit Card Details',
          subtitle: 'Track planned vs actual expenses.',
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 16),
        SectionCard(
          onTap: (){
            // Navigate to Recent Transactions page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckBalance()),
            );
          },
          title: 'Check Account Balance',
          subtitle: 'Review the current account balance.',
          icon: Icons.swap_horiz_outlined,
        ),
        const SizedBox(height: 16),
        SectionCard(
          onTap: (){
            // Navigate to Recent Transactions page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckBorrowedBalance()),
            );
          },
          title: 'Check Borrowed Amount',
          subtitle: 'Review the current Borrowed money.',
          icon: Icons.swap_horiz_outlined,
        ),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        SectionCard(
          title: 'Notifications',
          subtitle: 'Manage alerts and reminders.',
          icon: Icons.notifications_outlined,
        ),
        SizedBox(height: 16),
        SectionCard(
          title: 'Security',
          subtitle: 'Update access policies.',
          icon: Icons.security_outlined,
        ),
      ],
    );
  }
}
