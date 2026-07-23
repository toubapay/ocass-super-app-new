import 'package:flutter/material.dart';

class CustomThemeColors extends ThemeExtension<CustomThemeColors> {
  final Map<String, Color> buttonBackgroundColorMap;
  final Map<String, Color> buttonTextColorMap;
  final Color error;
  final Color success;
  final Color info;
  final Color warning;
  final Color cardColor;
  final Color searchBarBorder;

  const CustomThemeColors({
    required this.buttonBackgroundColorMap,
    required this.buttonTextColorMap,
    required this.error,
    required this.success,
    required this.info,
    required this.warning,
    required this.cardColor,
    required this.searchBarBorder,
  });

  // Predefined themes for light and dark modes
  factory CustomThemeColors.light() => const CustomThemeColors(
    buttonBackgroundColorMap: {
      'pending': Color(0x457bc2f6),
      'accepted': Color(0x499ad0fb),
      'ongoing': Color(0x629ac5f8),
      'completed': Color(0x5faff4c1),
      'settled': Color(0x6e93b347),
      'canceled': Color(0x51F6A9A9),
      'approved': Color(0x80356e4c),
      'expired' : Color(0x8C7C3B3B),
      'running' : Color(0x793c4fd8),
      'denied':  Color(0x666e3737),
      'paused': Color(0xff0461A5),
      'resumed' : Color(0x6f2f5e41),
      'resume' : Color(0x8e387c54),
      'subscription_purchase' : Color(0x3cecc98d),
      'subscription_renew' : Color(0x1d6bf5a2),
      'subscription_shift' : Color(0x452599ee),
      'subscription_refund' : Color(0x1dc97eee),
    },
    buttonTextColorMap: {
      'pending': Color(0xff058df3),
      'accepted': Color(0xff2B95FF),
      'ongoing': Color(0xff2B95FF),
      'completed': Color(0xff03b158),
      'settled': Color(0xf57b9826),
      'canceled': Color(0xfff44747),
      'approved': Color(0xff16B559),
      'expired' : Color(0xff9ca8af),
      'running' : Color(0xff707ec6),
      'denied':  Color(0xffFF3737),
      'paused': Color(0xff0461A5),
      'resumed' : Color(0xff16B559),
      'resume' : Color(0xff16B559),
      'subscription_purchase' : Color(0xffe7680a),
      'subscription_renew' : Color(0xff16B559),
      'subscription_shift' : Color(0xff0461A5),
      'subscription_refund' : Color(0xffba4af8),
    },
    error: Color(0xffFF4040),
    success: Color(0xff04BB7B),
    info: Color(0xff3C76F1),
    warning: Color(0xffFFBB38),
    cardColor: Color(0xffF5F5F5),
    searchBarBorder: Color(0xffEFF1F4),
  );

  factory CustomThemeColors.dark() => const CustomThemeColors(
    buttonBackgroundColorMap: {
      'pending': Color(0x457bc2f6),
      'accepted': Color(0x499ad0fb),
      'ongoing': Color(0x629ac5f8),
      'completed': Color(0x5faff4c1),
      'settled': Color(0x6e93b347),
      'canceled': Color(0x51F6A9A9),
      'approved': Color(0x80356e4c),
      'expired' : Color(0x8C7C3B3B),
      'running' : Color(0x793c4fd8),
      'denied':  Color(0x666e3737),
      'paused': Color(0xff0461A5),
      'resumed' : Color(0x6f2f5e41),
      'resume' : Color(0x8e387c54),
      'subscription_purchase' : Color(0x3cecc98d),
      'subscription_renew' : Color(0x1d6bf5a2),
      'subscription_shift' : Color(0x452599ee),
      'subscription_refund' : Color(0x1dc97eee),
    },
    buttonTextColorMap: {
      'pending': Color(0xff058df3),
      'accepted': Color(0xff2B95FF),
      'ongoing': Color(0xff2B95FF),
      'completed': Color(0xff03b158),
      'settled': Color(0xf57b9826),
      'canceled': Color(0xfff44747),
      'approved': Color(0xff16B559),
      'expired' : Color(0xff9ca8af),
      'running' : Color(0xff707ec6),
      'denied':  Color(0xffFF3737),
      'paused': Color(0xff0461A5),
      'resumed' : Color(0xff16B559),
      'resume' : Color(0xff16B559),
      'subscription_purchase' : Color(0xffe7680a),
      'subscription_renew' : Color(0xff16B559),
      'subscription_shift' : Color(0xff0461A5),
      'subscription_refund' : Color(0xffba4af8),
    },
    error: Color(0xffC33D3D),
    success: Color(0xff019463),
    info: Color(0xff245BD1),
    warning: Color(0xffE6A832),
    cardColor: Color(0xFF35444C),
    searchBarBorder: Color(0xff363e47),
  );

  @override
  CustomThemeColors copyWith({
    Map<String, Color>? buttonBackgroundColorMap,
    Map<String, Color>? buttonTextColorMap,
  }) {
    return CustomThemeColors(
      buttonBackgroundColorMap: buttonBackgroundColorMap ?? this.buttonBackgroundColorMap,
      buttonTextColorMap: buttonTextColorMap ?? this.buttonTextColorMap,
      error: error,
      success: success,
      info: info,
      warning: warning,
      cardColor: cardColor,
      searchBarBorder: searchBarBorder,
    );
  }

  @override
  CustomThemeColors lerp(ThemeExtension<CustomThemeColors>? other, double t) {
    if (other is! CustomThemeColors) return this;

    return CustomThemeColors(
      buttonBackgroundColorMap: buttonBackgroundColorMap,
      buttonTextColorMap: buttonTextColorMap,
      error: error,
      success: success,
      info: info,
      warning: warning,
      cardColor: cardColor,
      searchBarBorder: searchBarBorder,
    );
  }
}