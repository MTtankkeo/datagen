# Introduction
A Dart CLI tool for analyzer-based, extremely fast, and clean **data class** code generation.

> Parses Dart code into an AST using only the Dart analyzer, building classes completely independently of build_runner, achieving unparalleled build speed **(🚀 Takes 5 ~ 10ms per file on average)**.

## Support
`🟢 Supported` `🟡 Planned` `🔴 Not Supported`

| Future | Status | Usage |
| ------ | ------ | ----- |
| 🔒 Immutability | 🟢 | It's still required |
| 🗝️ Private fields | 🟢 | Support private fields with getters. |
| 🔄 copyWith (Clone) | 🟢 | @Datagen(copyWith: true) |
| 📦 JSON serialization | 🟢 | @Datagen(fromJson: true, fromJsonList: true, toJson: true) |
| 📝 Stringify | 🟢 | @Datagen(stringify: true) |
| ⚖️ Equality | 🟢 | @Datagen(equality: true) |

## Preview
<img width="4408" alt="preview" src="https://github.com/user-attachments/assets/57d20180-2df3-447c-8622-b8553f25e9a8" />

### Development
> When developing, there’s no need to follow any special format like **freezed** or **mappable**. As long as you write proper **const constructors**, the **Datagen** library builder will automatically adjust the code to fit standard Dart conventions. Also, it’s highly recommended to use the `watch` feature during development!

![preview-development](https://github.com/user-attachments/assets/33c09246-0ec8-44e1-b9f0-28ef95e8cb1c)

## Usage
Learn how to quickly set up and use this library for generating data classes.

### Annotate Your Class
The following is an example of using the `@datagen` or `@Datagen()` annotation on a class. 

> Applying this annotation enables Datagen to generate utility features such as `copyWith`, 
JSON serialization, stringify, and equality overrides based on the configuration options.

```dart
@Datagen(omitFactory: true)
class A {
  const A({
    required String name,
    int age = 20,
    DateTime? dateTime,
    required dynamic status,

    // Specifies the target type to convert the field to using `@Get`.
    // Only needs to indicate the target type and the actual type in the data class.
    @Get(int) required String minute,
  });

  // Use `dynamic` and a custom getter for fields not supported by `@Get`, 
  // e.g., the `status` field may require custom conversion.
  @override
  Enum get status {...}
}
```

### Build the Data Class
Generate the code using:

```bash
dart run datagen build
```

### Using Watch Mode
Automatically rebuild on file changes:

```bash
dart run datagen watch
```

> [!TIP]
> **Build Integration:** To integrate and manage build processes with tools like [resourcegen](https://github.com/MTtankkeo/resourcegen), learn how to use [Prepare](https://github.com/MTtankkeo/prepare) effectively.

### Options
Arguments for the `@Datagen()` annotation.

| Name | Description | Default |
| ---- | ----------- | ------- |
| copyWith | Enables generating a copyWith method for the annotated class. | true |
| fromJson | Enables generating a fromJson factory constructor. | true |
| toJson | Enables generating a toJson method. | true |
| stringify | Enables generating a toString override method. | true |
| equality | Enables generating a hashCode and operator == override. | true |
| omitFactory | Controls whether a fromJson factory is generated in the public class. The factory in the generated .datagen.dart class is always created. | false |

## How to Set Config File?
Create a file named `datagen.json` in the folder where you run the CMD command, and write the following configuration inside:

```json
{
    "options": {
        "copyWith": true,
        "fromJson": true,
        "fromJsonList": true,
        "toJson": true,
        "stringify": true,
        "omitFactory": false
    },
    "useCommand": true
}
```

## IDE Settings Guide
This table provides quick access to IDE-specific tips and guides.

| IDE | Docs |
| --- | ---- |
| Visual Studio Code | [VSCODE_GUIDE.md](docs/VSCODE_GUIDE.md) |
