import 'dart:convert';

import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

void main() {
  test('params', () {
    var registry = JsonWidgetRegistry(
      values: {
        'one': 1,
        'false': false,
        'string': 'foo',
        'true': true,
        'twoPointFive': 2.5,
      },
    );

    expect(
      registry.processDynamicArgs({
        'one': '{{one}}',
        'false': '{{false}}',
        'string': '{{string}}',
        'true': '{{true}}',
        'twoPointFive': '{{twoPointFive}}',
        'constant': 'constant',
      }),
      DynamicParamsResult(
        dynamicKeys: {'one', 'false', 'string', 'true', 'twoPointFive'},
        values: {
          'one': 1,
          'false': false,
          'string': 'foo',
          'true': true,
          'twoPointFive': 2.5,
          'constant': 'constant',
        },
      ),
    );

    expect(
      registry.processDynamicArgs([
        '{{one}}',
        '{{false}}',
        '{{string}}',
        '{{true}}',
        '{{twoPointFive}}',
        'constant'
      ]),
      DynamicParamsResult(
        dynamicKeys: {'one', 'false', 'string', 'true', 'twoPointFive'},
        values: [
          1,
          false,
          'foo',
          true,
          2.5,
          'constant',
        ],
      ),
    );
    expect(
      registry.processDynamicArgs({
        'nested': {
          'one': '{{one}}',
          'false': '{{false}}',
          'string': '{{string}}',
          'true': '{{true}}',
          'twoPointFive': '{{twoPointFive}}'
        },
      }),
      DynamicParamsResult(
        dynamicKeys: {'one', 'false', 'string', 'true', 'twoPointFive'},
        values: {
          'nested': {
            'one': 1,
            'false': false,
            'string': 'foo',
            'true': true,
            'twoPointFive': 2.5,
          },
        },
      ),
    );
  });

  test('function', () {
    String? result;
    var registry = JsonWidgetRegistry(
      functions: {
        'test': ({args, required registry}) {
          result = args?.toList().join('|');

          return result;
        }
      },
      values: {
        'one': 1,
        'false': false,
        'string': 'foo',
        'true': true,
        'twoPointFive': 2.5,
      },
    );

    expect(
      registry.processDynamicArgs('##test()##'),
      DynamicParamsResult(
        dynamicKeys: {'__FUNCTION__'},
        values: '',
      ),
    );
    expect(result, '');

    expect(
      registry.processDynamicArgs('##test({{one}})##'),
      DynamicParamsResult(
        dynamicKeys: {'__FUNCTION__', 'one'},
        values: '1',
      ),
    );
    expect(result, '1');

    expect(
      registry.processDynamicArgs('##test(foo)##'),
      DynamicParamsResult(
        dynamicKeys: {'__FUNCTION__'},
        values: 'foo',
      ),
    );
    expect(result, 'foo');

    expect(
      registry.processDynamicArgs({
        'nested': {
          'foo': '##test(foo, {{one}})##',
          'bar': '{{twoPointFive}}',
        },
      }),
      DynamicParamsResult(
        dynamicKeys: {'__FUNCTION__', 'one', 'twoPointFive'},
        values: {
          'nested': {
            'foo': 'foo|1',
            'bar': 2.5,
          },
        },
      ),
    );
    expect(result, 'foo|1');

    expect(
      registry.processDynamicArgs({
        'nested': {
          'foo':
              '##test( {{one}}, {{false}} ,  {{string}}, {{true}}, {{twoPointFive}}, constant  )##',
        },
      }),
      DynamicParamsResult(
        dynamicKeys: {
          '__FUNCTION__',
          'one',
          'false',
          'string',
          'true',
          'twoPointFive'
        },
        values: {
          'nested': {
            'foo': '1|false|foo|true|2.5|constant',
          },
        },
      ),
    );
    expect(result, '1|false|foo|true|2.5|constant');

    expect(
      registry.processDynamicArgs({
        'nested': [
          'foo',
          '##test( cons tant, {{one}}, {{false}} ,  {{string}}, {{true}}, {{twoPointFive}}, constant  )##',
          '{{one}}',
        ],
      }),
      DynamicParamsResult(
        dynamicKeys: {
          '__FUNCTION__',
          'one',
          'false',
          'string',
          'true',
          'twoPointFive'
        },
        values: {
          'nested': [
            'foo',
            'cons tant|1|false|foo|true|2.5|constant',
            1,
          ],
        },
      ),
    );
    expect(result, 'cons tant|1|false|foo|true|2.5|constant');
  });

  test('internal variable', () {
    /// This registry is overriding the built-in value of
    /// `bounce_in_curve`
    var registry = JsonWidgetRegistry(
      values: {
        'bounce_in_curve': Curves.bounceInOut,
      },
    );

    expect(
      registry.processDynamicArgs(
        {
          'bounce_in_curve': '{{bounce_in_curve}}',
        },
      ),
      DynamicParamsResult(
        dynamicKeys: {'bounce_in_curve'},
        values: {
          'bounce_in_curve': Curves.bounceInOut,
        },
      ),
    );

    expect(
      registry.processDynamicArgs(
        {
          'decelerate_curve': '{{decelerate_curve}}',
        },
      ),
      DynamicParamsResult(
        dynamicKeys: {'decelerate_curve'},
        values: {
          'decelerate_curve': Curves.decelerate,
        },
      ),
    );
  });

  test('json path', () {
    var people = [
      {
        'firstName': 'John',
        'lastName': 'Smith',
        'address': {
          'street': '1234 Lane Ave',
          'city': 'Springfield',
          'state': 'OH',
        }
      },
      {
        'firstName': 'Jane',
        'lastName': 'Smith',
        'address': {
          'street': '1234 Lane Ave',
          'city': 'Springfield',
          'state': 'MI',
        }
      },
    ];

    var registry = JsonWidgetRegistry(values: {'people': people});

    expect(
      registry.getValue(r'people;$[0].firstName'),
      'John',
    );
    expect(
      registry.getValue(r'people;$[1].address.state'),
      'MI',
    );

    expect(
      registry.getValue(r'people;$'),
      people,
    );

    registry = JsonWidgetRegistry(values: {'people': json.encode(people)});

    expect(
      registry.getValue(r'people;$[0].firstName'),
      'John',
    );
    expect(
      registry.getValue(r'people;$[1].address.state'),
      'MI',
    );

    expect(
      registry.getValue(r'people;$'),
      people,
    );
  });
}
