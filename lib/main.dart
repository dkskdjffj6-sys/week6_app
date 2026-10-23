import 'package:flutter/material.dart';
import 'views/metacognition_screen.dart';

void main() {
  runApp(const MetaCheckApp());
}

class MetaCheckApp extends StatelessWidget {
  const MetaCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetaCheck (메타체크)',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const MetacognitionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}