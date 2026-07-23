
import 'package:demandium/util/core_export.dart';

extension ContextInfo on BuildContext {
  ThemeData get theme => Theme.of(this);
  CustomThemeColors get customThemeColors => theme.extension<CustomThemeColors>()!;


}