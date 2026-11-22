import 'package:demandium/theme/custom_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';

/// The Noor web app's look (marcheocass/src/styles.css, colours B):
/// green for headers, buttons, links and prices; gold for highlights,
/// badges and the active chip; light grey page background, white cards with
/// large rounded corners, pill-shaped chips, bottom sheets rounded at 28.
class NoorTheme {
  static const green = Color(0xFF0E4D3A);
  static const greenDark = Color(0xFF0B3D2E);
  static const greenLight = Color(0xFF136B50);
  static const greenSoft = Color(0xFFE4F1EA);
  static const gold = Color(0xFFB8901F);
  static const goldDark = Color(0xFF6E500A);
  static const goldSoft = Color(0xFFF8EDCC);
  static const goldInk = Color(0xFF2A1D00);
  static const bg = Color(0xFFF4F4F5);
  static const text = Color(0xFF1C1C1E);
  static const muted = Color(0xFF6B6B70);
  static const line = Color(0xFFE5E5EA);
  static const danger = Color(0xFFC81E1E);

  /// The header of every page (.page-header): a green gradient.
  static const headerGradient = LinearGradient(colors: [greenDark, green, greenLight], stops: [0, 0.55, 1]);
}

ThemeData light({Color color = NoorTheme.green}) {
  final shape18 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
  const buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  return ThemeData(
    fontFamily: AppConstants.fontFamily,
    primaryColor: color,
    secondaryHeaderColor: NoorTheme.gold,
    disabledColor: const Color(0xFF9F9F9F),
    brightness: Brightness.light,
    hintColor: const Color(0xFF9F9F9F),
    cardColor: Colors.white,
    scaffoldBackgroundColor: NoorTheme.bg,
    canvasColor: NoorTheme.bg,
    shadowColor: Colors.black.withValues(alpha: 0.03),
    colorScheme: ColorScheme.light(primary: color, secondary: NoorTheme.gold, onSecondary: NoorTheme.goldInk, tertiary: NoorTheme.gold)
        .copyWith(surface: NoorTheme.bg, onSurface: NoorTheme.text)
        .copyWith(error: NoorTheme.danger),
    textTheme: const TextTheme().apply(bodyColor: NoorTheme.text, displayColor: NoorTheme.text),
    appBarTheme: AppBarTheme(
      backgroundColor: color,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(fontFamily: AppConstants.fontFamily, fontSize: 21, fontWeight: FontWeight.w500, color: Colors.white),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color, textStyle: const TextStyle(fontWeight: FontWeight.w700))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size(64, 50),
        shape: shape18,
        elevation: 3,
        shadowColor: color.withValues(alpha: 0.35),
        textStyle: buttonText,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, minimumSize: const Size(64, 50), shape: shape18, textStyle: buttonText),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: Colors.white,
        side: BorderSide(color: color, width: 2),
        minimumSize: const Size(64, 48),
        shape: shape18,
        textStyle: buttonText,
      ),
    ),
    // Only the label colours: many fields draw their own borders and fills.
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(color: Color(0xFF9F9F9F)),
      floatingLabelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: NoorTheme.gold,
      secondarySelectedColor: NoorTheme.gold,
      side: const BorderSide(color: NoorTheme.line),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(fontFamily: AppConstants.fontFamily, fontWeight: FontWeight.w500, color: NoorTheme.text),
      secondaryLabelStyle: TextStyle(fontFamily: AppConstants.fontFamily, fontWeight: FontWeight.w700, color: NoorTheme.goldInk),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      modalBackgroundColor: Colors.white,
      showDragHandle: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: NoorTheme.text,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    popupMenuTheme: PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: color,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: color),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? color : null),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? color : null)),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : null),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? color : null),
    ),
    listTileTheme: const ListTileThemeData(iconColor: NoorTheme.text, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
    bottomAppBarTheme: const BottomAppBarThemeData(
      surfaceTintColor: Colors.white,
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 5),
    ),
    extensions: <ThemeExtension<CustomThemeColors>>[
      CustomThemeColors.light(),
    ],
    dividerTheme: const DividerThemeData(thickness: 0.6, color: NoorTheme.line),
    // Tabs as the web app's segmented control: green text, gold underline.
    tabBarTheme: TabBarThemeData(
      dividerColor: Colors.transparent,
      labelColor: color,
      unselectedLabelColor: const Color(0xFF555555),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      indicatorColor: NoorTheme.gold,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: const UnderlineTabIndicator(borderSide: BorderSide(color: NoorTheme.gold, width: 3)),
    ),
  );
}
