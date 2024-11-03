import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<String> yesterdayMeals = [];
  List<String> todayMeals = [];
  List<String> tomorrowMeals = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    fetchAllMealInfo();
  }

  Future<void> fetchAllMealInfo() async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      // 네트워크 연결이 없을 경우 로딩 상태를 false로 설정하고 알림 표시
      if (!mounted) return;

      setState(() {
        isLoading = false; // 로딩 상태를 false로 설정
      });

      // 네트워크 연결이 없을 경우 알림 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('네트워크 연결 문제'),
            content: const Text('네트워크 연결을 확인해 주세요.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      return; // 함수 종료
    }

    // 네트워크 연결이 있을 경우 로딩 상태를 true로 설정
    setState(() {
      isLoading = true;
    });

    DateTime today = DateTime.now();
    String todayDate = formatDate(today);
    String yesterdayDate = formatDate(today.subtract(const Duration(days: 1)));
    String tomorrowDate = formatDate(today.add(const Duration(days: 1)));

    try {
      yesterdayMeals = await fetchMealInfo(yesterdayDate);
      todayMeals = await fetchMealInfo(todayDate);
      tomorrowMeals = await fetchMealInfo(tomorrowDate);
    } catch (error) {
      // API 호출 중 오류 발생 시 처리
      if (!mounted) return;

      setState(() {
        isLoading = false; // 로딩 상태를 false로 설정
      });

      // 오류 메시지 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('급식 정보를 불러오는 데 실패했습니다. \n네트워크 연결을 확인해주세요.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      return; // 함수 종료
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    // 초기 스크롤 위치를 '오늘의 급식' 카드의 비율로 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cardHeight = 0.58 * MediaQuery.of(context).size.height; // 카드 높이 58%
      const spacing = 25.0; // 카드 사이의 간격
      final scrollToPosition = cardHeight + spacing; // 스크롤 위치 계산

      _scrollController.animateTo(
        scrollToPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }




  Future<List<String>> fetchMealInfo(String date) async {
    final response = await http.get(Uri.parse(
        'https://open.neis.go.kr/hub/mealServiceDietInfo?ATPT_OFCDC_SC_CODE=J10&SD_SCHUL_CODE=7530616&KEY=0c41a0d911c641eea80238819c3ae790&TYPE=JSON&MLSV_YMD=$date'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['mealServiceDietInfo'] != null &&
          data['mealServiceDietInfo'].isNotEmpty) {
        List<String> meals = [];
        for (var meal in data['mealServiceDietInfo'][1]['row']) {
          if (meal['DDISH_NM'] != null && meal['CAL_INFO'] != null) {
            // HTML 태그 제거 후 줄바꿈 추가
            String mealInfo = '${removeHtmlTags(meal['DDISH_NM'])} (${meal['CAL_INFO']})';
            meals.add(addLineBreakAfterParenthesis(mealInfo));
          }
        }
        return meals;
      } else {
        return [];
      }
    } else {
      throw Exception('API를 통해 급식 정보를 불러오는 데 실패했습니다.');
    }
  }

  String removeHtmlTags(String htmlString) {
    final RegExp regExp = RegExp(r'<[^>]*>');
    return htmlString.replaceAll(regExp, '');
  }

  String addLineBreakAfterParenthesis(String text) {
    return text.replaceAll(')', ')\n');
  }

  String formatDate(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day
        .toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 높이와 너비 가져오기
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return SafeArea(
      child: isLoading
          ? const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
          ),
          SizedBox(height: 16),
          Text('급식 정보를 불러오는 중입니다...',
              style: TextStyle(fontSize: 18, color: Colors.white54, fontFamily: 'Noto Sans Korean', fontWeight: FontWeight.w500),),
        ],
      ),
      )
          : ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        children: [
          buildMealCard(yesterdayMeals, '［ 어제의 급식식단 ］', screenHeight, screenWidth),
          const SizedBox(height: 25),
          buildMealCard(todayMeals, '［ 오늘의 급식식단 ］', screenHeight, screenWidth),
          const SizedBox(height: 25),
          buildMealCard(tomorrowMeals, '［ 내일의 급식식단 ］', screenHeight, screenWidth),
        ],
      ),
    );
  }

  Widget buildMealCard(List<String> meals, String title, double screenHeight,
      double screenWidth) {
    return Container(
      width: screenWidth * 0.9, // 화면 너비의 90%
      height: screenHeight * 0.65, // 화면 높이의 25%
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 30, color: Colors.black87, fontFamily: 'Noto Sans Korean', fontWeight: FontWeight.w700 ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              meals.isNotEmpty
                  ? meals.join(', ')
                  : '정보가 없습니다.',
              style: const TextStyle(
                  fontSize: 20, color: Color(0xFFdc0025), fontFamily: 'Noto Sans Korean', fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}