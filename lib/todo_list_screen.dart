// lib/todo_list_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_drawer.dart';
import 'case_model.dart';
import 'todo_model.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  // To-Do 항목을 표시하는 행(Row)을 만드는 위젯
  Widget _buildToDoRow(ToDo todo) {
    final caseBox = Hive.box<Case>('cases');
    // To-Do에 저장된 부모 ID로 Case 데이터를 찾습니다.
    final parentCase = caseBox.get(todo.parentCaseKey);

    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      value: todo.isCompleted,
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          final wasCompleted = todo.isCompleted;
          todo.isCompleted = value;
          todo.save();
          if (value && !wasCompleted && parentCase != null) {
            // 타임라인에 기록을 남깁니다.
            final now = DateTime.now();
            final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
            parentCase.timeline.add('[$formattedDate] ${todo.content} 완료');
            parentCase.save();
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
      // 부모 Case가 있으면 피보험자 이름을 표시
      subtitle: Text(parentCase?.insuredName ?? '일반 업무'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 할 일'),
      ),
      drawer: const AppDrawer(),
      body: ValueListenableBuilder(
        // 'todos' 금고의 변화를 감지합니다.
        valueListenable: Hive.box<ToDo>('todos').listenable(),
        builder: (context, box, child) {
          // 완료되지 않은 할 일만 가져옵니다.
          final todos = box.values.where((todo) => !todo.isCompleted).toList();

          if (todos.isEmpty) {
            return const Center(child: Text('모든 할 일을 완료했습니다!'));
          }

          return ListView.separated(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return _buildToDoRow(todo);
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          );
        },
      ),
    );
  }
}