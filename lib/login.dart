// login.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _login() async {
    String studentId = _studentIdController.text.trim();
    String password = _passwordController.text.trim();

    if (studentId.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = '모든 필드를 채워주세요.';
      });
      return;
    }

    // Firestore에서 학번과 비밀번호 확인
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('studentId', isEqualTo: studentId)
        .where('password', isEqualTo: password)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // 색깔 정보 가져오기
      String color = snapshot.docs.first['color'] ?? '파란색';

      // 로그인 성공 시 사용자 정보 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('studentId', studentId);
      await prefs.setString('color', color);

      // 로그인 성공: MyHomePage로 이동하고 studentId 및 color 전달
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main',
          arguments: {'studentId': studentId, 'color': color});
    } else {
      // 로그인 실패: 오류 메시지 표시
      setState(() {
        _errorMessage = '학번 또는 비밀번호가 올바르지 않습니다.\n또는 네트워크 연결을 확인하세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView( // 추가된 부분
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.1,),
              Image.asset('assets/logo/logo.png', height: screenHeight * 0.15,),
              const SizedBox(height: 10,),
              const Text('밥밥이',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jua',
                  fontSize: 30),
              ),
              TextField(
                controller: _studentIdController,
                decoration: const InputDecoration(labelText: '학번'),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                maxLength: 5,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('로그인',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Noto Sans Korean',
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 30,),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text('회원 가입하기', style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Noto Sans Korean',
                    fontWeight: FontWeight.w900,
                    fontSize: 17
                ),

                ),
              ),
              const SizedBox(height: 15,),
              const Text('상일고등학교',
                style: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Noto Sans Korean',
                    fontWeight: FontWeight.w500,
                    fontSize: 18),
              ),
              const SizedBox(height: 8,),
              const Text('1인 개발: 박민찬',
                style: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Noto Sans Korean',
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
              const Text('Flutter Dart, Android Studio',
                style: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Noto Sans Korean',
                    fontWeight: FontWeight.w500,
                    fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}