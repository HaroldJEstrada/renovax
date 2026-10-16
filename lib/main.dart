import 'package:flutter/material.dart';

void main() => runApp(const RenovaxApp());

class RenovaxApp extends StatelessWidget {
  const RenovaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renovax',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Renovax')),
        body: const Center(child: Text('Bienvenido a Renovax')),
      ),
    );
  }
}
