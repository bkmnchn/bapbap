import 'package:flutter/material.dart';


class FourthPage extends StatefulWidget {
  const FourthPage({super.key});

  @override
  State<FourthPage> createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  final List<String> allergies = ['1. 난류', '2. 우유', '3. 메밀', '4. 땅콩', '5. 대두', '6. 밀', '7. 고등어', '8. 게', '9. 새우', '10. 돼지고기', '11. 복숭아', '12. 토마토', '13. 아황산류', '14. 호두', '15. 닭고기', '16. 쇠고기', '17. 오징어', '18. 조개류(굴, 전복, 홍합 포함)', '19. 잣',  ];

  @override
  Widget build(BuildContext context) {
    // 화면 크기 가져오기
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '알레르기 항목',
              style: TextStyle(
                color: Color(0xE6FFFFFF),
                fontSize: 30,
                fontFamily: 'Noto Sans Korean',
                fontWeight: FontWeight.w900,
              ),
            ),
            // 알레르기 항목을 카드 형태로 표시
            Card(
              margin: const EdgeInsets.all(16.0),
              color: Colors.black12, // 카드 배경색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // 모서리 둥글게
              ),
              child: SizedBox(
                width: screenSize.width * 0.8, // 화면 너비의 80%
                height: screenSize.height * 0.5, // 원하는 높이 설정
                child: ListView.builder(
                  itemCount: allergies.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0), // 카드 내 항목 간격
                      child: Text(
                        allergies[index],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 23,
                          fontFamily: 'Noto Sans Korean',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20), // 카드와 버튼 사이의 간격
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 40), // 최소 크기 설정 (너비, 높이)
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 패딩 설정
                backgroundColor: const Color(0xB3FFFFFF),
              ),
              onPressed: _logout,
              child: const Text(
                '계정 로그아웃',
                style: TextStyle(
                  fontFamily: 'Noto Sans Korean',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }
}
