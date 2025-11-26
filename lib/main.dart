// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

// // The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.
//
// // // The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.
// //
// // // // The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.
// // //
// // // // // The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.
// // // //
// // // // // // The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.
// // // // //
// // // // // // import 'dart:io';
// // // // // // import 'package:flutter/foundation.dart'; // compute 함수
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter_thread_merge/raster_test_page.dart';
// // // // // // import 'package:flutter_thread_merge/resize_page.dart';
// // // // // // import 'package:flutter_thread_merge/thread_merge_proof.dart';
// // // // // //
// // // // // // void main() {
// // // // // //   runApp(const MaterialApp(home: ThreadMergeProofTest()));
// // // // // // }
// // // // // //
// // // // //
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter_thread_merge/src/rust/api/simple.dart';
// // // // // import 'package:flutter_thread_merge/src/rust/frb_generated.dart';
// // // // //
// // // // // Future<void> main() async {
// // // // //   await RustLib.init();
// // // // //   runApp(const MyApp());
// // // // // }
// // // // //
// // // // // class MyApp extends StatelessWidget {
// // // // //   const MyApp({super.key});
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return MaterialApp(
// // // // //       home: Scaffold(
// // // // //         appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
// // // // //         body: Center(
// // // // //           child: Text(
// // // // //               'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // //
// // // //
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_thread_merge/src/rust/api/simple.dart';
// // // // import 'package:flutter_thread_merge/src/rust/frb_generated.dart';
// // // // import 'package:flutter_thread_merge/thread_merge_proof.dart';
// // // //
// // // // import 'rust_image_page.dart';
// // // //
// // // // Future<void> main() async {
// // // //   // await RustLib.init();
// // // //   runApp(const MyApp());
// // // // }
// // // //
// // // // class MyApp extends StatelessWidget {
// // // //   const MyApp({super.key});
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       home: ThreadMergeProof()
// // // //     );
// // // //   }
// // // // }
// // // //
// // //
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_thread_merge/src/rust/api/simple.dart';
// // // import 'package:flutter_thread_merge/src/rust/frb_generated.dart';
// // //
// // // import 'frb_thread_merge_proof.dart';
// // //
// // // Future<void> main() async {
// // //   await RustLib.init();
// // //   runApp(const MyApp());
// // // }
// // //
// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       home: FrbThreadTestPage(),
// // //     );
// // //   }
// // // }
// // //
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_thread_merge/src/rust/api/simple.dart';
// // import 'package:flutter_thread_merge/src/rust/frb_generated.dart';
// //
// // Future<void> main() async {
// //   await RustLib.init();
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
// //         body: Center(
// //           child: Text(
// //               'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
//
// import 'package:flutter/material.dart';
// import 'package:flutter_thread_merge/src/rust/api/simple.dart';
// import 'package:flutter_thread_merge/src/rust/frb_generated.dart';
//
// Future<void> main() async {
//   await RustLib.init();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
//         body: Center(
//           child: Text(
//               'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
//         ),
//       ),
//     );
//   }
// }
//

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
