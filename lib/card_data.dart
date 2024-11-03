// card_data.dart

import 'package:flutter/material.dart';

class CardData with ChangeNotifier {
  String? color;
  String? name; // name 필드 추가

  void setColor(String newColor) {
    color = newColor;
    notifyListeners(); // 상태 변경 알림
  }

  void setName(String newName) {
    name = newName; // name 설정 메서드 추가
    notifyListeners();
  }
}

