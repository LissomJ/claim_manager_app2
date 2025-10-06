// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'case_model.dart';
import 'todo_model.dart'; // ToDo 설계도를 가져옵니다.
import 'pdf_text_annotation.dart'; // <-- 이 줄을 추가하세요.
import 'pending_cases_screen.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CaseAdapter());
  Hive.registerAdapter(ToDoAdapter()); // ToDo 설계도를 금고에 등록합니다.
  Hive.registerAdapter(PdfTextAnnotationAdapter());
  await Hive.openBox<PdfTextAnnotation>('text_annotations');

  await Hive.openBox<Case>('cases');
  await Hive.openBox<ToDo>('todos'); // 'todos' 라는 이름의 새 금고를 엽니다.
  runApp(const ClaimManagerApp());
}

class ClaimManagerApp extends StatelessWidget {
  const ClaimManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const PendingCasesScreen(),
    );
  }
}