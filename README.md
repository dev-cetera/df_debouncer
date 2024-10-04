# DF - Debouncer

<a href="https://www.buymeacoffee.com/robmllze" target="_blank"><img align="right" src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

Dart & Flutter Packages by DevCetra.com & contributors.

[![pub package](https://img.shields.io/pub/v/df_debouncer.svg)](https://pub.dev/packages/df_debouncer)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/robmllze/df_debouncer/main/LICENSE)

## Summary

A package that provides a practical Debouncer for optimizing performance by controlling the frequency of function calls in response to rapid events.

## Usage Example

```dart
// Create a debouncer to automatically save a form to the database after some delay.
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

---

## Contributing and Discussions

This is an open-source project, and we warmly welcome contributions from everyone, regardless of experience level. Whether you're a seasoned developer or just starting out, contributing to this project is a fantastic way to learn, share your knowledge, and make a meaningful impact on the community.

### Ways you can contribute:

- **Buy me a coffee:** If you'd like to support the project financially, consider [buying me a coffee](https://www.buymeacoffee.com/robmllze). Your support helps cover the costs of development and keeps the project growing.
- **Share your ideas:** Every perspective matters, and your ideas can spark innovation.
- **Report bugs:** Help us identify and fix issues to make the project more robust.
- **Suggest improvements or new features:** Your ideas can help shape the future of the project.
- **Help clarify documentation:** Good documentation is key to accessibility. You can make it easier for others to get started by improving or expanding our documentation.
- **Write articles:** Share your knowledge by writing tutorials, guides, or blog posts about your experiences with the project. It's a great way to contribute and help others learn.

No matter how you choose to contribute, your involvement is greatly appreciated and valued!

---

### Chief Maintainer:

📧 Email _Robert Mollentze_ at robmllze@gmail.com

### Dontations:

If you're enjoying this package and find it valuable, consider showing your appreciation with a small donation. Every bit helps in supporting future development. You can donate here:

https://www.buymeacoffee.com/robmllze

---

## License

This project is released under the MIT License. See [LICENSE](https://raw.githubusercontent.com/robmllze/df_debouncer/main/LICENSE) for more information.
