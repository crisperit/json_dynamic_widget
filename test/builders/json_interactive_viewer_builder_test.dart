import 'package:flutter_test/flutter_test.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

void main() {
  test('type', () {
    const type = JsonInteractiveViewerBuilder.type;

    expect(type, 'interactive_viewer');
    expect(
      JsonWidgetRegistry.instance.getWidgetBuilder(type)({})
          is JsonInteractiveViewerBuilder,
      true,
    );
  });
}
