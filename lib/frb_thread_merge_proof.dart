import 'package:flutter/material.dart';

import 'src/rust/api/simple.dart';

class FrbThreadTestPage extends StatefulWidget {
  const FrbThreadTestPage({super.key});

  @override
  State<FrbThreadTestPage> createState() => _FrbThreadTestPageState();
}

class _FrbThreadTestPageState extends State<FrbThreadTestPage> {
  String _status = "버튼을 눌러보세요";
  bool _isWorking = false;

  // CASE 1: 안전한 비동기 호출 (Future)
  Future<void> _runAsync() async {
    setState(() {
      _isWorking = true;
      _status = "Rust(Async) 실행 중... \n(로딩바가 돌아야 함)";
    });

    // 🚀 Rust가 백그라운드 스레드에서 돌기 때문에 await을 해도 UI는 멈추지 않음
    final result = await rustHeavyWorkAsync();

    setState(() {
      _isWorking = false;
      _status = result;
    });
  }

  // CASE 2: 위험한 동기 호출 (Sync)
  void _runSync() {
    setState(() {
      _isWorking = true;
      _status = "Rust(Sync) 실행 중... \n(앱 멈출 것임)";
    });

    // 화면 갱신을 위해 약간 딜레이 (안 그러면 텍스트 바뀌기도 전에 멈춤)
    Future.delayed(const Duration(milliseconds: 100), () {
      // 🔴 Rust 함수를 메인 스레드에서 바로 실행!
      // 이 줄에서 3초간 앱이 '얼음' 상태가 됩니다.
      final result = rustHeavyWorkSync();

      setState(() {
        _isWorking = false;
        _status = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FRB Thread Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // UI 스레드 생존 확인용 뺑뺑이
            if (_isWorking)
              const CircularProgressIndicator()
            else
              const Icon(Icons.check_circle, size: 50, color: Colors.green),

            const SizedBox(height: 30),
            Text(_status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 50),

            // 버튼 1: Async
            ElevatedButton(
              onPressed: _isWorking ? null : _runAsync,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text("1. Rust Async 실행 (안전)"),
            ),
            const SizedBox(height: 20),

            // 버튼 2: Sync
            ElevatedButton(
              onPressed: _isWorking ? null : _runSync,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text("2. Rust Sync 실행 (위험 - UI 멈춤)"),
            ),
          ],
        ),
      ),
    );
  }
}
