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
<img width="3449" alt="preview" src="https://github.com/user-attachments/assets/5ffe11c0-aef5-46a4-9f15-e1f8bdfdfeda" />

### Development
> When developing, there’s no need to follow any special format like **freezed** or **mappable**. As long as you write proper **const constructors**, the **Datagen** library builder will automatically adjust the code to fit standard Dart conventions. Also, it’s highly recommended to use the `--watch` feature during development!

![preview-development](https://github.com/user-attachments/assets/aa776d77-0967-4dd7-9e18-008a78d69c19)

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
dart run datagen build --watch
```

### Options
Arguments for the `@Datagen()` annotation.

| Name | Description | Default |
| ---- | ----------- | ------- |
| copyWith | Enables generating a copyWith method for the annotated class. | true |
| fromJson | Enables generating a fromJson factory constructor. | true |
| toJson | Enables generating a toJson method. | true |
| stringify | Enables generating a toString override method. | true |
| equality | Enables generating a `hashCode` and `operator ==` override. | true |
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

## Using VSCode
You can configure VSCode to automatically run dart run datagen build --watch whenever you open the project folder. This is useful for keeping your code generation up-to-date without manually starting the command each time.

### Steps:
1. In the root of your project, create a folder named `.vscode` if it doesn’t already exist.

2. Inside the .vscode folder, create a file called `tasks.json`.

3. Copy and paste the following content into tasks.json:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run Datagen Watch",
      "type": "shell",
      "command": "dart",
      "args": ["run", "datagen", "build", "--watch"],
      "problemMatcher": [],
      "runOptions": {
        "runOn": "folderOpen"
      },
      "presentation": {
        "echo": true,
        "reveal": "silent",
        "focus": false,
        "panel": "dedicated"
      }
    }
  ]
}
```
