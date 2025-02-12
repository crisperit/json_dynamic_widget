import 'package:flutter_test/flutter_test.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

void main() {
  test('type', () {
    const type = JsonOutlinedButtonBuilder.type;

    expect(type, 'outlined_button');
    expect(
      JsonWidgetRegistry.instance.getWidgetBuilder(type)({})
          is JsonOutlinedButtonBuilder,
      true,
    );
  });
}
