import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("SecondScreen"),
      ),
      body: const Center(
        child: Text("Nice"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.backspace),
      ),
    );
  }
}
