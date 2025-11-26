import 'package:flutter/material.dart';
import 'package:flutter_thread_merge/rust_image_page.dart';
import 'package:flutter_thread_merge/src/rust/api/simple.dart';
import 'package:flutter_thread_merge/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RustImageTest()
    );
  }
}
