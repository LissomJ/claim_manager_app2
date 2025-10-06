// lib/todo_model.dart

import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 1)
class ToDo extends HiveObject {
  @HiveField(0)
  String content;

  @HiveField(1)
  bool isCompleted;

  // --- 새로 추가된 필드 ---
  @HiveField(2)
  int parentCaseKey; // 어떤 사건(Case)에 속해있는지 알려주는 ID

  @HiveField(3)
  String? colorTag; // 색상 태그

  ToDo({
    required this.content,
    this.isCompleted = false,
    required this.parentCaseKey,
    this.colorTag,
  });
}