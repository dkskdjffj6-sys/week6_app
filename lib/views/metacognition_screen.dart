import 'package:flutter/material.dart';
import '../controllers/metacognition_controller.dart';

class MetacognitionScreen extends StatefulWidget {
  const MetacognitionScreen({super.key});

  @override
  State<MetacognitionScreen> createState() => _MetacognitionScreenState();
}

class _MetacognitionScreenState extends State<MetacognitionScreen> {
  final MetacognitionController _controller = MetacognitionController();

  final _subjectController = TextEditingController();
  final _predictedController = TextEditingController();
  final _actualController = TextEditingController();
  final _reflectionController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _predictedController.dispose();
    _actualController.dispose();
    _reflectionController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    String? validationError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('메타인지 회고 작성'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: '과목명',
                        hintText: '예: 운영체제, 데이터베이스',
                      ),
                    ),
                    TextField(
                      controller: _predictedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '예상 점수 (0~100)'),
                    ),
                    TextField(
                      controller: _actualController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '실제 점수 (0~100)'),
                    ),
                    TextField(
                      controller: _reflectionController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: '학업 회고'),
                    ),
                    if (validationError != null) ...[
                      const SizedBox(height: 12),
                      Text(validationError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                ElevatedButton(
                  onPressed: () {
                    final err = _controller.addEntry(
                      subject: _subjectController.text,
                      predictedStr: _predictedController.text,
                      actualStr: _actualController.text,
                      reflection: _reflectionController.text,
                    );

                    if (err != null) {
                      setDialogState(() => validationError = err);
                    } else {
                      _subjectController.clear();
                      _predictedController.clear();
                      _actualController.clear();
                      _reflectionController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('MetaCheck — 메타인지 진단'),
            actions: [
              IconButton(
                icon: const Icon(Icons.sync),
                tooltip: '동기화 테스트 (AC 4)',
                onPressed: () => _controller.fetchExternalAnalysis(simulateFailure: true),
              )
            ],
          ),
          body: _buildBody(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text('회고 작성'),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    // AC 4: 외부 통신 에러 및 재시도 상태
    if (_controller.state == ViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_controller.errorMessage ?? '오류 발생', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _controller.fetchExternalAnalysis(simulateFailure: false),
              icon: const Icon(Icons.refresh),
              label: const Text('재시도 (Retry)'),
            )
          ],
        ),
      );
    }

    // AC 3: 빈 상태 (Empty State)
    if (_controller.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('등록된 메타인지 회고가 없습니다.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add_task),
              label: const Text('첫 회고 작성하기'),
            )
          ],
        ),
      );
    }

    // AC 1: 정상 목록 표시
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.entries.length,
      itemBuilder: (context, index) {
        final entry = _controller.entries[index];
        return Card(
          child: ListTile(
            title: Text(entry.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('예상 ${entry.predictedScore}점 / 실제 ${entry.actualScore}점 (${entry.distortionDiagnosis})'),
          ),
        );
      },
    );
  }
}