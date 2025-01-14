import 'package:flutter_test/flutter_test.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

void main() {
  test('type', () {
    const type = JsonGestureDetectorBuilder.type;

    expect(type, 'gesture_detector');
    expect(
      JsonWidgetRegistry.instance.getWidgetBuilder(type)({})
          is JsonGestureDetectorBuilder,
      true,
    );
  });
}
