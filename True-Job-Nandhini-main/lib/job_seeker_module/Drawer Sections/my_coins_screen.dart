import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api/wallet_api.dart';

class MyCoinsScreen extends StatefulWidget {
  const MyCoinsScreen({Key? key}) : super(key: key);

  @override
  State<MyCoinsScreen> createState() => _MyCoinsScreenState();
}

class _MyCoinsScreenState extends State<MyCoinsScreen> {
  bool _isLoading = true;
  int _coinBalance = 0;
  int _purchasedCoins = 0;
  int _spentCoins = 0;
  int _remainingCoins = 0;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 1; // Default to 1 if not found

      final res = await WalletApi.fetchWallet(userId: userId);
      if (res['error'] == false && res['data'] != null && res['data'].isNotEmpty) {
        final data = res['data'][0];
        setState(() {
          _coinBalance = data['balance_coins'] ?? 0;
          _purchasedCoins = data['total_purchase_coins'] ?? 0;
          _spentCoins = data['total_spent_coins'] ?? 0;
          _remainingCoins = data['balance_coins'] ?? 0; // Using balance_coins for remaining
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'My Coins',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMainCard(sw),
                          const SizedBox(height: 24),
                          _buildTransactionHistoryTile(sw),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomArea(sw),
                ],
              ),
      ),
    );
  }

  Widget _buildMainCard(double sw) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Top Blue Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2563EB), Color(0xFF153885)],
                stops: [0.7, 1.0],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Coin Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: const [
                        Text(
                          'View plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.asset(
                      'assets/common_images/coin.png', // Fallback, but ideally a coin icon
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_coinBalance',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        'Coins',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bottom White Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Purchased', '$_purchasedCoins'),
                _buildVerticalDivider(),
                _buildStatColumn('Spent', '$_spentCoins'),
                _buildVerticalDivider(),
                _buildStatColumn('Remaining', '$_remainingCoins'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondary_color,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 0.5, color: Color(0xFFC2C2C2));
  }

  Widget _buildTransactionHistoryTile(double sw) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE6E6E6)),
      ),
      child: Row(
        children: [
          Image.asset('assets/common_images/transaction_history.png', height: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Transaction History',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'View your coin activity',
                  style: TextStyle(color: AppColors.secondary_color, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.black87, size: 16),
        ],
      ),
    );
  }

  Widget _buildBottomArea(double sw) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Not Enough Coins Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: const [
                Text(
                  'Not Enough Coins?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Buy coins to unlock features',
                  style: TextStyle(color: AppColors.secondary_color, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Sticky Bottom Button Area
          Container(
            padding: const EdgeInsets.fromLTRB(64, 16, 64, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFCFCFCF))),
            ),
            child: ElevatedButton(
              onPressed: () {
                // Handle Buy Coins
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Blue button
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Buy Coins',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
