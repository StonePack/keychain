import 'package:flutter/material.dart';

import 'package:keymaster/keymaster.dart';

void main() {
  runApp(const KeychainExample());
}

class KeychainExample extends StatefulWidget {
  const KeychainExample({super.key});

  @override
  State<KeychainExample> createState() => _KeychainExampleState();
}

class _KeychainExampleState extends State<KeychainExample> {
  @override
  void initState() {
    super.initState();
    // Keymaster.set('test_key', 'this is NEW test data');
    Keymaster.fetch('test_key');
    // Keymaster.delete('test_key');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: Text('Running keychain test'),
        ),
      ),
    );
  }
}
