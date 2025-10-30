import 'package:test/test.dart';

import 'sample/multi_fields.dart';
import 'sample/single_field.dart';

void main() {
  final rawTypesModel = TestRawTypes(
    a: 42,
    b: 3.14,
    c: 3,
    d: true,
    e: "Hello, World!",
    f: 42,
  );

  final objectModel = TestObject(
    a: rawTypesModel,
    b: TestInt(value: 42),
    c: TestNum(value: 3.14),
    d: TestBool(value: false),
    e: TestString(value: "Hello, World!"),
    f: TestDynamic(value: true),
  );

  test("Serializes all primitive fields correctly", () {
    final json = {
      "a": 42,
      "b": 3.14,
      "c": 3,
      "d": true,
      "e": "Hello, World!",
      "f": 42,
    };

    expect(rawTypesModel.toJson(), json);
    expect($TestRawTypes.fromJson(json), rawTypesModel);
  });

  test("Serializes nested objects correctly", () {
    final json = {
      "a": {
        "a": 42,
        "b": 3.14,
        "c": 3,
        "d": true,
        "e": "Hello, World!",
        "f": 42,
      },
      "b": {"value": 42},
      "c": {"value": 3.14},
      "d": {"value": false},
      "e": {"value": "Hello, World!"},
      "f": {"value": true},
    };

    expect(objectModel.toJson(), json);
    expect($TestObject.fromJson(json), objectModel);
  });

  test("Serializes nested objects correctly", () {
    final clone = objectModel.copyWith(
      a: rawTypesModel.copyWith(a: 69, e: "Changed"),
      b: TestInt(value: 256),
      e: TestString(value: "Modified"),
    );

    // Verify that the clone has the updated values.
    expect(clone.a.a, 69);
    expect(clone.a.e, "Changed");
    expect(clone.b.value, 256);
    expect(clone.e.value, "Modified");

    // Verify that the original object remains unchanged. (immutability check)
    expect(objectModel.a.a, 42);
    expect(objectModel.a.e, "Hello, World!");
    expect(objectModel.b.value, 42);
    expect(objectModel.e.value, "Hello, World!");
  });
}
