import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/metacognition_entry.dart';

enum ViewState { empty, loading, loaded, error }

/// 메타인지 데이터 및 외부 API 비동기 통신 상태 관리자
class MetacognitionController extends ChangeNotifier {
  final List<MetacognitionEntry> _entries = [];
  ViewState _state = ViewState.empty;
  String? _errorMessage;
  int _retryCount = 0;

  List<MetacognitionEntry> get entries => List.unmodifiable(_entries);
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  /// AC 1 & AC 2: 입력 유효성 검사 및 데이터 추가
  String? addEntry({
    required String subject,
    required String predictedStr,
    required String actualStr,
    required String reflection,
  }) {
    // 1. 필수 분야 빈 값 검사 (AC 2: Invalid Input - Empty string)
    if (subject.trim().isEmpty) {
      return '과목명을 입력해주세요.';
    }
    if (predictedStr.trim().isEmpty || actualStr.trim().isEmpty) {
      return '예상 점수와 실제 점수를 모두 입력해주세요.';
    }

    // 2. 숫자 변환 및 범위 검사 (AC 2: Invalid Input - Out of bounds)
    final predicted = int.tryParse(predictedStr);
    final actual = int.tryParse(actualStr);

    if (predicted == null || actual == null) {
      return '점수는 숫자로만 입력해야 합니다.';
    }

    if (predicted < 0 || predicted > 100 || actual < 0 || actual > 100) {
      return '점수는 0점에서 100점 사이여야 합니다.';
    }

    // AC 1: 정상 입력 처리
    final newEntry = MetacognitionEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: subject.trim(),
      predictedScore: predicted,
      actualScore: actual,
      reflection: reflection.trim(),
      createdAt: DateTime.now(),
    );

    _entries.insert(0, newEntry);
    _state = ViewState.loaded;
    _errorMessage = null;
    notifyListeners();
    return null; // 에러 없음
  }

  /// AC 4: 외부 통신 모의(Mock) 및 재시도 로직 구현
  Future<void> fetchExternalAnalysis({bool simulateFailure = false}) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (simulateFailure && _retryCount < 1) {
      _retryCount++;
      _state = ViewState.error;
      _errorMessage = '네트워크 연결 실패 (서버 응답 없음). 다시 시도해주세요.';
      notifyListeners();
      return;
    }

    // 성공 처리
    _retryCount = 0;
    _state = _entries.isEmpty ? ViewState.empty : ViewState.loaded;
    _errorMessage = null;
    notifyListeners();
  }
}