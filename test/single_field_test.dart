import 'package:test/test.dart';

import 'sample/single_field.dart';

void main() {
  group("toJson() method converts various field types to JSON correctly", () {
    test("int toJson()", () {
      expect(TestInt(value: 42).toJson(), {"value": 42});
    });

    test("double toJson()", () {
      expect(TestDouble(value: 3.14).toJson(), {"value": 3.14});
    });

    test("num with int toJson()", () {
      expect(TestNum(value: 42).toJson(), {"value": 42});
    });

    test("num with double toJson()", () {
      expect(TestNum(value: 3.14).toJson(), {"value": 3.14});
    });

    test("bool true toJson()", () {
      expect(TestBool(value: true).toJson(), {"value": true});
    });

    test("bool false toJson()", () {
      expect(TestBool(value: false).toJson(), {"value": false});
    });

    test("String toJson()", () {
      expect(TestString(value: "Hello, World!").toJson(),
          {"value": "Hello, World!"});
    });

    test("dynamic with int toJson()", () {
      expect(TestDynamic(value: 42).toJson(), {"value": 42});
    });

    test("dynamic with double toJson()", () {
      expect(TestDynamic(value: 3.14).toJson(), {"value": 3.14});
    });

    test("dynamic with bool toJson()", () {
      expect(TestDynamic(value: true).toJson(), {"value": true});
    });

    test("dynamic with string toJson()", () {
      expect(TestDynamic(value: "Hello, World!").toJson(),
          {"value": "Hello, World!"});
    });
  });

  group("fromJson() method parses various JSON field types correctly", () {
    test("int fromJson()", () {
      final json = {"value": 42};
      final obj = $TestInt.fromJson(json);
      expect(obj.value, 42);
    });

    test("double fromJson()", () {
      final json = {"value": 3.14};
      final obj = $TestDouble.fromJson(json);
      expect(obj.value, 3.14);
    });

    test("num with int fromJson()", () {
      final json = {"value": 42};
      final obj = $TestNum.fromJson(json);
      expect(obj.value, 42);
    });

    test("num with double fromJson()", () {
      final json = {"value": 3.14};
      final obj = $TestNum.fromJson(json);
      expect(obj.value, 3.14);
    });

    test("bool true fromJson()", () {
      final json = {"value": true};
      final obj = $TestBool.fromJson(json);
      expect(obj.value, true);
    });

    test("bool false fromJson()", () {
      final json = {"value": false};
      final obj = $TestBool.fromJson(json);
      expect(obj.value, false);
    });

    test("String fromJson()", () {
      final json = {"value": "Hello, World!"};
      final obj = $TestString.fromJson(json);
      expect(obj.value, "Hello, World!");
    });

    test("dynamic with int fromJson()", () {
      final json = {"value": 42};
      final obj = $TestDynamic.fromJson(json);
      expect(obj.value, 42);
    });

    test("dynamic with double fromJson()", () {
      final json = {"value": 3.14};
      final obj = $TestDynamic.fromJson(json);
      expect(obj.value, 3.14);
    });

    test("dynamic with bool fromJson()", () {
      final json = {"value": true};
      final obj = $TestDynamic.fromJson(json);
      expect(obj.value, true);
    });

    test("dynamic with string fromJson()", () {
      final json = {"value": "Hello, World!"};
      final obj = $TestDynamic.fromJson(json);
      expect(obj.value, "Hello, World!");
    });
  });

  group("copyWith() method creates a clone with updated fields correctly", () {
    test("int copyWith()", () {
      final origin = TestInt(value: 42);
      final clone = origin.copyWith(value: 100);
      expect(clone.value, 100);
      expect(origin.value, 42);
    });

    test("double copyWith()", () {
      final origin = TestDouble(value: 3.14);
      final clone = origin.copyWith(value: 2.71);
      expect(clone.value, 2.71);
      expect(origin.value, 3.14);
    });

    test("num with int copyWith()", () {
      final origin = TestNum(value: 42);
      final clone = origin.copyWith(value: 99);
      expect(clone.value, 99);
      expect(origin.value, 42);
    });

    test("num with double copyWith()", () {
      final origin = TestNum(value: 3.14);
      final clone = origin.copyWith(value: 1.618);
      expect(clone.value, 1.618);
      expect(origin.value, 3.14);
    });

    test("bool copyWith()", () {
      final origin = TestBool(value: true);
      final clone = origin.copyWith(value: false);
      expect(clone.value, false);
      expect(origin.value, true);
    });

    test("string copyWith()", () {
      final origin = TestString(value: "Hello");
      final clone = origin.copyWith(value: "World");
      expect(clone.value, "World");
      expect(origin.value, "Hello");
    });

    test("dynamic copyWith()", () {
      final origin = TestDynamic(value: 42);
      final clone = origin.copyWith(value: "Changed");
      expect(clone.value, "Changed");
      expect(origin.value, 42);
    });
  });
}
