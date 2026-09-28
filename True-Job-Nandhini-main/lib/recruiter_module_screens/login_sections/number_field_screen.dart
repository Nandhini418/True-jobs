import 'package:truejobs/recruiter_module_screens/login_sections/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/utils/phone_number_formatter.dart';

class NumberFieldScreen extends StatefulWidget {
  const NumberFieldScreen({super.key});

  @override
  State<NumberFieldScreen> createState() => _NumberFieldScreenState();
}

class _NumberFieldScreenState extends State<NumberFieldScreen> {
  static const String _fontFamily = 'Poppins';
  static const int _phoneLength = 10;

  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  bool _isPhoneComplete = false;
  bool _isPhoneFocused = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    _phoneFocusNode.addListener(_onFocusChanged);
  }

  void _onPhoneChanged() {
    final isComplete = _phoneController.text.length == _phoneLength;
    if (isComplete != _isPhoneComplete) {
      setState(() {
        _isPhoneComplete = isComplete;
      });
    }
  }

  void _onFocusChanged() {
    setState(() {
      _isPhoneFocused = _phoneFocusNode.hasFocus;
    });
  }

  bool get _canGetOtp => _isPhoneComplete && _agreedToTerms;

  void _onGetOtpPressed() {
    if (!_canGetOtp) return;
    // TODO: call your OTP API here and navigate to the OTP screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: _phoneController.text,
          isRegistration: true,
        ),
      ),
    );
  }

  void _onJobSeekerPressed() {
    // TODO: navigate to Job Seeker sign-in flow
  }

  Color get _phoneBorderColor {
    if (_isPhoneComplete) return AppColors.primary;
    if (_isPhoneFocused) return AppColors.dynamicBorder;
    return Colors.transparent;
  }

  double get _phoneBorderWidth {
    if (_isPhoneComplete) return 1.0;
    if (_isPhoneFocused) return 1.0;
    return 0.0;
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _phoneFocusNode.removeListener(_onFocusChanged);
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.05,
            screenWidth * 0.05,
            screenWidth * 0.05,
            screenHeight * 0.025,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.03),
              _buildTitle(screenWidth, textColor, subtitleColor),
              SizedBox(height: screenHeight * 0.04),
              _buildCard(
                screenWidth,
                screenHeight,
                textColor,
                subtitleColor,
                borderColor,
              ),
              SizedBox(height: screenHeight * 0.3),
              Center(
                child: _footerLine(
                  'Looking for a job? ',
                  'Sign in as Job Seeker',
                  screenWidth,
                  textColor,
                  _onJobSeekerPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(double screenWidth, Color textColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Talent That\nDrives Your\nBusiness Forward.',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.25,
          ),
        ),
        SizedBox(height: screenWidth * 0.025),
        Text(
          'Discover qualified professionals, automate recruitment, and build high-performing teams.',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: screenWidth * 0.03,
            color: Color(0x66000000),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
      double screenWidth,
      double screenHeight,
      Color textColor,
      Color subtitleColor,
      Color borderColor,
      ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xFFE0E0E0),
          width: 0.63
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000), // #00000014
            offset: const Offset(0, 4),
            blurRadius: 10.04,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0x0A000000), // #0000000A
            offset: const Offset(0, 0),
            blurRadius: 2.51,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue with mobile',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: screenWidth * 0.042,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'Mobile number',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: screenWidth * 0.032,
              color: subtitleColor,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          _buildPhoneField(screenWidth, textColor),
          SizedBox(height: screenHeight * 0.018),
          _buildTermsCheckbox(screenWidth, subtitleColor),
          SizedBox(height: screenHeight * 0.035),
          _buildGetOtpButton(screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildPhoneField(double screenWidth, Color textColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: screenWidth * 0.14,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: _phoneBorderColor,
          width: _phoneBorderWidth,
        ),
      ),
      child: Row(
        children: [
          Text(
            '+91',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: screenWidth * 0.038,
              color: textColor,
            ),
          ),
          SizedBox(width: screenWidth * 0.025),
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              maxLength: _phoneLength,
              inputFormatters: [PhoneNumberFormatter()],
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: screenWidth * 0.038,
                color: textColor,
              ),
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: 'Enter your mobile number to get OTP',
                hintStyle: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: screenWidth * 0.032,
                  color: const Color(0x22000000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox(double screenWidth, Color subtitleColor) {
    return Row(
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            checkboxTheme: CheckboxThemeData(
              side: BorderSide(
                color: Color(0xFFCFCFCF),
                width: 1.0, // Border thickness
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          child: Checkbox(
            value: _agreedToTerms,
            activeColor: AppColors.primary,
            checkColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
          ),
        ),
        SizedBox(width: screenWidth * 0.01),
        Expanded(
          child: Text(
            'I agree to the Privacy Policy and Terms & Conditions',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: screenWidth * 0.028,
              color: Color(0x88000000),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGetOtpButton(double screenWidth, double screenHeight) {
    return SizedBox(
      width: double.infinity,
      height: screenWidth * (42 / 360),
      child: ElevatedButton(
        onPressed: _canGetOtp ? _onGetOtpPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Color(0xFFEFF0F3),
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.buttonDisabledText,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              screenWidth * (103 / 360),
            ),
          ),
        ),
        child: Text(
          'Get OTP',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: screenWidth * 0.038,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _footerLine(
      String normal,
      String link,
      double screenWidth,
      Color textColor,
      VoidCallback onLinkTap,
      ) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: screenWidth * 0.032,
          color: textColor,
          letterSpacing: 0.2,
        ),
        children: [
          TextSpan(text: normal),
          TextSpan(
            text: link,
            style: const TextStyle(
              fontFamily: _fontFamily,
              color: Color(0xFF055BF2),
            ),
            recognizer: TapGestureRecognizer()..onTap = onLinkTap,
          ),
        ],
      ),
    );
  }
}