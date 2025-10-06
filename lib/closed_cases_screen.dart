// lib/closed_cases_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'case_model.dart';
import 'case_details_screen.dart';
import 'app_drawer.dart';

class ClosedCasesScreen extends StatefulWidget {
  const ClosedCasesScreen({super.key});
  @override
  State<ClosedCasesScreen> createState() => _ClosedCasesScreenState();
}

class _ClosedCasesScreenState extends State<ClosedCasesScreen> {
  // --- '상태 변경' 팝업창을 보여주는 새 함수 ---
  void _showClosedActionsDialog(Case caseItem) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('상태 변경'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('색상 태그', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildColorButton('red', caseItem, setStateInDialog),
                      _buildColorButton('orange', caseItem, setStateInDialog),
                      _buildColorButton('blue', caseItem, setStateInDialog),
                      _buildColorButton('green', caseItem, setStateInDialog),
                      GestureDetector(
                        onTap: () {
                          setStateInDialog(() => caseItem.colorTag = null);
                          caseItem.save();
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.close, size: 18, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  const Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      child: const Text('미결로 보내기', style: TextStyle(color: Colors.blue)),
                      onPressed: () {
                        caseItem.isClosed = false; // 상태를 '미결'로 변경
                        caseItem.closingDate = null; // 종결일자 삭제
                        caseItem.save();
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('닫기'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- '색상 선택' 버튼을 만드는 헬퍼 위젯 ---
  Widget _buildColorButton(String color, Case caseItem, Function(void Function()) setStateInDialog) {
    Color displayColor;
    switch (color) {
      case 'red': displayColor = Colors.red; break;
      case 'orange': displayColor = Colors.orange; break;
      case 'blue': displayColor = Colors.blue; break;
      case 'green': displayColor = Colors.green; break;
      default: displayColor = Colors.transparent;
    }
    return GestureDetector(
      onTap: () {
        setStateInDialog(() => caseItem.colorTag = color);
        caseItem.save();
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: displayColor,
        child: caseItem.colorTag == color ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
      ),
    );
  }

  Color _getColorFromTag(String? colorTag) {
    switch (colorTag) {
      case 'red': return Colors.red;
      case 'orange': return Colors.orange;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      default: return Colors.transparent;
    }
  }

  Widget _buildClosedHeader() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.black);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(bottom: BorderSide(color: Colors.grey[400]!)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 20),
          Expanded(flex: 2, child: Text('사고번호', textAlign: TextAlign.center, style: headerStyle)),
          Expanded(flex: 1, child: Text('피보험자', textAlign: TextAlign.center, style: headerStyle)),
          Expanded(flex: 1, child: Text('담당자', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 90, child: Text('종결일자', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 70, child: Text('계산서', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 70, child: Text('오딧점검', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 40), // 더보기 버튼 공간
        ],
      ),
    );
  }

  Widget _buildClosedRow(Case caseItem) {
    const rowStyle = TextStyle(color: Colors.black, fontSize: 14);
    final boldRowStyle = rowStyle.copyWith(fontWeight: FontWeight.bold);

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CaseDetailsScreen(caseData: caseItem)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: CircleAvatar(radius: 5, backgroundColor: _getColorFromTag(caseItem.colorTag)),
            ),
            Expanded(flex: 2, child: Text(caseItem.caseNumber, textAlign: TextAlign.center, style: rowStyle)),
            Expanded(flex: 1, child: Text(caseItem.insuredName, textAlign: TextAlign.center, style: rowStyle)),
            Expanded(flex: 1, child: Text(caseItem.agentName, textAlign: TextAlign.center, style: rowStyle)),
            SizedBox(width: 90, child: Text(caseItem.closingDate ?? '-', textAlign: TextAlign.center, style: rowStyle)),
            SizedBox(
              width: 70,
              child: InkWell(
                onTap: () {
                  setState(() {
                    caseItem.invoiceSent = !caseItem.invoiceSent;
                    caseItem.save();
                  });
                },
                child: Text(caseItem.invoiceSent ? 'Y' : 'N', textAlign: TextAlign.center, style: caseItem.invoiceSent ? boldRowStyle : rowStyle),
              ),
            ),
            SizedBox(
              width: 70,
              child: InkWell(
                onTap: () {
                  setState(() {
                    caseItem.auditChecked = !caseItem.auditChecked;
                    caseItem.save();
                  });
                },
                child: Text(caseItem.auditChecked ? 'Y' : 'N', textAlign: TextAlign.center, style: caseItem.auditChecked ? boldRowStyle : rowStyle),
              ),
            ),
            // --- '더보기' 버튼 추가 ---
            SizedBox(
              width: 40,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  _showClosedActionsDialog(caseItem);
                },
                child: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('종결 관리'),
      ),
      drawer: const AppDrawer(),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Case>('cases').listenable(),
        builder: (context, box, widget) {
          final closedCases = box.values.where((caseItem) => caseItem.isClosed == true).toList();
          if (closedCases.isEmpty) {
            return const Center(
              child: Text('종결된 사건이 없습니다.'),
            );
          }
          return Column(
            children: [
              _buildClosedHeader(),
              Expanded(
                child: ListView.separated(
                  itemCount: closedCases.length,
                  itemBuilder: (context, index) {
                    final caseItem = closedCases[index];
                    return _buildClosedRow(caseItem);
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}