// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'card_data.dart';
import 'sub/card_page.dart';
import 'sub/geupsik.dart';
import 'sub/logout.dart';
import 'login.dart';
import 'signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider<CardData>(
      create: (context) => CardData(), // CardData Provider 생성
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project',
      theme: ThemeData(
        primaryColor: const Color(0xFF2f3937),
        scaffoldBackgroundColor: const Color(0xFF2f3937),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0x08090b0b),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const LoginPage(),
      routes: {
        '/main': (context) => const MyHomePage(),
        '/signup': (context) => const SignupPage(), // SignupPage 경로 추가
        '/login': (context) => const LoginPage(),
      },
    );
  }
}


// main.dart

// main.dart

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String? studentId; // studentId를 저장할 변수

  final List<Widget> _pages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      studentId = args['studentId'];
      String color = args['color'];

      // FirstPage 생성 시 studentId와 색깔 전달
      _pages.add(FirstPage(studentId: studentId!, color: color)); // 색깔을 추가로 전달
      _pages.add(const SecondPage());
      _pages.add(const FourthPage());
    }
  }
  // 나머지 코드...



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'S.Card',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: '오늘의 급식',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '알레르기 항목',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
