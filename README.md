# Dart Package Template

Dart & Flutter Packages by DevCetra.com & contributors.

[![pub package](https://img.shields.io/pub/v/df_debouncer.svg)](https://pub.dev/packages/df_debouncer)

## Summary

A package that provides a practical Debouncer for optimizing performance by controlling the frequency of function calls in response to rapid events.

## Usage Example

```dart
// Create the debouncer to automatically save a form to the database after
// some delay..
late final _autosave = Debouncer(
  delay: const Duration(milliseconds: 500),
  onWaited: () {
    final name = _nameController.text;
    final email = _emailController.text;
    print('Form saved to database: {"name": "$name", "email": "$email"}');
  },
  onCall: () {
    print('Form changed!');
  },
);

// Tigger the autosave when the form changes.
TextField(
  controller: _emailController,
  decoration: const InputDecoration(
    labelText: 'Email:',
   ),
  onChanged: (_) => _autosave(),
),

// Immediately save the form to the database when the page is closed.
@override
void dispose() {
  _autosave.finalize();
  super.dispose();
}
```

For a full feature set, please refer to the [API reference](https://pub.dev/documentation/df_debouncer/).

## Installation

Use this package as a dependency by adding it to your `pubspec.yaml` file (see [here](https://pub.dev/packages/df_debouncer/install)).

## Contributing and Discussions

This is an open-source project, and contributions are welcome from everyone, regardless of experience level. Contributing to projects is a great way to learn, share knowledge, and showcase your skills to the community. Join the discussions to ask questions, report bugs, suggest features, share ideas, or find out how you can contribute.

### Join GitHub Discussions:

💬 https://github.com/robmllze/df_debouncer/discussions/

### Join Reddit Discussions:

💬 https://www.reddit.com/r/df_debouncer/

### Chief Maintainer:

📧 Email _Robert Mollentze_ at robmllze@gmail.com

## License

This project is released under the MIT License. See [LICENSE](https://raw.githubusercontent.com/robmllze/df_debouncer/main/LICENSE) for more information.
