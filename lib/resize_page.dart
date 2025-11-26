import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

class ResizePerformanceTest extends StatefulWidget {
  const ResizePerformanceTest({super.key});

  @override
  State<ResizePerformanceTest> createState() => _ResizePerformanceTestState();
}

class _ResizePerformanceTestState extends State<ResizePerformanceTest> {
  bool _isHeavyMode = false; // true면 '나쁜 예시' 실행

  @override
  Widget build(BuildContext context) {
    // 1. 화면 크기 감지 (스레드 병합 시, OS의 창 크기 변경과 동기화됨)
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // ⚠️ [위험] Heavy Mode일 때:
    // 화면 크기가 1픽셀 바뀔 때마다 이 무거운 연산이 '메인 스레드'에서 실행됩니다.
    // 스레드가 병합되었기 때문에, 이 연산이 끝날 때까지 창 크기 조절 자체가 버벅거립니다.
    if (_isHeavyMode) {
      _simulateHeavyBuildLogic();
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 패턴 (화면 크기에 따라 실시간 반응)
          _buildResponsivePattern(width, height),

          // 컨트롤 패널
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "창 크기를 마우스로 조절해보세요!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "현재 크기: ${width.toStringAsFixed(0)} x ${height.toStringAsFixed(0)}",
                    style:
                        const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("최적화 모드"),
                      Switch(
                        value: _isHeavyMode,
                        onChanged: (val) {
                          setState(() {
                            _isHeavyMode = val;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      const Text(
                        "렉 유발 모드",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isHeavyMode
                        ? "⚠️ 창 조절 시 마우스가 끊길 수 있습니다.\n(Main Thread Blocking)"
                        : "✅ 창 조절이 부드럽고 쫀득합니다.\n(Synchronous Resize)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isHeavyMode ? Colors.red : Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // [시각적 효과] 화면 크기에 따라 격자 무늬를 그림
  Widget _buildResponsivePattern(double w, double h) {
    // 최적화 모드에서는 const나 가벼운 위젯을 쓰겠지만,
    // 여기서는 변화를 보여주기 위해 Container를 Grid로 배치
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (w / 24).ceil().clamp(1, 24), // 너비에 따라 열 개수 변경
      ),
      itemCount: 1000, // 화면을 채울 정도
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(1),
          color: Colors.blueAccent.withValues(alpha: 0.3),
        );
      },
    );
  }

  // 🔴 [나쁜 예] 억지로 메인 스레드를 잡아먹는 함수
  void _simulateHeavyBuildLogic() {
    // 단순히 시간을 끄는 반복문 (약 5~10ms 부하 가정)
    // 창을 드래그하면 1초에 60번 이상 호출되므로 엄청난 렉 유발
    double sum = 0;
    for (int i = 0; i < 100000000; i++) {
      sum += sqrt(i);
    }
    print("Heavy logic done: $sum"); // 로그를 찍으면 더 느려짐
  }
}

class ExtremeLagTest extends StatefulWidget {
  const ExtremeLagTest({super.key});

  @override
  State<ExtremeLagTest> createState() => _ExtremeLagTestState();
}

class _ExtremeLagTestState extends State<ExtremeLagTest>
    with SingleTickerProviderStateMixin {
  bool _isNuclearLagMode = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 뱅글뱅글 도는 애니메이션 (UI 스레드가 살아있는지 확인용)
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기를 가져옴 (Resize 이벤트 발생 시 build 재호출)
    final size = MediaQuery.of(context).size;

    // 🔴 [핵심] 렉 유발 모드 ON
    if (_isNuclearLagMode) {
      // CPU 속도와 상관없이 무조건 30ms (0.03초) 동안 멈춥니다.
      // 60FPS를 방어하려면 16ms 안에 끝내야 하는데, 30ms를 쉬어버리니
      // 무조건 프레임 드랍이 발생하고 스레드가 차단됩니다.
      sleep(const Duration(milliseconds: 30));
    }

    return Scaffold(
      backgroundColor: _isNuclearLagMode ? Colors.red[50] : Colors.blue[50],
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 배경: 격자 무늬 (리사이즈 시 따라오는지 확인용)
          CustomPaint(
            painter: GridPainter(),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. 애니메이션 인디케이터
                RotationTransition(
                  turns: _controller,
                  child: Icon(
                    Icons.sync,
                    size: 80,
                    color: _isNuclearLagMode ? Colors.red : Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. 현재 상태 텍스트
                Text(
                  _isNuclearLagMode ? "⚠️ NUCLEAR LAG ON ⚠️" : "✅ Smooth Mode",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isNuclearLagMode ? Colors.red : Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Window Size: ${size.width.toInt()} x ${size.height.toInt()}",
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                ),
                const SizedBox(height: 30),

                // 3. 토글 스위치
                SwitchListTile(
                  title: const Text("강제 렉 유발 (sleep 30ms)"),
                  subtitle: const Text("켜는 순간 창 조절이 뻑뻑해집니다."),
                  value: _isNuclearLagMode,
                  onChanged: (value) {
                    setState(() {
                      _isNuclearLagMode = value;
                    });
                  },
                ),

                if (_isNuclearLagMode)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "지금 창 크기를 마우스로 조절해보세요.\n마우스가 창을 못 따라오거나 뚝뚝 끊기면\n'Thread Merge'로 인한 Blocking 현상입니다.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 배경에 격자를 그려주는 페인터
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;

    // 가로선
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // 세로선
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AdvancedResizeTest extends StatefulWidget {
  const AdvancedResizeTest({super.key});

  @override
  State<AdvancedResizeTest> createState() => _AdvancedResizeTestState();
}

class _AdvancedResizeTestState extends State<AdvancedResizeTest> {
  bool _isHeavyMode = false;

  @override
  Widget build(BuildContext context) {
    // 1. 화면 크기 감지
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // 🔴 [렉 유발 로직]
    if (_isHeavyMode) {
      _simulateHeavyBuildLogic();
    }

    // 반응형 변수 설정 (너비에 따라 값 변경)
    bool isWide = width > 700;
    Color responsiveColor;
    String modeText;

    if (width < 500) {
      responsiveColor = Colors.orangeAccent;
      modeText = "Mobile (< 500)";
    } else if (width < 900) {
      responsiveColor = Colors.tealAccent;
      modeText = "Tablet (< 900)";
    } else {
      responsiveColor = Colors.indigoAccent;
      modeText = "Desktop (> 900)";
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 배경 그리드 (기존)
          _buildBackgroundGrid(width),

          // 2. [NEW] 화면 끝과 끝을 잇는 X자 선 (동기화 테스트용)
          CustomPaint(
            painter: XSyncPainter(color: responsiveColor),
            size: Size.infinite,
          ),

          // 3. 메인 컨텐츠 (반응형 레이아웃)
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // 배경 투명도
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: responsiveColor, width: 3),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                // [NEW] 너비에 따라 Row 또는 Column으로 구조 변경
                child: Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 왼쪽(혹은 위) 정보창
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isWide ? Icons.desktop_windows : Icons.smartphone,
                            size: 50,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            modeText,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: responsiveColor.withOpacity(1.0), // 진한 색
                            ),
                          ),
                          Text(
                            "${width.toInt()} x ${height.toInt()}",
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                    // 구분선 (방향에 따라 가로/세로 변경)
                    if (isWide)
                      Container(width: 1, height: 100, color: Colors.grey)
                    else
                      Container(
                          height: 1,
                          width: 100,
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          color: Colors.grey),

                    // 오른쪽(혹은 아래) 컨트롤러
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Thread Blocking Test",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            title: const Text("Heavy Calc"),
                            subtitle: Text(_isHeavyMode
                                ? "LAG ON (Blocking)"
                                : "Smooth (Sync)"),
                            value: _isHeavyMode,
                            activeColor: Colors.red,
                            onChanged: (val) =>
                                setState(() => _isHeavyMode = val),
                          ),
                          if (_isHeavyMode)
                            const Text(
                              "창을 빠르게 조절해보세요.\n배경의 X자가 모서리에서 떨어지거나\n레이아웃 변경이 늦게 따라옵니다.",
                              style: TextStyle(fontSize: 12, color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGrid(double width) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (width / 20).ceil(),
      ),
      itemCount: 5000,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(1),
          color: Colors.grey.withValues(alpha: 0.3),
        );
      },
    );
  }

  void _simulateHeavyBuildLogic() {
    // 부하를 조금 더 늘렸습니다 (확실한 체감을 위해)
    double sum = 0;
    for (int i = 0; i < 100000000; i++) {
      sum += sqrt(i);
    }
  }
}

// [NEW] 화면 네 모서리를 잇는 X자를 그리는 페인터
// 화면 크기가 변할 때마다 즉시 다시 그려져야 함
class XSyncPainter extends CustomPainter {
  final Color color;
  XSyncPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // 왼쪽 위 -> 오른쪽 아래
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);

    // 오른쪽 위 -> 왼쪽 아래
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);

    // 테두리
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), paint..strokeWidth = 10);
  }

  @override
  bool shouldRepaint(covariant XSyncPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class DenseGridResizeTest extends StatefulWidget {
  const DenseGridResizeTest({super.key});

  @override
  State<DenseGridResizeTest> createState() => _DenseGridResizeTestState();
}

class _DenseGridResizeTestState extends State<DenseGridResizeTest> {
  bool _isHeavyMode = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // 🔴 [렉 유발] 촘촘한 그리드는 그리기가 가벼워서 부하를 좀 더 강하게 줬습니다.
    if (_isHeavyMode) {
      _simulateHeavyBuildLogic();
    }

    // 반응형 컬러
    Color themeColor = width > 800 ? Colors.indigo : Colors.teal;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. [NEW] 아주 촘촘한 모눈종이 그리드 (CustomPainter 사용)
          // 위젯이 아니라 선을 직접 그리기 때문에 수천 개를 그려도 빠릅니다.
          const CustomPaint(
            painter: DenseGridPainter(spacing: 10.0), // 10px 간격
            size: Size.infinite,
          ),

          // 2. X자 동기화 선
          CustomPaint(
            painter: XSyncPainter(color: themeColor),
            size: Size.infinite,
          ),

          // 3. 컨트롤 패널
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeColor, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 15, spreadRadius: 2)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Density Grid Test",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: themeColor),
                  ),
                  const SizedBox(height: 5),
                  Text("${size.width.toInt()} x ${size.height.toInt()} px"),
                  const Divider(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Smooth"),
                      Switch(
                        value: _isHeavyMode,
                        activeColor: Colors.red,
                        onChanged: (v) => setState(() => _isHeavyMode = v),
                      ),
                      const Text("LAG (Blocking)",
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "격자가 촘촘할수록\n'울렁거림(Moire)'이나 '끊김'이\n더 잘 보입니다.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateHeavyBuildLogic() {
    // 그리드 그리기가 워낙 빨라서, 렉을 느끼려면 부하를 충분히 줘야 합니다.
    double sum = 0;
    for (int i = 0; i < 8000000; i++) {
      sum += sqrt(i);
    }
  }
}

// 🖌️ [핵심] 촘촘한 그리드를 그리는 페인터
class DenseGridPainter extends CustomPainter {
  final double spacing; // 격자 간격 (작을수록 촘촘함)

  const DenseGridPainter({this.spacing = 10.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05) // 아주 연한 회색
      ..strokeWidth = 1.0; // 얇은 선

    // 1. 세로선 그리기
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 2. 가로선 그리기
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant DenseGridPainter oldDelegate) => false;
}
