import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_typography.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';

class ChatMarkdownView extends StatelessWidget {
  final String text;
  final bool isStreaming;

  const ChatMarkdownView({
    super.key,
    required this.text,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveText = isStreaming ? '$text █' : text;

    return MarkdownBody(
      data: effectiveText,
      selectable: true,
      builders: {
        'code': CodeBlockBuilder(context),
      },
      styleSheet: MarkdownStyleSheet(
        p: AppTypography.bodySmall.copyWith(
          fontSize: 14.5,
          color: AppColors.textPrimary,
          height: 1.55,
        ),
        strong: AppTypography.bodySmall.copyWith(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.55,
        ),
        em: AppTypography.bodySmall.copyWith(
          fontSize: 14.5,
          fontStyle: FontStyle.italic,
          color: AppColors.textPrimary,
          height: 1.55,
        ),
        h1: AppTypography.titleLarge.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        h2: AppTypography.titleMedium.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        h3: AppTypography.titleSmall.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        listBullet: AppTypography.bodySmall.copyWith(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        listIndent: 24.0,
        blockquote: AppTypography.bodySmall.copyWith(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: const Color(0xFF4B5563),
        ),
        blockquoteDecoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(color: AppColors.primary, width: 3),
          ),
        ),
        code: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Color(0xFF1E2224),
          backgroundColor: Color(0xFFE2E5EA),
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF181B1D),
          borderRadius: BorderRadius.circular(14),
        ),
        horizontalRuleDecoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  CodeBlockBuilder(this.context);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // If inline code (no children blocks or single line without newlines)
    if (!element.textContent.contains('\n') &&
        element.attributes['class'] == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E5EA),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          element.textContent,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181B1D),
          ),
        ),
      );
    }

    final language = _extractLanguage(element);
    final codeText = element.textContent.trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF181B1D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2D3236),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar with Language label and Copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF222629),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.8,
                  ),
                ),
                _CopyCodeButton(codeText: codeText),
              ],
            ),
          ),

          // Code Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SelectableText(
                codeText,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFFE5E7EB),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _extractLanguage(md.Element element) {
    final classAttr = element.attributes['class'];
    if (classAttr != null && classAttr.startsWith('language-')) {
      return classAttr.substring(9);
    }
    return 'code';
  }
}

class _CopyCodeButton extends StatefulWidget {
  final String codeText;

  const _CopyCodeButton({required this.codeText});

  @override
  State<_CopyCodeButton> createState() => _CopyCodeButtonState();
}

class _CopyCodeButtonState extends State<_CopyCodeButton> {
  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.codeText));
    setState(() => _copied = true);
    AppSnackBar.showSuccess(context, message: 'Code copied to clipboard');

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _copy,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _copied ? Icons.check_rounded : Icons.content_copy_rounded,
              size: 14,
              color: _copied ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 5),
            Text(
              _copied ? 'Copied!' : 'Copy code',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color:
                    _copied ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
