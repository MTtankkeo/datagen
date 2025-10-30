import 'package:datagen/annotation.dart';

import 'single_field.dart';

part 'multi_fields.datagen.dart';

@datagen
class TestRawTypes {
  const TestRawTypes({
    required int a,
    required double b,
    required num c,
    required bool d,
    required String e,
    required dynamic f,
  });
}

@datagen
class TestObject {
  const TestObject({
    required TestRawTypes a,
    required TestInt b,
    required TestNum c,
    required TestBool d,
    required TestString e,
    required TestDynamic f,
  });
}
