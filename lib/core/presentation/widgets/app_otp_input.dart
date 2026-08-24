import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// A customizable OTP / Pin Code input widget with individual rounded square boxes.
class AppOtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;

  const AppOtpInput({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
    this.autoFocus = true,
  });

  @override
  State<AppOtpInput> createState() => _AppOtpInputState();
}

class _AppOtpInputState extends State<AppOtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    final code = _otpCode;
    widget.onChanged?.call(code);

    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 64,
          height: 64,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  _controllers[index].text.isEmpty &&
                  index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              autofocus: widget.autoFocus && index == 0,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: AppTypography.displayLarge.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (val) => _onDigitChanged(index, val),
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppColors.textfields,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.roundedLg,
                  borderSide: BorderSide(color: AppColors.dividers, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.roundedLg,
                  borderSide: BorderSide(color: AppColors.dividers, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.roundedLg,
                  borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
