// ---------------------------------------------------------
// 1. 무거운 작업 함수
// ---------------------------------------------------------
// 10억 번 반복문을 돌려서 시간을 끄는 함수입니다.
// Isolate로 보낼 것이므로 최상위(Top-level) 함수로 선언했습니다.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

int heavyTask(int loopCount) {
  int total = 0;
  for (int i = 0; i < loopCount; i++) {
    total += i;
  }
  return total;
}

// ---------------------------------------------------------
// 2. UI 위젯
// ---------------------------------------------------------
class IsolateComparisonApp extends StatefulWidget {
  const IsolateComparisonApp({super.key});

  @override
  State<IsolateComparisonApp> createState() => _IsolateComparisonAppState();
}

class _IsolateComparisonAppState extends State<IsolateComparisonApp> {
  String _resultText = '버튼을 눌러보세요';
  bool _isCalculating = false;

  // CASE 1: Isolate 사용 (compute) - 화면 안 멈춤
  Future<void> _runWithIsolate() async {
    setState(() {
      _isCalculating = true;
      _resultText = 'Isolate로 계산 중... (애니메이션이 부드러움)';
    });

    // 🟢 별도의 스레드(Isolate)에서 실행
    int result = await compute(heavyTask, 1000000000);

    setState(() {
      _isCalculating = false;
      _resultText = 'Isolate 결과: $result';
    });
  }

  // CASE 2: Isolate 미사용 (메인 스레드) - 화면 멈춤!
  Future<void> _runWithoutIsolate() async {
    setState(() {
      _isCalculating = true;
      _resultText = '메인 스레드에서 계산 중... (화면 멈춤!)';
    });

    // 💡 중요: setState가 화면을 그릴 틈을 주기 위해 아주 잠깐 대기
    // 이걸 안 하면 "로딩 중" 글자도 뜨기 전에 멈춰버릴 수 있음
    await Future.delayed(const Duration(milliseconds: 100));

    // 🔴 메인 스레드(UI 스레드)에서 직접 실행
    // 이 함수가 끝날 때까지 UI 스레드는 아무것도 못 합니다. (그리기, 터치 등 불가)
    int result = heavyTask(1000000000);

    setState(() {
      _isCalculating = false;
      _resultText = '메인 스레드 결과: $result';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Isolate vs Main Thread 비교')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("현재 버전: ${Platform.version}",
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 30),

            // 로딩 인디케이터: UI 스레드가 살아있는지 죽었는지 판별하는 기준
            if (_isCalculating)
              const CircularProgressIndicator()
            else
              const Icon(Icons.check_circle, size: 50, color: Colors.green),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _resultText,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),

            // 버튼 1: 부드러운 처리
            ElevatedButton.icon(
              onPressed: _isCalculating ? null : _runWithIsolate,
              icon: const Icon(Icons.speed),
              label: const Text('Isolate 사용 (compute)\n화면 안 멈춤'),
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
            ),

            const SizedBox(height: 20),

            // 버튼 2: 화면 멈춤
            ElevatedButton.icon(
              onPressed: _isCalculating ? null : _runWithoutIsolate,
              icon: const Icon(Icons.block, color: Colors.red),
              label: const Text('Isolate 미사용 (Main Thread)\n화면 멈춤 (랙 발생)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
