## Using VSCode

You can configure VSCode to automatically run `dart run datagen build --watch` whenever you open the project folder. This keeps your code generation up-to-date without manually starting the command each time. Additionally, you can hide the generated `.datagen.dart` files in VSCode for a cleaner workspace.

### Steps

1. In the root of your project, create a folder named `.vscode` if it doesn’t already exist.

2. Inside the `.vscode` folder, create a file called `tasks.json` with the following content:

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

3. Optionally, create a `settings.json` file in the same `.vscode` folder to hide generated `.datagen.dart` files:

```json
{
  "files.exclude": {
    "**/*.datagen.dart": true
  }
}
```

> With this configuration, VSCode will automatically run Datagen in watch mode when you open the project, and your editor won’t show the generated files in the file explorer.