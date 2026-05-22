//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:df_debouncer/df_debouncer.dart';
import 'package:flutter/material.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

void main() {
  runApp(const App());
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class App extends StatelessWidget {
  const App({super.key});

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
    onStart: () {
      debugPrint('Saving form...');
    },
    onWaited: () {
      final name = _nameController.text;
      final email = _emailController.text;
      debugPrint(
        'Form saved to database: {"name": "$name", "email": "$email"}',
      );
    },
    onCall: () {
      debugPrint('Form changed!');
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
      appBar: AppBar(title: const Text('df_debouncer Example')),
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name:'),
            // Tigger the autosave when the form changes.
            onChanged: (_) => _autosave(),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email:'),
            onChanged: (_) => _autosave(),
          ),
        ],
      ),
    );
  }
}
