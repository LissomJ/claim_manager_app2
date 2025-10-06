// lib/case_details_screen.dart

import 'pdf_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'case_model.dart';
import 'todo_model.dart';

class CaseDetailsScreen extends StatefulWidget {
  final Case caseData;
  const CaseDetailsScreen({super.key, required this.caseData});

  @override
  State<CaseDetailsScreen> createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.caseData.todos ??= HiveList(Hive.box<ToDo>('todos'));
    _noteController.text = widget.caseData.mainNote ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    _todoController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  void _addTimelineEvent({String? predefinedText}) {
    final textToAdd = predefinedText ?? _timelineController.text;
    if (textToAdd.isNotEmpty) {
      setState(() {
        final now = DateTime.now();
        final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        widget.caseData.timeline.add('[$formattedDate] $textToAdd');
        widget.caseData.save();
        _timelineController.clear();
      });
    }
  }

  void _deleteTimelineEvent(int index) {
    setState(() {
      widget.caseData.timeline.removeAt(index);
      widget.caseData.save();
    });
  }

  void _addToDo(String content) {
    if (content.isNotEmpty) {
      final newToDo = ToDo(
        content: content,
        parentCaseKey: widget.caseData.key,
      );
      final todoBox = Hive.box<ToDo>('todos');
      setState(() {
        todoBox.add(newToDo);
        widget.caseData.todos!.add(newToDo);
        widget.caseData.save();
      });
    }
  }

  void _deleteToDo(int index) {
    setState(() {
      widget.caseData.todos!.deleteFromHive(index);
      widget.caseData.save();
    });
  }

  void _showAddToDoDialog() {
    _todoController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새로운 할 일'),
        content: TextField(
          controller: _todoController,
          autofocus: true,
          decoration: const InputDecoration(hintText: '할 일 내용을 입력하세요...'),
          onSubmitted: (value) {
            _addToDo(value);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('추가'),
            onPressed: () {
              _addToDo(_todoController.text);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  void _showEditNoteDialog(int index) {
    final originalNote = widget.caseData.timeline[index];
    final content = originalNote.substring(originalNote.indexOf(' ') + 1);
    final editController = TextEditingController(text: content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('타임라인 수정'),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLines: 5,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('저장'),
            onPressed: () {
              setState(() {
                final timeStamp = originalNote.substring(0, originalNote.indexOf(' ') + 1);
                widget.caseData.timeline[index] = '$timeStamp${editController.text}';
                widget.caseData.save();
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDoubleInfoRow({
    required String title1, required String content1, bool isCopyable1 = false,
    required String title2, required String content2, bool isCopyable2 = false,
  }) {
    final titleStyle = TextStyle(color: Colors.black.withOpacity(0.6));
    const contentStyle = TextStyle(color: Colors.black);

    Widget buildColumn(String title, String content, bool isCopyable) {
      return Expanded(
        child: GestureDetector(
          onLongPress: isCopyable ? () {
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('\'$title\'이(가) 복사되었습니다.')),
            );
          } : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 80, child: Text(title, style: titleStyle)),
              Expanded(child: Text(content, style: contentStyle)),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildColumn(title1, content1, isCopyable1),
          buildColumn(title2, content2, isCopyable2),
        ],
      ),
    );
  }

  Widget _buildSingleInfoRow(String title, String content) {
    final titleStyle = TextStyle(color: Colors.black.withOpacity(0.6));
    const contentStyle = TextStyle(color: Colors.black, height: 1.5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(title, style: titleStyle)),
          Expanded(child: Text(content, style: contentStyle)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.caseData.insuredName),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddToDoDialog,
        child: const Icon(Icons.playlist_add),
        tooltip: '할 일 추가',
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoubleInfoRow(
                    title1: '피보험자', content1: '${widget.caseData.insuredName} (${widget.caseData.insuredContact})',
                    title2: '사고번호', content2: widget.caseData.caseNumber, isCopyable2: true,
                  ),
                  _buildDoubleInfoRow(
                    title1: '주소지', content1: widget.caseData.insuredAddress.isEmpty ? '-' : widget.caseData.insuredAddress,
                    title2: '담당자', content2: widget.caseData.agentInfo.isEmpty ? '-' : widget.caseData.agentInfo,
                  ),
                  const Divider(height: 16),
                  _buildDoubleInfoRow(
                    title1: '사고일자', content1: widget.caseData.accidentDate.isEmpty ? '-' : widget.caseData.accidentDate,
                    title2: '사고내용', content2: widget.caseData.accidentDetails.isEmpty ? '-' : widget.caseData.accidentDetails,
                  ),
                  _buildDoubleInfoRow(
                    title1: '조사유형', content1: widget.caseData.investigationType.isEmpty ? '-' : widget.caseData.investigationType,
                    title2: '위임사유', content2: widget.caseData.assignmentReason.isEmpty ? '-' : widget.caseData.assignmentReason,
                  ),
                  const Divider(height: 16),
                  _buildSingleInfoRow('위임지시', widget.caseData.instructions.isEmpty ? '-' : widget.caseData.instructions),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('■ 노트', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: '자유롭게 메모를 작성하세요...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onChanged: (text) {
                      widget.caseData.mainNote = text;
                      widget.caseData.save();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('■ 할 일 (To-Do List)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (widget.caseData.todos?.isNotEmpty ?? false)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.caseData.todos!.length,
                      itemBuilder: (context, index) {
                        final todo = widget.caseData.todos![index];
                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: todo.isCompleted,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              final wasCompleted = todo.isCompleted;
                              todo.isCompleted = value;
                              todo.save();
                              if (value && !wasCompleted) {
                                _addTimelineEvent(predefinedText: '${todo.content} 완료');
                              }
                            });
                          },
                          title: Text(
                            todo.content,
                            style: TextStyle(
                              decoration: todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                              color: todo.isCompleted ? Colors.grey : Colors.black,
                            ),
                          ),
                          secondary: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            onPressed: () => _deleteToDo(index),
                          ),
                        );
                      },
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text('등록된 할 일이 없습니다.')),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('■ 타임라인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.caseData.timeline.length,
                    itemBuilder: (context, index) {
                      final event = widget.caseData.timeline[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(event, style: const TextStyle(fontSize: 14)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                          onPressed: () => _deleteTimelineEvent(index),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _timelineController,
                          decoration: const InputDecoration(
                            hintText: '타임라인에 수동으로 기록 추가...',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) => _addTimelineEvent(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.blueGrey),
                        onPressed: () => _addTimelineEvent(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.edit_document, color: Colors.blueGrey),
              title: const Text('문서 편집 및 조합', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('PDF 페이지 선택, 순서 변경, 신분증 추가 등'),
              onTap: () {
                // 이 부분을 채워넣습니다.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PdfViewerScreen(caseData: widget.caseData)),
                );
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}