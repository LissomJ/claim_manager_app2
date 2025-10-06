// lib/page_editor_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'case_model.dart';
import 'pdf_text_annotation.dart';

// 화면에 표시될 텍스트 객체 (이제 Hive 데이터와 직접 연결됩니다)
class MovableText {
  PdfTextAnnotation annotation;
  final String id = UniqueKey().toString();
  final FocusNode focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();

  MovableText({required this.annotation}) {
    controller.text = annotation.text;
  }
}

class PageEditorScreen extends StatefulWidget {
  final Uint8List pageImageData;
  final Case caseData; // Case 데이터를 전달받아 저장에 사용합니다.
  const PageEditorScreen({super.key, required this.pageImageData, required this.caseData});

  @override
  State<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends State<PageEditorScreen> {
  final List<MovableText> _texts = [];
  MovableText? _selectedText;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Case 데이터에 저장된 텍스트 어노테이션들을 불러옵니다.
    widget.caseData.textAnnotations ??= HiveList(Hive.box<PdfTextAnnotation>('text_annotations'));
    for (var annotation in widget.caseData.textAnnotations!) {
      _texts.add(MovableText(annotation: annotation));
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    for (var text in _texts) {
      text.focusNode.dispose();
      text.controller.dispose();
    }
    super.dispose();
  }

  void _addText(Offset position) {
    setState(() {
      final newAnnotation = PdfTextAnnotation(
        text: '',
        dx: position.dx,
        dy: position.dy,
        fontSize: 12.0,
      );
      // HiveList에 추가하여 영구 저장합니다.
      widget.caseData.textAnnotations!.add(newAnnotation);
      widget.caseData.save();

      final newText = MovableText(annotation: newAnnotation);
      _texts.add(newText);
      _selectedText = newText;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        newText.focusNode.requestFocus();
      });
    });
  }

  void _showActionsDialog(MovableText textToEdit) {
    final controller = TextEditingController(text: textToEdit.annotation.text);

    void onSave() {
      if (controller.text.isNotEmpty) {
        setState(() {
          textToEdit.annotation.text = controller.text;
          textToEdit.annotation.save(); // 개별 항목 저장
        });
      }
      Navigator.of(context).pop();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('텍스트 편집'),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (value) => onSave(),
        ),
        actions: [
          TextButton(
            child: const Text('복제'),
            onPressed: () {
              final originalAnnotation = textToEdit.annotation;
              _addText(Offset(originalAnnotation.dx + 20, originalAnnotation.dy + 20));
              // 복제 시 원본 텍스트를 바로 넣어줍니다.
              _texts.last.annotation.text = originalAnnotation.text;
              _texts.last.annotation.fontSize = originalAnnotation.fontSize;
              _texts.last.annotation.save();

              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
            onPressed: () {
              setState(() {
                if (_selectedText == textToEdit) {
                  _selectedText = null;
                }
                widget.caseData.textAnnotations!.remove(textToEdit.annotation);
                textToEdit.annotation.delete(); // Hive에서 완전히 삭제
                _texts.remove(textToEdit);
                widget.caseData.save();
              });
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('확인'),
            onPressed: onSave,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('페이지 편집'),
        actions: [
          if (_selectedText != null) ...[
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (_selectedText!.annotation.fontSize > 4) {
                    _selectedText!.annotation.fontSize -= 1;
                    _selectedText!.annotation.save();
                  }
                });
              },
              tooltip: '글자 작게',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _selectedText!.annotation.fontSize += 1;
                  _selectedText!.annotation.save();
                });
              },
              tooltip: '글자 크게',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: '편집 완료',
          ),
        ],
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.delete && _selectedText != null) {
              setState(() {
                widget.caseData.textAnnotations!.remove(_selectedText!.annotation);
                _selectedText!.annotation.delete();
                _texts.remove(_selectedText);
                _selectedText = null;
                widget.caseData.save();
              });
            }
          }
        },
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                  onTap: () => setState(() => _selectedText = null),
                  onLongPressStart: (details) => _addText(details.localPosition),
                  onSecondaryTapUp: (details) => _addText(details.localPosition),
                  child: Image.memory(widget.pageImageData, fit: BoxFit.contain)
              ),
              ..._texts.map((movableText) {
                final isSelected = _selectedText == movableText;
                return Positioned(
                  left: movableText.annotation.dx,
                  top: movableText.annotation.dy,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedText = movableText),
                    onLongPress: () => _showActionsDialog(movableText),
                    onSecondaryTap: () => _showActionsDialog(movableText),
                    onPanStart: (details) => setState(() => _selectedText = movableText),
                    onPanUpdate: (details) {
                      setState(() {
                        movableText.annotation.dx += details.delta.dx;
                        movableText.annotation.dy += details.delta.dy;
                      });
                    },
                    onPanEnd: (details) {
                      movableText.annotation.save();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: isSelected
                          ? BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 1),
                      )
                          : null,
                      child: isSelected
                          ? IntrinsicWidth(
                        child: TextField(
                          controller: movableText.controller,
                          focusNode: movableText.focusNode,
                          autofocus: true,
                          onChanged: (text) {
                            movableText.annotation.text = text;
                            movableText.annotation.save();
                          },
                          style: TextStyle(fontSize: movableText.annotation.fontSize, color: Colors.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      )
                          : Text(
                        movableText.annotation.text,
                        style: TextStyle(
                          fontSize: movableText.annotation.fontSize,
                          color: Colors.black,
                          shadows: const [
                            Shadow(blurRadius: 1.0, color: Colors.white, offset: Offset(1,1)),
                            Shadow(blurRadius: 1.0, color: Colors.white, offset: Offset(-1,-1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}