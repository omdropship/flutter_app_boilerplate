import 'package:flutter/material.dart';

void main() {
  runApp(const ChatTemanApp());
}

class ChatTemanApp extends StatelessWidget {
  const ChatTemanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatTeman',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatTeman'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'ChatTeman',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Aplikasi berhasil dijalankan',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ChatTeman siap digunakan'),
                  ),
                );
              },
              child: const Text('Tes Aplikasi'),
            ),
          ],
        ),
      ),
    );
  }
}
