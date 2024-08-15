//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. Use of this
// source code is governed by an MIT-style license that can be found in the
// LICENSE file.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:df_debouncer/df_debouncer.dart';
import 'package:flutter/material.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

void main() {
  runApp(App());
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'df_debouncer Example',
      home: DebouncerExample(),
    );
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class DebouncerExample extends StatefulWidget {
  const DebouncerExample({super.key});
  @override
  State<DebouncerExample> createState() => _DebouncerExampleState();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _DebouncerExampleState extends State<DebouncerExample> {
  //
  //
  //

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  //
  //
  //

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

  //
  //
  //

  @override
  void dispose() {
    // Immediately save the form to the database when the page is closed.
    _autosave.finalize();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  //
  //
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('df_debouncer Example'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name:',
            ),
            // Tigger the autosave when the form changes.
            onChanged: (_) => _autosave(),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email:',
            ),
            onChanged: (_) => _autosave(),
          ),
        ],
      ),
    );
  }
}
