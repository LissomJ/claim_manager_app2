// lib/pdf_viewer_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'case_model.dart';
import 'dart:ui' as ui;
import 'page_editor_screen.dart';

class EditablePage {
  final Uint8List imageData;
  final String id = UniqueKey().toString();

  EditablePage({
    required this.imageData,
  });
}

class PdfViewerScreen extends StatefulWidget {
  final Case caseData;
  const PdfViewerScreen({super.key, required this.caseData});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final List<EditablePage> _pages = [];
  bool _isLoading = false;
  final List<EditablePage> _selectedPages = [];

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<List<EditablePage>> _generatePagesFromPath(String path) async {
    final List<EditablePage> newPages = [];
    final file = File(path);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      final isPdf = path.toLowerCase().endsWith('.pdf');

      if (isPdf) {
        await for (final page in Printing.raster(bytes, dpi: 150)) {
          newPages.add(EditablePage(imageData: await page.toPng()));
        }
      } else {
        newPages.add(EditablePage(imageData: bytes));
      }
    }
    return newPages;
  }

  Future<void> _initialLoad() async {
    setState(() => _isLoading = true);
    final List<EditablePage> initialPages = [];

    final pdfPaths = widget.caseData.pdfPaths;
    final idPhotoPaths = widget.caseData.idPhotoPaths;

    for (final path in pdfPaths) {
      initialPages.addAll(await _generatePagesFromPath(path));
    }
    for (final path in idPhotoPaths) {
      initialPages.addAll(await _generatePagesFromPath(path));
    }

    setState(() {
      _pages.addAll(initialPages);
      _isLoading = false;
    });
  }

  Future<void> _importFromPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: true);
    if (result != null) {
      setState(() => _isLoading = true);
      for (final file in result.files) {
        if (file.path != null) {
          final path = file.path!;
          _pages.addAll(await _generatePagesFromPath(path));
          if (!widget.caseData.pdfPaths.contains(path)) {
            widget.caseData.pdfPaths.add(path);
          }
        }
      }
      setState(() {
        widget.caseData.save();
        _isLoading = false;
      });
    }
  }

  Future<void> _importImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image, allowMultiple: true);
    if (result != null) {
      setState(() => _isLoading = true);
      for (var file in result.files) {
        if (file.path != null) {
          final path = file.path!;
          _pages.addAll(await _generatePagesFromPath(path));
          if (!widget.caseData.idPhotoPaths.contains(path)) {
            widget.caseData.idPhotoPaths.add(path);
          }
        }
      }
      setState(() {
        widget.caseData.save();
        _isLoading = false;
      });
    }
  }

  Future<void> _exportSelectionAsPdf() async {
    if (_selectedPages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내보낼 페이지를 먼저 선택해주세요.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final pdf = pw.Document();
    for (final page in _selectedPages) {
      final image = pw.MemoryImage(page.imageData);
      final codec = await ui.instantiateImageCodec(page.imageData);
      final frameInfo = await codec.getNextFrame();
      final decodedImage = frameInfo.image;
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            decodedImage.width.toDouble(),
            decodedImage.height.toDouble(),
            marginAll: 0,
          ),
          build: (pw.Context context) {
            return pw.Image(image);
          },
        ),
      );
    }
    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${widget.caseData.insuredName}_조합문서.pdf');
    setState(() => _isLoading = false);
  }

  void _showPageActionsBottomSheet(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('이 페이지 복제'),
              onTap: () {
                setState(() {
                  final pageToCopy = _pages[index];
                  _pages.insert(index + 1, EditablePage(imageData: pageToCopy.imageData));
                  _selectedPages.clear();
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('이 페이지 삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                setState(() {
                  _pages.removeAt(index);
                  _selectedPages.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('문서 조합'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: _selectedPages.isNotEmpty ? _exportSelectionAsPdf : null,
            tooltip: '선택 항목 내보내기',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('페이지 로딩 중...')]))
          : _pages.isEmpty
          ? const Center(child: Text('하단 버튼을 눌러 PDF 또는 이미지를 추가하세요.'))
          : ReorderableGridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _pages.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            final page = _pages.removeAt(oldIndex);
            _pages.insert(newIndex, page);
            _selectedPages.clear();
          });
        },
        itemBuilder: (context, index) {
          final page = _pages[index];
          final isSelected = _selectedPages.contains(page);
          return GridTile(
            key: ValueKey(page.id),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedPages.remove(page);
                  } else {
                    _selectedPages.add(page);
                  }
                });
              },
              onDoubleTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageEditorScreen(
                      pageImageData: page.imageData,
                      caseData: widget.caseData, // <-- 이 줄을 추가하세요.
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(1, 1),
                          )
                        ],
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.memory(page.imageData, fit: BoxFit.contain)),
                    ),
                    // --- 헤더 (페이지 번호, 선택 순서) ---
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                          color: Colors.black45,
                        ),
                        child: Row(
                          children: [
                            if (isSelected)
                              Text('${_selectedPages.indexOf(page) + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            const Spacer(),
                            Text('${index + 1}p', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    // --- 선택 시 체크 아이콘 ---
                    if (isSelected)
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(Icons.check_circle, color: Colors.blue, size: 24),
                      ),
                    // --- 오른쪽 아래 '더보기' 버튼 ---
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showPageActionsBottomSheet(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(8)),
                          ),
                          child: const Icon(Icons.more_horiz, color: Colors.white, size: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('PDF 페이지 가져오기'),
              onPressed: _importFromPdf,
            ),
            TextButton.icon(
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('이미지 가져오기'),
              onPressed: _importImages,
            ),
          ],
        ),
      ),
    );
  }
}