import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../card_data.dart';

class FirstPage extends StatefulWidget {
  final String studentId;
  final String color;

  const FirstPage({super.key, required this.studentId, required this.color});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool isBack = true;
  double angle = 0;
  bool isLoading = true; // 로딩 상태 추가
  bool isConnected = true; // 연결 상태 추가

  @override
  void initState() {
    super.initState();
    _checkConnection(); // 연결 상태 확인
  }

  Future<void> _checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
      isLoading = false; // 로딩 완료
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardData = Provider.of<CardData>(context);
    List<Color> cardColors = _getGradientColors(widget.color) ?? [Colors.blue, Colors.blueAccent];

    // 화면 크기 가져오기
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // 카드 비율 조정 (예: 80%의 너비와 60%의 높이)
    final cardWidth = screenWidth * 0.7;
    final cardHeight = screenHeight * 0.65;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator()); // 로딩 중일 때
    }

    if (!isConnected) {
      return const Center(child: Text('네트워크에 연결되지 않았습니다.', style: TextStyle(color: Colors.red, fontSize: 30))); // 연결이 없을 때
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                angle = (angle + pi) % (2 * pi);
                isBack = !isBack;
              });
            },
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: angle),
              duration: const Duration(milliseconds: 700),
              builder: (BuildContext context, double val, __) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(val),
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: LinearGradient(
                        colors: cardColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: isBack ? 1.0 : 0.0,
                          child: Container(
                            child: const Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sangil',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 57,
                                        fontFamily: 'Nerko One',
                                        fontWeight: FontWeight.w900,
                                        height: 1.0,
                                      ),
                                    ),
                                    Text(
                                      'Lunch',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 57,
                                        fontFamily: 'Nerko One',
                                        fontWeight: FontWeight.w900,
                                        height: 1.0,
                                      ),
                                    ),
                                    Text(
                                      'Card',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 57,
                                        fontFamily: 'Nerko One',
                                        fontWeight: FontWeight.w900,
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: isBack ? 0.0 : 1.0,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      cardData.name ?? '상일고등학교',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontFamily: 'Noto Sans Korean',
                                        fontWeight: FontWeight.w900,
                                        height: 2.0,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      widget.studentId,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 50,
                                        fontFamily: 'Noto Sans Korean',
                                        fontWeight: FontWeight.w900,
                                        height: 0.1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Color>? _getGradientColors(String? color) {
    switch (color) {
      case '파란색':
        return [const Color(0xff294ce6), const Color(0xff6a9eff)];

      case '핑크색':
        return [const Color(0xffFF1493), const Color(0xffff6f91)];

      case '초록색':
        return [const Color(0xff03a630), const Color(0xff87d99b)];
      default:
        return null;
    }
  }
}
