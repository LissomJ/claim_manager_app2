// lib/pdf_text_annotation.dart

import 'package:hive/hive.dart';

part 'pdf_text_annotation.g.dart';

@HiveType(typeId: 2) // ID가 겹치지 않도록 2번을 부여합니다.
class PdfTextAnnotation extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  double dx; // x 좌표

  @HiveField(2)
  double dy; // y 좌표

  @HiveField(3)
  double fontSize;

  PdfTextAnnotation({
    required this.text,
    required this.dx,
    required this.dy,
    required this.fontSize,
  });
}