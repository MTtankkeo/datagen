import 'package:test/test.dart';
import 'package:datagen/annotation.dart';

import 'sample/enum.dart';

@datagen
class TestEnum {
  const TestEnum({required dynamic value});

  @override
  Enums get value {
    return Enums.values.firstWhere((e) => e.key == super.value);
  }
}

void main() {
  test("Checks if a getter can be overridden using @override", () async {
    expect(TestEnum(value: "a").value, Enums.a);
    expect(TestEnum(value: "b").value, Enums.b);
    expect(TestEnum(value: "c").value, Enums.c);
  });
}
