import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/rust/api/simple.dart' as rust_api;
import 'src/rust/api/simple.dart';

class RustImagePage extends StatefulWidget {
  const RustImagePage({super.key});

  @override
  State<RustImagePage> createState() => _RustImagePageState();
}

class _RustImagePageState extends State<RustImagePage> {
  Uint8List? _originalImage;
  Uint8List? _processedImage;
  bool _isProcessing = false;
  String _status = "画像を読み込んでください。";

  // 1. 예제 이미지를 로드하는 함수
  Future<void> _loadImage() async {
    // assets에 있는 이미지를 바이트로 읽어옴
    final byteData = await rootBundle.load('assets/dash.png');
    setState(() {
      _originalImage = byteData.buffer.asUint8List();
      _processedImage = null;
      _status = "処理準備完了";
    });
  }

  // 2. Rust에게 일을 시키는 함수
  Future<void> _runRustProcessing() async {
    if (_originalImage == null) return;

    setState(() {
      _isProcessing = true;
      _status = "Rustが白黒/ぼかし処理中... (UIは止まらない)";
    });

    try {
      // 🚀 [핵심] Rust 함수 호출
      // flutter_rust_bridge 덕분에 이 호출은 '비동기(Future)'로 동작합니다.
      // 즉, UI 스레드를 막지 않고 백그라운드 스레드에서 Rust가 돕니다.
      // (만약 Raw FFI 동기 호출이었다면 여기서 앱이 멈췄을 것입니다.)
      final result =
          await rust_api.processImageHeavy(imageData: _originalImage!);

      setState(() {
        _processedImage = result;
        _status = "処理完了! (Rust Power 🦀)";
      });
    } catch (e) {
      setState(() => _status = "エラー発生: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter + Rust Image Processing")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 상태 메시지 & 로딩 인디케이터
            Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(), // Rust가 일하는 동안 뱅글뱅글 돌아야 함
              ),
            const SizedBox(height: 20),

            // 이미지 비교 (Before & After)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageBox(_originalImage, "オリジナル"),
                _buildImageBox(_processedImage, "Rust処理結果"),
              ],
            ),
            const SizedBox(height: 30),

            // 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loadImage,
                  child: const Text("画像読み込み"),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _runRustProcessing,
                  icon: const Icon(Icons.build),
                  label: const Text("Rustで変換"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBox(Uint8List? data, String label) {
    return Column(
      children: [
        Text(label),
        Container(
          width: 150,
          height: 150,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: data == null
              ? const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey))
              : Image.memory(data, fit: BoxFit.cover, gaplessPlayback: true),
        ),
      ],
    );
  }
}


class RustImageTest extends StatefulWidget {
  const RustImageTest({super.key});

  @override
  State<RustImageTest> createState() => _RustImageTestState();
}

class _RustImageTestState extends State<RustImageTest> {
  Uint8List? _imageBytes;
  bool _isProcessing = false;
  String _status = "画像を読み込んでください。";

  @override
  void initState() {
    super.initState();
    _loadImage(); // 시작하자마자 이미지 로드
  }

  Future<void> _loadImage() async {
    // assets에 고화질 이미지를 넣어두고 테스트하세요 (ex: 4K 이미지)
    final data = await rootBundle.load('assets/dash.png');
    setState(() {
      _imageBytes = data.buffer.asUint8List();
      _status = "準備完了";
    });
  }

  // ✅ CASE 1: Async (비동기) - 안전함
  Future<void> _runAsync() async {
    if (_imageBytes == null) return;
    setState(() {
      _isProcessing = true;
      _status = "Async処理中... (ローディングバーは動いていますか？)";
    });

    // 🚀 Rust가 백그라운드에서 돕니다. UI 스레드 자유!
    final result = await applyFilterAsync(imageData: _imageBytes!);

    setState(() {
      _imageBytes = result;
      _isProcessing = false;
      _status = "Async完了! (スムーズでした)";
    });
  }

  // ❌ CASE 2: Sync (동기) - 위험함
  void _runSync() {
    if (_imageBytes == null) return;
    setState(() {
      _isProcessing = true;
      _status = "Sync処理中... (フリーズ発生!)";
    });

    // 화면 갱신할 시간을 주기 위해 0.1초 뒤 실행
    Future.delayed(const Duration(milliseconds: 100), () {

      // 💣 여기서 CPU가 100% 돌면서 메인 스레드를 점유합니다.
      // 이미지 크기에 따라 1~3초간 앱이 완전히 멈춥니다.
      final result = applyFilterSync(imageData: _imageBytes!);

      setState(() {
        _imageBytes = result;
        _isProcessing = false;
        _status = "Sync完了! (フリーズしました)";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FRB Image Processing Test")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 상태 표시 및 로딩바
            Text(_status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_isProcessing)
              const CircularProgressIndicator() // 멈추는지 확인하는 용도
            else
              const Icon(Icons.check_circle, color: Colors.green, size: 40),

            const SizedBox(height: 20),
            // 이미지 표시
            if (_imageBytes != null)
              Image.memory(
                _imageBytes!,
                height: 300,
                gaplessPlayback: true,
              )
            else
              const SizedBox(height: 300, child: Center(child: Text("画像がありません"))),

            const SizedBox(height: 30),

            // 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isProcessing ? null : _runAsync,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: const Text("Async (安全)"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _runSync,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text("Sync (危険 - Main Blocking)"),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Syncボタンを押してウィンドウのタイトルバーをドラッグしてみてください。", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}