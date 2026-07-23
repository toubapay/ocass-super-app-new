import 'package:eClassify/main.dart';
import 'package:flutter/material.dart';

class TestFile extends StatefulWidget {
  const TestFile({super.key});

  @override
  State<TestFile> createState() => _TestFileState();
}

class _TestFileState extends State<TestFile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: EclassyApp());
  }
}
