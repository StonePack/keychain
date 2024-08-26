import 'package:flutter/foundation.dart';
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
  final TextEditingController controller = TextEditingController();

  Future<void> deleteValue() async {
    final bool? success = await Keymaster.delete(
      'test_key_auth',
      authRequired: true,
    );

    controller.text = 'delete: $success';
  }

  Future<void> fetchValue() async {
    final String? value = await Keymaster.fetch(
      'test_key_auth',
      authRequired: true,
    );

    controller.text = 'fetched: $value';
  }

  Future<void> saveValue() async {
    final bool? success = await Keymaster.set(
      'test_key_auth',
      controller.text,
      authRequired: true,
    );

    if (kDebugMode) print('keychain save success: $success');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: saveValue,
                  child: const Text('Save to Keychain'),
                ),
                const SizedBox(width: 20),
                MaterialButton(
                  onPressed: fetchValue,
                  child: const Text('Read from Keychain'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: deleteValue,
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
