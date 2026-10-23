import 'package:flutter_test/flutter_test.dart';
import 'package:week6_app/controllers/metacognition_controller.dart';

void main() {
  group('MetaCheck 7주차 앱 인수 조건 (AC) 검증 테스트', () {
    late MetacognitionController controller;

    setUp(() {
      controller = MetacognitionController();
    });

    test('AC 1 (정상 입력): 유효한 점수 입력 시 정상적으로 회고가 추가된다', () {
      final error = controller.addEntry(
        subject: '운영체제',
        predictedStr: '85',
        actualStr: '80',
        reflection: '타이머 활용 필요',
      );

      expect(error, isNull);
      expect(controller.entries.length, equals(1));
      expect(controller.entries.first.distortionGap, equals(5));
    });

    test('AC 2 (잘못된 입력): 범위를 벗어난 점수(105점) 입력 시 에러 문구를 반환한다', () {
      final error = controller.addEntry(
        subject: '알고리즘',
        predictedStr: '105',
        actualStr: '90',
        reflection: '',
      );

      expect(error, equals('점수는 0점에서 100점 사이여야 합니다.'));
    });

    test('AC 3 (빈 상태): 초기 데이터가 없는 경우 ViewState.empty를 유지한다', () {
      expect(controller.entries.isEmpty, isTrue);
      expect(controller.state, equals(ViewState.empty));
    });

    test('AC 4 (외부 요청 실패 및 재시도): 실패 시 에러 상태 후 재시도로 복구된다', () async {
      await controller.fetchExternalAnalysis(simulateFailure: true);
      expect(controller.state, equals(ViewState.error));

      await controller.fetchExternalAnalysis(simulateFailure: false);
      expect(controller.state, equals(ViewState.empty));
    });
  });
}