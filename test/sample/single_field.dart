import 'package:datagen/annotation.dart';

part 'single_field.datagen.dart';

@datagen
class TestInt {
  const TestInt({required int value});
}

@datagen
class TestDouble {
  const TestDouble({required double value});
}

@datagen
class TestNum {
  const TestNum({required num value});
}

@datagen
class TestBool {
  const TestBool({required bool value});
}

@datagen
class TestString {
  const TestString({required String value});
}

@datagen
class TestDynamic {
  const TestDynamic({required dynamic value});
}

@datagen
class TestObjectWithInt {
  const TestObjectWithInt({required TestInt value});
}

@datagen
class TestObjectWithDouble {
  const TestObjectWithDouble({required TestDouble value});
}

@datagen
class TestObjectWithNum {
  const TestObjectWithNum({required TestNum value});
}

@datagen
class TestObjectWithBool {
  const TestObjectWithBool({required TestBool value});
}

@datagen
class TestObjectWithString {
  const TestObjectWithString({required TestString value});
}

@datagen
class TestObjectWithDynamic {
  const TestObjectWithDynamic({required TestDynamic value});
}
