import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/rupee_text.dart';
import '../home_screen.dart';
import '../../utils/smooth_page_route.dart';
import '../../services/api/subscription_plan_api.dart';
import 'package:animate_gradient/animate_gradient.dart';

class ProPaymentScreen extends StatefulWidget {
  const ProPaymentScreen({super.key});

  @override
  State<ProPaymentScreen> createState() => _ProPaymentScreenState();
}

class _ProPaymentScreenState extends State<ProPaymentScreen> {
  int _selectedPlanIndex = 0;
  late Razorpay _razorpay;
  String _name = '';
  String _mobile = '';
  String _email = '';
  int _freeViews = 0;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _fetchPlans();
    _fetchRazorpayKey();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  bool _isLoading = true;
  String _razorpayKey = 'rzp_live_0JaXxZHLE0HNDj';

  Future<void> _fetchRazorpayKey() async {
    try {
      final response = await SubscriptionPlanApi.fetchRazorpayKey();
      if (response['status'] == true && response['pay_key'] != null) {
        setState(() {
          _razorpayKey = response['pay_key'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching razorpay key: $e');
    }
  }

  Future<void> _fetchPlans() async {
    try {
      final response = await SubscriptionPlanApi.fetchPlans();
      if (response['status'] == true && response['plans'] != null) {
        List<dynamic> planData = response['plans'];
        setState(() {
          _plans = planData.map((e) {
            final m = Map<String, dynamic>.from(e);
            final amount =
                double.tryParse(m['amount'].toString())?.toInt() ?? 0;
            return {
              'id': m['id'],
              'title': m['package_name'],
              'discountTag': m['bonus_coins'] > 0
                  ? '+${m['bonus_coins']} Bonus'
                  : '',
              'discountedPrice': amount,
              'originalPrice': amount,
              'footer':
                  '${m['total_coins']} Coins • ₹ ${m['hr_view_coin_cost']}/View',
              'total_coins': m['total_coins'],
              'subtotal': amount,
              'discountVal': 0,
              'gst': 0,
              'total': amount,
              'amount_paise': amount * 100, // Razorpay amount in paise
            };
          }).toList();
          _isLoading = false;
        });
        if (response['wallet'] != null) {
          _freeViews = int.tryParse(response['wallet']['free_views'].toString()) ?? 0;
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to fetch plans'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching plans: $e');
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _name = prefs.getString('name') ?? '';
        _mobile = prefs.getString('mobile') ?? '';
        _email = prefs.getString('email') ?? '';
      });
    } catch (e) {
      debugPrint('Error loading user details for payment: $e');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      if (userId == null) {
        final String? userIdStr = prefs.getString('user_id');
        if (userIdStr != null) {
          userId = int.tryParse(userIdStr);
        }
      }
      if (userId == null) {
        final String? cidStr = prefs.getString('cid');
        if (cidStr != null) {
          userId = int.tryParse(cidStr);
        }
      }

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final result = await SubscriptionPlanApi.verifyPayment(
        userId: userId,
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      // Dismiss loading overlay
      if (mounted) Navigator.pop(context);

      final bool isSuccess =
          result['status'] == 1 ||
          result['status'] == true ||
          result['status']?.toString().toLowerCase() == 'true' ||
          result['status']?.toString() == '1';

      if (isSuccess) {
        _showFeedbackDialog(
          isSuccess: true,
          title: 'Payment Successful',
          message:
              'Your subscription to Pro plan has been activated successfully!',
          transactionId: response.paymentId ?? 'N/A',
        );
      } else {
        _showFeedbackDialog(
          isSuccess: false,
          title: 'Activation Failed',
          message:
              result['message']?.toString() ??
              'Payment succeeded but activation failed on our end. Please contact support.',
          transactionId: response.paymentId ?? 'N/A',
        );
      }
    } catch (e) {
      // Dismiss loading overlay
      if (mounted) Navigator.pop(context);

      _showFeedbackDialog(
        isSuccess: false,
        title: 'Error',
        message: 'An error occurred while activating your plan: $e',
        transactionId: response.paymentId ?? 'N/A',
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment cancelled by user.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    _showFeedbackDialog(
      isSuccess: false,
      title: 'Payment Failed',
      message:
          response.message ??
          'An error occurred during payment. Please try again.',
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _startPayment(Map<String, dynamic> selectedPlan) async {
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      if (userId == null) {
        final String? userIdStr = prefs.getString('user_id');
        if (userIdStr != null) {
          userId = int.tryParse(userIdStr);
        }
      }
      if (userId == null) {
        final String? cidStr = prefs.getString('cid');
        if (cidStr != null) {
          userId = int.tryParse(cidStr);
        }
      }

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final int coinsAdd =
          int.tryParse(selectedPlan['total_coins']?.toString() ?? '0') ?? 0;
      final double amount = (selectedPlan['discountedPrice'] as num).toDouble();
      final int packageId = int.tryParse(selectedPlan['id'].toString()) ?? 0;

      final result = await SubscriptionPlanApi.createRazorpayOrder(
        coinsAdd: coinsAdd,
        amount: amount,
        packageId: packageId,
        userId: userId,
      );

      // Dismiss loading overlay if mounted before opening Razorpay (Razorpay has its own UI)
      if (mounted) Navigator.pop(context);

      final bool isSuccess =
          result['status'] == 1 ||
          result['status'] == true ||
          result['status']?.toString().toLowerCase() == 'true' ||
          result['status']?.toString() == '1';

      if (!isSuccess || result['order_id'] == null) {
        throw Exception(
          result['message'] ?? 'Failed to create order on server',
        );
      }

      final String orderId = result['order_id'].toString();

      var options = {
        'key': _razorpayKey,
        'amount': selectedPlan['amount_paise'] ?? 100, // amount in paise
        'order_id': orderId,
        'name': 'True Jobs',
        'description': 'True Pro: ${selectedPlan['title']}',
        'prefill': {
          if (_name.isNotEmpty) 'name': _name,
          if (_mobile.isNotEmpty) 'contact': _mobile,
          if (_email.isNotEmpty) 'email': _email,
        },
        'theme': {
          'color': '#003399', // Matches AppColors.primary color
        },
        'external': {
          'wallets': ['paytm'],
        },
      };

      _razorpay.open(options);
    } catch (e) {
      // Dismiss loading overlay if there's an error and still showing
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      debugPrint('Error starting Razorpay checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initiating payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static const Color _navyMid = Color(0xFF0B2E63);
  static const Color _accentBlue = Color(0xFF1E5AA8);
  static const Color _green = Color(0xFF19893F);
  static const Color _cardDark = Color(0xFF0E2547);
  static const Color _borderDark = Color(0xFF1E3A66);

  void _showFeedbackDialog({
    required bool isSuccess,
    required String title,
    required String message,
    String? transactionId,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isSuccess,
      builder: (BuildContext context) {
        final double sw = MediaQuery.of(context).size.width;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: _navyMid,
          elevation: 10,
          child: Padding(
            padding: EdgeInsets.all(sw * 0.06),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: sw * 0.18,
                  height: sw * 0.18,
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? _green.withValues(alpha: 0.18)
                        : const Color(0xFFFFEBEE).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess
                        ? Icons.check_circle_rounded
                        : Icons.error_rounded,
                    color: isSuccess ? _green : const Color(0xFFEF5350),
                    size: sw * 0.12,
                  ),
                ),
                SizedBox(height: sw * 0.05),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sw * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: sw * 0.03),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: sw * 0.036,
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: sw * 0.05),
                Container(
                  padding: EdgeInsets.all(sw * 0.04),
                  decoration: BoxDecoration(
                    color: _cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderDark),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Amount Paid', '₹ 1.00', sw),
                      if (transactionId != null) ...[
                        SizedBox(height: sw * 0.02),
                        _buildDetailRow(
                          'Transaction ID',
                          transactionId,
                          sw,
                          isShorten: true,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: sw * 0.06),
                SizedBox(
                  width: double.infinity,
                  height: sw * 0.12,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (isSuccess) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          SmoothPageRoute(child: const HomeScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess
                          ? _green
                          : const Color(0xFFCE1414),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw * 0.06),
                      ),
                    ),
                    child: Text(
                      isSuccess ? 'Continue to Home' : 'Try Again',
                      style: TextStyle(
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    double sw, {
    bool isShorten = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: sw * 0.034,
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          isShorten && value.length > 18
              ? '${value.substring(0, 8)}...${value.substring(value.length - 8)}'
              : value,
          style: TextStyle(
            fontSize: sw * 0.034,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _plans = [];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final double sh = screenSize.height;

    final selectedPlan = _plans.isNotEmpty && _selectedPlanIndex < _plans.length
        ? _plans[_selectedPlanIndex]
        : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          // gradient: LinearGradient(
          //   colors: [
          //     _navyDark,
          //     _navyMid,
          //     _accentBlue,
          //     _navyMid,
          //     _navyDark,
          //   ],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _plans.isEmpty
              ? const Center(
                  child: Text(
                    'No subscription plans available',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        sw * 0.03,
                        sw * 0.02,
                        sw * 0.05,
                        0,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: _accentBlue,
                              size: sw * 0.05,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            'Upgrade to Pro',
                            style: TextStyle(
                              fontSize: sw * 0.052,
                              fontWeight: FontWeight.bold,
                              color: _accentBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          sw * 0.05,
                          sw * 0.02,
                          sw * 0.05,
                          sw * 0.04,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroCard(sw),
                            SizedBox(height: sw * 0.06),

                            Text(
                              'Choose your plan',
                              style: TextStyle(
                                fontSize: sw * 0.05,
                                fontWeight: FontWeight.bold,
                                color: _accentBlue,
                              ),
                            ),
                            SizedBox(height: sw * 0.05),

                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _plans.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: sw * 0.05),
                              itemBuilder: (context, index) {
                                final plan = _plans[index];
                                final isSelected = _selectedPlanIndex == index;
                                return _buildPlanCard(
                                  plan,
                                  index,
                                  isSelected,
                                  sw,
                                );
                              },
                            ),
                            SizedBox(height: sw * 0.06),
                            // Continue Button (Now scrolls with content)
                            Container(
                              padding: EdgeInsets.only(
                                top: sw * 0.03,
                                bottom: sw * 0.1,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: sh * 0.055,
                                    child: ElevatedButton(
                                      onPressed: selectedPlan != null
                                          ? () {
                                              if (_freeViews > 0) {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15),
                                                      ),
                                                      title: const Text('Free Views Available', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      content: Text('You still have $_freeViews free HR contact views left. Please use them before purchasing a plan!'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text('OK', style: TextStyle(color: Color(0xFF1E5AA8), fontWeight: FontWeight.bold)),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                );
                                              } else {
                                                _startPayment(selectedPlan);
                                              }
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _accentBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            sw * 0.08,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Continue to Pay  ₹ ${selectedPlan?['total'] ?? 0}',
                                            style: TextStyle(
                                              fontSize: sw * 0.04,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(double sw) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(sw * 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimateGradient(
        primaryColors: const [
          Color(0xFFE88515),
          Color(0xFF772B88),
          Color(0xFFA41CC3),
        ],
        secondaryColors: const [
          Color(0xFFA41CC3),
          Color(0xFF772B88),
          Color(0xFFE88515),
        ],
        child: Padding(
          padding: EdgeInsets.all(sw * 0.04),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'True Jobs Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sw * 0.06,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: sw * 0.04),
                    _buildHeroFeature(
                      'Unlimited job posts',
                      Icons.work_outline_rounded,
                      sw,
                    ),
                    _buildHeroFeature(
                      'Priority interview calls',
                      Icons.bolt_rounded,
                      sw,
                    ),
                    _buildHeroFeature(
                      'Direct recruiter contact',
                      Icons.person_outline_rounded,
                      sw,
                    ),
                  ],
                ),
              ),
              SizedBox(width: sw * 0.015),
              Expanded(
                flex: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    'assets/image/shield.png',
                    fit: BoxFit.contain,
                    width: sw * 0.28,
                    height: sw * 0.30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroFeature(String label, IconData icon, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.02),
      child: Row(
        children: [
          Container(
            width: sw * 0.06,
            height: sw * 0.06,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: sw * 0.032),
          ),
          SizedBox(width: sw * 0.025),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: sw * 0.033,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    Map<String, dynamic> plan,
    int index,
    bool isSelected,
    double sw,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF772B88),
                    Color(0xFFE88515),
                    Color(0xFFA41CC3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFD2D2D2), width: 1),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: isSelected ? const EdgeInsets.all(1.2) : EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(13),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Top Section
              Padding(
                padding: EdgeInsets.all(sw * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        plan['title'] ?? '',
                        style: TextStyle(
                          fontSize: sw * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RupeeText(
                          text: '₹ ${plan['discountedPrice']}',
                          style: TextStyle(
                            fontSize: sw * 0.045,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          iconHeight: sw * 0.065,
                        ),
                        if (plan['originalPrice'] != null &&
                            plan['originalPrice'] != plan['discountedPrice'])
                          RupeeText(
                            text: '₹ ${plan['originalPrice']}',
                            style: TextStyle(
                              fontSize: sw * 0.045,
                              color: const Color(0xFF9CA3AF),
                              decoration: TextDecoration.lineThrough,
                            ),
                            iconHeight: sw * 0.04,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bottom Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05,
                  vertical: sw * 0.035,
                ),
                color: const Color(0xFFF3F4F6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RupeeText(
                        text: plan['footer'] ?? '',
                        style: TextStyle(
                          fontSize: sw * 0.035,
                          color: Colors.black87,
                        ),
                        iconHeight: sw * 0.04,
                      ),
                    ),
                    if (plan['discountTag'] != null &&
                        plan['discountTag'].toString().isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.03,
                          vertical: sw * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF23A455),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          plan['discountTag'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sw * 0.028,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
