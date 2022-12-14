import 'package:child_builder/child_builder.dart';
import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_theme/json_theme.dart';

/// Builder that can build an [ClipRect] widget.  See the [fromDynamic] for the
/// format.
class JsonClipRectBuilder extends JsonWidgetBuilder {
  const JsonClipRectBuilder({
    required this.clipBehavior,
    this.clipper,
  }) : super(numSupportedChildren: kNumSupportedChildren);

  static const kNumSupportedChildren = 1;

  static const type = 'clip_rect';

  final Clip clipBehavior;
  final CustomClipper<Rect>? clipper;

  /// Builds the builder from a Map-like dynamic structure.  This expects the
  /// JSON format to be of the following structure:
  ///
  /// ```json
  /// {
  ///   "clipBehavior": "<Clip>",
  ///   "clipper": "<CustomClipper<Rect>>"
  /// }
  /// ```
  ///
  /// See also:
  ///  * [ThemeDecoder.decodeClip]
  static JsonClipRectBuilder? fromDynamic(
    dynamic map, {
    JsonWidgetRegistry? registry,
  }) {
    JsonClipRectBuilder? result;

    if (map != null) {
      result = JsonClipRectBuilder(
        clipBehavior: ThemeDecoder.decodeClip(
              map['clipBehavior'],
              validate: false,
            ) ??
            Clip.hardEdge,
        clipper: map['clipper'],
      );
    }

    return result;
  }

  @override
  Widget buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  }) {
    final child = getChild(data);

    return ClipRect(
      clipBehavior: clipBehavior,
      clipper: clipper,
      key: key,
      child: child.build(
        childBuilder: childBuilder,
        context: context,
      ),
    );
  }
}
