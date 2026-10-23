/// 메타인지 학업 회고 데이터 모델
class MetacognitionEntry {
  final String id;
  final String subject;       // 과목명
  final int predictedScore;   // 메타인지 예상 점수 (0~100)
  final int actualScore;      // 실제 시험 점수 (0~100)
  final String reflection;     // 학습 회고 내용
  final DateTime createdAt;

  MetacognitionEntry({
    required this.id,
    required this.subject,
    required this.predictedScore,
    required this.actualScore,
    required this.reflection,
    required this.createdAt,
  });

  /// 메타인지 왜곡도 수치 계산 (예상 점수 - 실제 점수)
  /// 양수: 과대평가 (Overconfidence)
  /// 음수: 과소평가 (Underconfidence)
  int get distortionGap => predictedScore - actualScore;

  /// 메타인지 상태 진단 문구
  String get distortionDiagnosis {
    final gap = distortionGap.abs();
    if (gap <= 5) return '정확한 메타인지 (오차 범위 내)';
    if (predictedScore > actualScore) {
      return '과대평가 경향 ($gap점 차이) - 메타인지 교정이 필요합니다.';
    } else {
      return '과소평가 경향 ($gap점 차이) - 자신감을 높이세요!';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'predictedScore': predictedScore,
        'actualScore': actualScore,
        'reflection': reflection,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MetacognitionEntry.fromJson(Map<String, dynamic> json) {
    return MetacognitionEntry(
      id: json['id'] as String,
      subject: json['subject'] as String,
      predictedScore: json['predictedScore'] as int,
      actualScore: json['actualScore'] as int,
      reflection: json['reflection'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}