import 'dart:math';
import 'package:flutter/material.dart';

class ThreadMergeProof extends StatefulWidget {
  const ThreadMergeProof({super.key});

  @override
  State<ThreadMergeProof> createState() => _ThreadMergeProofState();
}

class _ThreadMergeProofState extends State<ThreadMergeProof> {
  String _status = "대기 중";

  void _blockMainThread() {
    setState(() => _status = "⚠️ 메인 스레드 차단 중... (창을 움직여보세요)");

    // 화면에 글자가 렌더링될 틈을 주기 위해 0.1초 뒤 실행
    Future.delayed(const Duration(milliseconds: 100), () {
      // 🔴 [핵심] CPU를 100% 쓰면서 5초간 멈춤 (Blocking)
      // sleep과 달리 이건 '연산'이라서 프로파일러에 'Dart 실행 중'으로 확실히 찍힘
      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsedMilliseconds < 5000) {
        sqrt(12345.6789); // 무의미한 계산 반복
      }

      setState(() => _status = "차단 해제됨");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // 멈추는지 확인용
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _blockMainThread,
              child: const Text("5초간 메인 스레드 죽이기"),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "버튼을 누르고 즉시 창(Window)을 드래그해보세요.\n\n"
                "v3.27: 창은 움직임 (Platform 살아있음)\n"
                "v3.38: 창도 안 움직임 (Platform 죽음)",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}
//
// class ThreadMergeProofTest extends StatefulWidget {
//   const ThreadMergeProofTest({super.key});
//
//   @override
//   State<ThreadMergeProofTest> createState() => _ThreadMergeProofTestState();
// }
//
// class _ThreadMergeProofTestState extends State<ThreadMergeProofTest> {
//   bool _isFrozen = false;
//
//   void _freezeApp() {
//     setState(() {
//       _isFrozen = true;
//     });
//
//     // 💡 잠시 후 실행하여 사용자가 마우스를 움직일 틈을 줍니다.
//     Future.delayed(const Duration(milliseconds: 500), () {
//       print("❄️ FREEZE START: 3초간 멈춥니다.");
//
//       // 🔴 [핵심] Dart 스레드를 3초간 강제로 정지시킴 (Blocking)
//       sleep(const Duration(seconds: 5));
//
//       print("✅ FREEZE END: 풀렸습니다.");
//       setState(() {
//         _isFrozen = false;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _isFrozen ? Colors.red.shade100 : Colors.white,
//       appBar: AppBar(
//         title: const Text("Thread Merge 증명 테스트"),
//         backgroundColor: _isFrozen ? Colors.red : Colors.blue,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 시각적 확인용 인디케이터
//             if (_isFrozen)
//               const Icon(Icons.error, size: 80, color: Colors.red)
//             else
//               const CircularProgressIndicator(),
//
//             const SizedBox(height: 30),
//
//             const Text(
//               "테스트 방법:\n1. 아래 버튼을 누르세요.\n2. 0.5초 뒤 앱이 빨간색이 되며 멈춥니다.\n3. 그때 즉시 [창 제목 표시줄]을 잡고 흔들어보세요.",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16),
//             ),
//
//             const SizedBox(height: 30),
//
//             ElevatedButton.icon(
//               onPressed: _isFrozen ? null : _freezeApp,
//               icon: const Icon(Icons.ac_unit),
//               label: const Text(
//                 "3초간 얼리기 (Main Thread Blocking)",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
