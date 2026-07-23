import 'dart:ui';
import 'package:demandium/feature/booking/widget/timeline/indicator_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'connector_theme.dart';
import 'timelines.dart';

/// Applies a theme to descendant timeline widgets.
///
/// A theme describes the colors and typographic choices of an application.
///
/// Descendant widgets obtain the current theme's [TimelineThemeData] object
/// using [TimelineTheme.of]. When a widget uses [TimelineTheme.of], it is
/// automatically rebuilt if the theme later changes, so that the changes can be
/// applied.
///
/// See also:
///
///  * [TimelineThemeData], which describes the actual configuration of a theme.
class TimelineTheme extends StatelessWidget {
  /// Applies the given theme [data] to [child].
  ///
  /// The [data] and [child] arguments must not be null.
  const TimelineTheme({
    super.key,
    required this.data,
    required this.child,
  });

  /// Specifies the direction for descendant widgets.
  final TimelineThemeData data;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  static final TimelineThemeData _kFallbackTheme = TimelineThemeData.fallback();

  /// The data from the closest [TimelineTheme] instance that encloses the given
  /// context.
  ///
  /// Defaults to [ThemeData.fallback] if there is no [Theme] in the given
  /// build context.
  ///
  /// When the [TimelineTheme] is actually created in the same `build` function
  /// (possibly indirectly, e.g. as part of a [Timeline]), the `context`
  /// argument to the `build` function can't be used to find the [TimelineTheme]
  /// (since it's "above" the widget being returned). In such cases, the
  /// following technique with a [Builder] can be used to provide a new scope
  /// with a [BuildContext] that is "under" the [TimelineTheme]:
  ///
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   // TODO: replace to Timeline
  ///   return TimelineTheme(
  ///     data: TimelineThemeData.vertical(),
  ///     child: Builder(
  ///       // Create an inner BuildContext so that we can refer to the Theme with TimelineTheme.of().
  ///       builder: (BuildContext context) {
  ///         return Center(
  ///           child: TimelineNode(
  ///             direction: TimelineTheme.of(context).direction,
  ///             child: Text('Example'),
  ///           ),
  ///         );
  ///       },
  ///     ),
  ///   );
  /// }
  /// ```
  static TimelineThemeData of(BuildContext context) {
    final inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<_InheritedTheme>();
    return inheritedTheme?.theme.data ?? _kFallbackTheme;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedTheme(
      theme: this,
      child: IndicatorTheme(
        data: data.indicatorTheme,
        child: child,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<TimelineThemeData>('data', data, showName: false));
  }
}

class _InheritedTheme extends InheritedTheme {
  const _InheritedTheme({
    required this.theme,
    required super.child,
  });

  final TimelineTheme theme;

  @override
  Widget wrap(BuildContext context, Widget child) {
    final ancestorTheme =
        context.findAncestorWidgetOfExactType<_InheritedTheme>();
    return identical(this, ancestorTheme)
        ? child
        : TimelineTheme(data: theme.data, child: child);
  }

  @override
  bool updateShouldNotify(_InheritedTheme old) => theme.data != old.theme.data;
}


@immutable
class TimelineThemeData with Diagnosticable {

  factory TimelineThemeData({
    Axis? direction,
    Color? color,
    double? nodePosition,
    bool? nodeItemOverlap,
    double? indicatorPosition,
    IndicatorThemeData? indicatorTheme,
    ConnectorThemeData? connectorTheme,
  }) {
    direction ??= Axis.vertical;
    color ??= Colors
        .blue; // TODO: Need to change the default color to the theme color?
    nodePosition ??= 0.5;
    nodeItemOverlap ??= false;
    indicatorPosition ??= 0.5;
    indicatorTheme ??= const IndicatorThemeData();
    connectorTheme ??= const ConnectorThemeData();
    return TimelineThemeData.raw(
      direction: direction,
      color: color,
      nodePosition: nodePosition,
      nodeItemOverlap: nodeItemOverlap,
      indicatorPosition: indicatorPosition,
      indicatorTheme: indicatorTheme,
      connectorTheme: connectorTheme,
    );
  }

  factory TimelineThemeData.fallback() => TimelineThemeData.vertical();

  const TimelineThemeData.raw({
    required this.direction,
    required this.color,
    required this.nodePosition,
    required this.nodeItemOverlap,
    required this.indicatorPosition,
    required this.indicatorTheme,
    required this.connectorTheme,
  });


  factory TimelineThemeData.vertical() => TimelineThemeData(
        direction: Axis.vertical,
      );


  factory TimelineThemeData.horizontal() => TimelineThemeData(
        direction: Axis.horizontal,
      );


  final Axis direction;
  final Color color;
  final double nodePosition;
  final bool nodeItemOverlap;
  final double indicatorPosition;
  final IndicatorThemeData indicatorTheme;

  final ConnectorThemeData connectorTheme;

  TimelineThemeData copyWith({
    Axis? direction,
    Color? color,
    double? nodePosition,
    bool? nodeItemOverlap,
    double? indicatorPosition,
    IndicatorThemeData? indicatorTheme,
    ConnectorThemeData? connectorTheme,
  }) {
    return TimelineThemeData.raw(
      direction: direction ?? this.direction,
      color: color ?? this.color,
      nodePosition: nodePosition ?? this.nodePosition,
      nodeItemOverlap: nodeItemOverlap ?? this.nodeItemOverlap,
      indicatorPosition: indicatorPosition ?? this.indicatorPosition,
      indicatorTheme: indicatorTheme ?? this.indicatorTheme,
      connectorTheme: connectorTheme ?? this.connectorTheme,
    );
  }

  static TimelineThemeData lerp(
      TimelineThemeData a, TimelineThemeData b, double t) {
    return TimelineThemeData.raw(
      direction: t < 0.5 ? a.direction : b.direction,
      color: Color.lerp(a.color, b.color, t)!,
      nodePosition: lerpDouble(a.nodePosition, b.nodePosition, t)!,
      nodeItemOverlap: t < 0.5 ? a.nodeItemOverlap : b.nodeItemOverlap,
      indicatorPosition:
          lerpDouble(a.indicatorPosition, b.indicatorPosition, t)!,
      indicatorTheme:
          IndicatorThemeData.lerp(a.indicatorTheme, b.indicatorTheme, t),
      connectorTheme:
          ConnectorThemeData.lerp(a.connectorTheme, b.connectorTheme, t),
    );
  }


  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final defaultData = TimelineThemeData.fallback();
    properties
      ..add(DiagnosticsProperty<Axis>('direction', direction,
          defaultValue: defaultData.direction, level: DiagnosticLevel.debug))
      ..add(ColorProperty('color', color,
          defaultValue: defaultData.color, level: DiagnosticLevel.debug))
      ..add(DoubleProperty('nodePosition', nodePosition,
          defaultValue: defaultData.nodePosition, level: DiagnosticLevel.debug))
      ..add(FlagProperty('nodeItemOverlap',
          value: nodeItemOverlap, ifTrue: 'overlap connector and indicator'))
      ..add(DoubleProperty('indicatorPosition', indicatorPosition,
          defaultValue: defaultData.indicatorPosition,
          level: DiagnosticLevel.debug))
      ..add(DiagnosticsProperty<IndicatorThemeData>(
        'indicatorTheme',
        indicatorTheme,
        defaultValue: defaultData.indicatorTheme,
        level: DiagnosticLevel.debug,
      ))
      ..add(DiagnosticsProperty<ConnectorThemeData>(
        'connectorTheme',
        connectorTheme,
        defaultValue: defaultData.connectorTheme,
        level: DiagnosticLevel.debug,
      ));
  }


}
