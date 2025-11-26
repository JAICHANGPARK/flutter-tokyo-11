import 'package:flutter/material.dart';

class RasterLagTest extends StatefulWidget {
  const RasterLagTest({super.key});

  @override
  State<RasterLagTest> createState() => _RasterLagTestState();
}

class _RasterLagTestState extends State<RasterLagTest> {
  Offset _position = Offset.zero; // 박스의 위치
  bool _isRasterHeavy = false; // Raster 부하 모드

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // 1. 터치/마우스 감지 영역 (전체 화면)
          Positioned.fill(
            child: Listener(
              onPointerHover: (event) {
                setState(() {
                  _position = event.localPosition;
                });
              },
              onPointerMove: (event) {
                setState(() {
                  _position = event.localPosition;
                });
              },
              child: Container(color: Colors.transparent),
            ),
          ),

          // 2. 따라다니는 박스
          Positioned(
            left: _position.dx - 50, // 중앙 정렬
            top: _position.dy - 50,
            child: _buildTestObject(),
          ),

          // 3. 컨트롤 패널
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(blurRadius: 10, color: Colors.black26)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("UI vs Raster Separation Test",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  const Text("마우스를 빠르게 움직여보세요."),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Switch(
                        value: _isRasterHeavy,
                        activeColor: Colors.red,
                        onChanged: (val) {
                          setState(() {
                            _isRasterHeavy = val;
                          });
                        },
                      ),
                      Text(
                        _isRasterHeavy ? "GPU 고문 모드 (Raster Heavy)" : "일반 모드",
                        style: TextStyle(
                          color: _isRasterHeavy ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_isRasterHeavy)
                    const Text(
                      "UI 스레드는 빠르지만,\nRaster 스레드가 느려서\n박스가 뒤늦게 따라옵니다.",
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestObject() {
    // [일반 모드] 가벼운 컨테이너 하나
    if (!_isRasterHeavy) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(50), // 원형
        ),
        child: const Center(
            child: Icon(Icons.mouse, color: Colors.white, size: 40)),
      );
    }

    // [GPU 고문 모드]
    // UI 스레드 부하는 거의 없습니다 (단순 루프).
    // 하지만 Raster 스레드(GPU)는 '그림자'와 '클리핑' 계산 때문에 죽어납니다.
    return Stack(
      children: List.generate(200, (index) {
        return Container(
          width: 100,
          height: 100,
          margin: EdgeInsets.all(index * 0.1), // 약간씩 위치를 꼬아서 더 복잡하게
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.01), // 투명도 겹치기 (GPU 연산 증가)
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              // 그림자는 Raster 스레드에서 가장 비싼 연산 중 하나입니다.
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 10 + index.toDouble(), // 블러 반경을 계속 바꿔서 캐싱 방지
                spreadRadius: 2,
              )
            ],
          ),
        );
      }),
    );
  }
}
