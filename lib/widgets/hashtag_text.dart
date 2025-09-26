import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class HashtagText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const HashtagText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _buildTextSpan(text, style ?? AppTextStyles.body),
    );
  }

  TextSpan _buildTextSpan(String text, TextStyle defaultStyle) {
    final List<TextSpan> spans = [];
    final RegExp hashtagRegex = RegExp(r'#\S+');
    int lastMatchEnd = 0;

    for (final Match match in hashtagRegex.allMatches(text)) {
      // 前の部分のテキスト
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: defaultStyle,
        ));
      }

      // ハッシュタグ部分
      final hashtag = match.group(0)!;
      Color hashtagColor = AppColors.primary;
      
      // 募集ハッシュタグは特別な色に
      if (hashtag == '#募集') {
        hashtagColor = Colors.orange;
      }
      
      spans.add(TextSpan(
        text: hashtag,
        style: defaultStyle.copyWith(
          color: hashtagColor,
          fontWeight: FontWeight.w600,
        ),
      ));

      lastMatchEnd = match.end;
    }

    // 残りのテキスト
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: defaultStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}