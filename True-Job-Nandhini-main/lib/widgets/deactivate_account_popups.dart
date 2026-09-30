import 'package:flutter/material.dart';
import 'package:truejobs/common_screens/role_selection_screen.dart';
import '../constants/app_colors.dart';

/// Entry point â€” call this from Settings screen's "Deactivate Account" tap.
void showDeactivateFirstPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.dynamicCardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return _DeactivateFirstPopup(
        onKeepAccount: () => Navigator.pop(sheetContext),
        onDeactivate: () {
          Navigator.pop(sheetContext);
          showDeactivateReasonPopup(context);
        },
      );
    },
  );
}

void showDeactivateReasonPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.dynamicCardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return _DeactivateReasonPopup(
        onKeepAccount: () => Navigator.pop(sheetContext),
        onReasonSelected: (reason) {
          Navigator.pop(sheetContext);
          showDeactivateOtpPopup(context);
        },
      );
    },
  );
}

void showDeactivateOtpPopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.dynamicCardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return _DeactivateOtpPopup(
        onKeepAccount: () => Navigator.pop(sheetContext),
        onDeactivate: () {
          Navigator.pop(sheetContext);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (route) => false,
          );
        },
      );
    },
  );
}

/// ---------------- POPUP 1 : Warning ----------------
class _DeactivateFirstPopup extends StatelessWidget {
  final VoidCallback onKeepAccount;
  final VoidCallback onDeactivate;

  const _DeactivateFirstPopup({
    required this.onKeepAccount,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Padding(
      padding: EdgeInsets.only(
        left: sw * 0.05,
        right: sw * 0.05,
        top: sw * 0.05,
        bottom: MediaQuery.of(context).viewInsets.bottom + sw * 0.05,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "We're Sorry to See You Go!",
                  style: TextStyle(fontSize: sw * 0.048, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              GestureDetector(
                onTap: onKeepAccount,
                child: Icon(Icons.close, size: sw * 0.06, color: subtitleColor),
              ),
            ],
          ),
          SizedBox(height: sw * 0.03),
          Text(
            "Are you sure you want to deactivate your True Jobs account?",
            style: TextStyle(fontSize: sw * 0.038, color: subtitleColor, height: 1.4),
          ),
          SizedBox(height: sw * 0.03),
          Text(
            "Your profile will be hidden, job alerts and recruiter messages will be paused. You can reactivate your account anytime by signing in again.",
            style: TextStyle(fontSize: sw * 0.038, color: subtitleColor, height: 1.4),
          ),
          SizedBox(height: sw * 0.06),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onKeepAccount,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Keep My Account',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: sw * 0.036),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDeactivate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA21818),
                    padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Deactivate Account',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: sw * 0.036),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------- POPUP 2 : Reason ----------------
class _DeactivateReasonPopup extends StatefulWidget {
  final VoidCallback onKeepAccount;
  final ValueChanged<String> onReasonSelected;

  const _DeactivateReasonPopup({
    required this.onKeepAccount,
    required this.onReasonSelected,
  });

  @override
  State<_DeactivateReasonPopup> createState() => _DeactivateReasonPopupState();
}

class _DeactivateReasonPopupState extends State<_DeactivateReasonPopup> {
  final List<String> _reasons = [
    'I found a job',
    "There aren't enough jobs in my location",
    'Other reason',
  ];

  String? _selectedReason;
  bool _showOtherField = false;
  final TextEditingController _otherReasonController = TextEditingController();

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _onChipTap(String reason) {
    if (reason == 'Other reason') {
      setState(() {
        _selectedReason = reason;
        _showOtherField = true;
      });
    } else {
      setState(() {
        _selectedReason = reason;
        _showOtherField = false;
      });
      widget.onReasonSelected(reason);
    }
  }

  void _onDeactivateTap() {
    if (_showOtherField) {
      if (_otherReasonController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please tell us your reason')),
        );
        return;
      }
      widget.onReasonSelected(_otherReasonController.text.trim());
    } else if (_selectedReason != null) {
      widget.onReasonSelected(_selectedReason!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final Color cardBg = AppColors.dynamicCardBg;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Padding(
      padding: EdgeInsets.only(
        left: sw * 0.05,
        right: sw * 0.05,
        top: sw * 0.05,
        bottom: MediaQuery.of(context).viewInsets.bottom + sw * 0.05,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Why are you deactivating",
                  style: TextStyle(fontSize: sw * 0.048, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              GestureDetector(
                onTap: widget.onKeepAccount,
                child: Icon(Icons.close, size: sw * 0.06, color: subtitleColor),
              ),
            ],
          ),
          SizedBox(height: sw * 0.04),
          Wrap(
            spacing: sw * 0.02,
            runSpacing: sw * 0.025,
            children: _reasons.map((reason) {
              final bool isSelected = _selectedReason == reason;
              return GestureDetector(
                onTap: () => _onChipTap(reason),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.025),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : cardBg,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontSize: sw * 0.034,
                      color: isSelected ? AppColors.primary : textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_showOtherField) ...[
            SizedBox(height: sw * 0.04),
            TextField(
              controller: _otherReasonController,
              maxLines: 3,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Please specify your reason',
                hintStyle: TextStyle(color: subtitleColor, fontSize: sw * 0.036),
                contentPadding: EdgeInsets.all(sw * 0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
          SizedBox(height: sw * 0.06),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onKeepAccount,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Keep My Account',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: sw * 0.036),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onDeactivateTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA21818),
                    padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Deactivate Account',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: sw * 0.036),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------- POPUP 3 : OTP ----------------
class _DeactivateOtpPopup extends StatefulWidget {
  final VoidCallback onKeepAccount;
  final VoidCallback onDeactivate;

  const _DeactivateOtpPopup({
    required this.onKeepAccount,
    required this.onDeactivate,
  });

  @override
  State<_DeactivateOtpPopup> createState() => _DeactivateOtpPopupState();
}

class _DeactivateOtpPopupState extends State<_DeactivateOtpPopup> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final Color textColor = AppColors.dynamicText;
    final Color subtitleColor = AppColors.dynamicSubtitle;
    final Color borderColor = AppColors.dynamicBorder;

    return Padding(
      padding: EdgeInsets.only(
        left: sw * 0.05,
        right: sw * 0.05,
        top: sw * 0.05,
        bottom: MediaQuery.of(context).viewInsets.bottom + sw * 0.05,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Please enter OTP",
                  style: TextStyle(fontSize: sw * 0.048, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              GestureDetector(
                onTap: widget.onKeepAccount,
                child: Icon(Icons.close, size: sw * 0.06, color: subtitleColor),
              ),
            ],
          ),
          SizedBox(height: sw * 0.02),
          Text(
            "We have send you an OTP at 8590794021",
            style: TextStyle(fontSize: sw * 0.036, color: subtitleColor),
          ),
          SizedBox(height: sw * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              return SizedBox(
                width: sw * 0.15,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(fontSize: sw * 0.05, fontWeight: FontWeight.bold, color: textColor),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: sw * 0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 3) {
                      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                    } else if (value.isEmpty && index > 0) {
                      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                    }
                  },
                ),
              );
            }),
          ),
          SizedBox(height: sw * 0.04),
          Text(
            "Your account will be temporarily deactivated. You won't receive any communications from True Jobs. Sign in anytime to reactivate your account and restore your profile.",
            style: TextStyle(fontSize: sw * 0.032, color: subtitleColor, height: 1.4),
          ),
          SizedBox(height: sw * 0.06),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onKeepAccount,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Keep My Account',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: sw * 0.036),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onDeactivate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA21818),
                    padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Deactivate Account',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: sw * 0.036),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
