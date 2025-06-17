## Summary

A package that provides a practical Debouncer for optimizing performance by controlling the frequency of function calls in response to rapid events.

## Example

```dart
// Create a debouncer to automatically save a form to the database after some delay.
late final _autosave = Debouncer(
  delay: const Duration(milliseconds: 500),
   onStart: () {
      print('Saving form...');
    },
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