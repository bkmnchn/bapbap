// signup.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  String _selectedColor = '파란색'; // 기본 색깔 설정

  Future<List<String>> _loadStudentIds() async {
    final rawData = await rootBundle.loadString('assets/csv/VaildHakbun.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
    return csvTable.map((row) => row[0].toString()).toList(); // 첫 번째 열의 데이터 반환
  }

  Future<void> _signup() async {
    String studentId = _studentIdController.text.trim();
    String password = _passwordController.text.trim();

    if (studentId.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = '모든 필드를 채워주세요.';
      });
      return;
    }
    // 비밀번호 길이 체크
    if (password.length != 4) {
      setState(() {
        _errorMessage = '비밀번호는 반드시 4자리 수여야 합니다.';
      });
      return;
    }

    // CSV 파일에서 학번 리스트 불러오기
    List<String> validStudentIds = await _loadStudentIds();
    if (!validStudentIds.contains(studentId)) {
      setState(() {
        _errorMessage = '유효하지 않은 학번입니다.';
      });
      return;
    }

    // 중복 체크
    final studentIdExists = await FirebaseFirestore.instance
        .collection('students')
        .where('studentId', isEqualTo: studentId)
        .get();

    if (studentIdExists.docs.isNotEmpty) {
      setState(() {
        _errorMessage = '이 학번은 이미 등록되어 있습니다.';
      });
      return;
    }

    try {
      // Firestore에 데이터 추가
      await FirebaseFirestore.instance.collection('students').add({
        'studentId': studentId,
        'password': password,
        'color': _selectedColor, // 선택한 색깔 저장
      });

      if (!mounted) return;
      Navigator.pop(context); // 회원가입 후 페이지 돌아가기
    } catch (e) {
      setState(() {
        _errorMessage = '회원가입 중 오류가 발생했습니다: $e';
      });
    }
  }

  void _selectColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _colorOption(context, const Color(0xff294ce6), '파란색'),
                _colorOption(context, const Color(0xffFF1493), '핑크색'),
                _colorOption(context, const Color(0xff03a630), '초록색'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Widget _colorOption(BuildContext context, Color color, String colorName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = colorName; // 선택된 색깔 저장
        });
        Navigator.of(context).pop(); // 다이얼로그 닫기
      },
      child: Container(
        width: 100,
        height: 50,
        color: color,
        alignment: Alignment.center,
        child: Text(
          colorName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(labelText: '학번'),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number, // 숫자 키패드 사용
                    maxLength: 5, // 최대 길이 설정
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number, // 일반 키패드 사용
                    maxLength: 4, // 최대 길이 설정
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _selectColor(context), // 색상 선택 버튼
                    child: Text('색상 선택: $_selectedColor',
                      style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Noto Sans Korean',
                          fontWeight: FontWeight.w900),),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signup,
                    child: const Text('회원가입',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Noto Sans Korean',
                          fontWeight: FontWeight.w900),),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // 로그인 페이지로 돌아가기
                    },
                    child: const Text('로그인 페이지로 돌아가기',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Noto Sans Korean',
                          fontWeight: FontWeight.w900),),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}
