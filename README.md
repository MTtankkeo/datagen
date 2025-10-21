# Introduction
A Dart CLI tool for analyzer-based, extremely fast, and clean **data class** code generation.

> Parses Dart code into an AST using only the Dart analyzer, building classes completely independently of build_runner, achieving unparalleled build speed **(🚀 Takes 5 ~ 10ms per file on average)**.

## Support
`🟢 Supported` `🟡 Planned` `🔴 Not Supported`

| Future | Status | Usage |
| ------ | ------ | ----- |
| 🔒 Immutability | 🟢 | Required |
| 🔄 copyWith (Clone) | 🟢 | @Datagen(copyWith: true) |
| 📦 JSON serialization | 🟢 | @Datagen(fromJson: true, fromJsonList: true, toJson: true) |
| ⚖️ Equality check | 🟡 | |
| 🔑 hashCode | 🟡 | |
| 📝 Stringify | 🟢 | @Datagen(stringify: true) |

## Preview
![preview](https://github.com/user-attachments/assets/aa776d77-0967-4dd7-9e18-008a78d69c19)

## Usage
Learn how to quickly set up and use this library for generating data classes.

### Annotate Your Class
Use the `@datagen` or `@Datagen()` annotation on your class:

```dart
@datagen
class A {
  const A({
    required String a,
    int b = 3,
    int? c,
  });
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
| omitFactory | Controls whether a fromJson factory is generated in the public class. The factory in the generated .datagen.dart class is always created. | false |

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
