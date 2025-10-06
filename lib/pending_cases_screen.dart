// lib/pending_cases_screen.dart (전체 코드)
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'case_model.dart';
import 'case_details_screen.dart';
import 'app_drawer.dart';

class PendingCasesScreen extends StatefulWidget {
  const PendingCasesScreen({super.key});
  @override
  State<PendingCasesScreen> createState() => _PendingCasesScreenState();
}

// lib/pending_cases_screen.dart 파일의 이 부분을 교체해주세요.

// lib/pending_cases_screen.dart 파일의 _PendingCasesScreenState 부분을 이걸로 교체

// lib/pending_cases_screen.dart 파일의 _PendingCasesScreenState 부분을 이걸로 교체

class _PendingCasesScreenState extends State<PendingCasesScreen> {
  String _sortOrder = 'newest';
  String? _activeColorFilter;
  String? _activeAgentFilter;

  final TextEditingController _agentFilterController = TextEditingController();

  // --- 날짜 수정 팝업을 띄우고 데이터를 업데이트하는 함수 (분리) ---
  Future<void> _showDatePickerAndUpdate(Case caseItem) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      String formattedDate = "${pickedDate.year.toString().substring(2)}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

      if (mounted) {
        setState(() {
          caseItem.assignmentDate = formattedDate;
          caseItem.save();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _agentFilterController.text = _activeAgentFilter ?? '';
  }

  @override
  void dispose() {
    _agentFilterController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    _agentFilterController.text = _activeAgentFilter ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('필터'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('색상 필터', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterColorButton('red'),
                    _buildFilterColorButton('orange'),
                    _buildFilterColorButton('blue'),
                    _buildFilterColorButton('green'),
                  ],
                ),
                const Divider(height: 24),
                const Text('담당자 필터', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _agentFilterController,
                  decoration: const InputDecoration(
                    hintText: '담당자 이름 입력...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('모든 필터 해제'),
              onPressed: () {
                setState(() {
                  _activeColorFilter = null;
                  _activeAgentFilter = null;
                  _agentFilterController.clear();
                });
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('필터 적용'),
              onPressed: () {
                setState(() {
                  _activeAgentFilter = _agentFilterController.text.isNotEmpty
                      ? _agentFilterController.text
                      : null;
                });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildFilterColorButton(String color) {
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
        setState(() {
          if (_activeColorFilter == color) {
            _activeColorFilter = null;
          } else {
            _activeColorFilter = color;
          }
        });
        Navigator.of(context).pop();
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: displayColor,
        child: _activeColorFilter == color ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정렬 순서'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('배당일 최신순'),
              value: 'newest',
              groupValue: _sortOrder,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortOrder = value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('배당일 오래된순'),
              value: 'oldest',
              groupValue: _sortOrder,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortOrder = value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
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

  void _showAddCaseDialog() {
    final box = Hive.box<Case>('cases');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddCaseDialog(
          onCaseAdded: (newCase) {
            box.add(newCase);
          },
        );
      },
    );
  }

  void _showActionsDialog(Case caseItem) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('컨택 완료', style: TextStyle(fontSize: 16)),
                      Switch(
                        value: caseItem.isContacted,
                        onChanged: (value) {
                          setStateInDialog(() {
                            caseItem.isContacted = value;
                          });
                          caseItem.save();
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
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
                          setStateInDialog(() {
                            caseItem.colorTag = null;
                          });
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
                      child: const Text('종결 처리', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        caseItem.isClosed = true;
                        final now = DateTime.now();
                        caseItem.closingDate = "${now.year.toString().substring(2)}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
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
        setStateInDialog(() {
          caseItem.colorTag = color;
        });
        caseItem.save();
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: displayColor,
        child: caseItem.colorTag == color ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
      ),
    );
  }

  Widget _buildHeader() {
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
          SizedBox(width: 40, child: Text('순번', textAlign: TextAlign.center, style: headerStyle)),
          Expanded(flex: 3, child: Text('사고번호', textAlign: TextAlign.center, style: headerStyle)),
          Expanded(flex: 2, child: Text('피보험자', textAlign: TextAlign.center, style: headerStyle)),
          Expanded(flex: 3, child: Text('주소지', textAlign: TextAlign.center, style: headerStyle)),
          Expanded(flex: 2, child: Text('담당자', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 80, child: Text('배당일자', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 50, child: Text('컨택', textAlign: TextAlign.center, style: headerStyle)),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildRow(Case caseItem, int index) {
    const rowStyle = TextStyle(color: Colors.black, fontSize: 14);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaseDetailsScreen(caseData: caseItem),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: CircleAvatar(
                radius: 5,
                backgroundColor: _getColorFromTag(caseItem.colorTag),
              ),
            ),
            SizedBox(width: 40, child: Text('${index + 1}', textAlign: TextAlign.center, style: rowStyle)),
            Expanded(flex: 3, child: Text(caseItem.caseNumber, textAlign: TextAlign.center, style: rowStyle)),
            Expanded(flex: 2, child: Text(caseItem.insuredName, textAlign: TextAlign.center, style: rowStyle)),
            Expanded(flex: 3, child: Text(caseItem.insuredAddress, textAlign: TextAlign.center, style: rowStyle)),
            Expanded(flex: 2, child: Text(caseItem.agentName, textAlign: TextAlign.center, style: rowStyle)),
            SizedBox(
              width: 80,
              child: GestureDetector(
                onLongPress: () => _showDatePickerAndUpdate(caseItem),
                onSecondaryTap: () => _showDatePickerAndUpdate(caseItem),
                child: Text(caseItem.assignmentDate, textAlign: TextAlign.center, style: rowStyle),
              ),
            ),
            SizedBox(width: 50, child: Text(caseItem.isContacted ? 'Y' : 'N', textAlign: TextAlign.center, style: rowStyle)),
            SizedBox(
              width: 40,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  _showActionsDialog(caseItem);
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
        title: const Text('미결 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: '정렬',
          ),
          IconButton(
            icon: Icon(
              Icons.filter_alt,
              color: (_activeColorFilter != null || (_activeAgentFilter != null && _activeAgentFilter!.isNotEmpty))
                  ? Colors.white
                  : Colors.white.withOpacity(0.7),
            ),
            onPressed: _showFilterDialog,
            tooltip: '필터',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Case>('cases').listenable(),
        builder: (context, box, widget) {

          var pendingCases = box.values.where((caseItem) => caseItem.isClosed == false).toList();

          if (_activeColorFilter != null) {
            pendingCases = pendingCases.where((c) => c.colorTag == _activeColorFilter).toList();
          }
          if (_activeAgentFilter != null && _activeAgentFilter!.isNotEmpty) {
            pendingCases = pendingCases.where((c) => c.agentName.contains(_activeAgentFilter!)).toList();
          }

          pendingCases.sort((a, b) {
            if (_sortOrder == 'newest') {
              return b.assignmentDate.compareTo(a.assignmentDate);
            } else {
              return a.assignmentDate.compareTo(b.assignmentDate);
            }
          });

          if (pendingCases.isEmpty) {
            return const Center(
              child: Text(
                '표시할 사건이 없습니다.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.separated(
                  itemCount: pendingCases.length,
                  itemBuilder: (context, index) {
                    final caseItem = pendingCases[index];
                    return _buildRow(caseItem, index);
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCaseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddCaseDialog extends StatefulWidget {
  final Function(Case) onCaseAdded;
  const _AddCaseDialog({required this.onCaseAdded});
  @override
  State<_AddCaseDialog> createState() => _AddCaseDialogState();
}
class _AddCaseDialogState extends State<_AddCaseDialog> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _pasteController = TextEditingController();
  final TextEditingController _insuredController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _caseNumberController = TextEditingController();
  final TextEditingController _agentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _extractText(String source, RegExp regExp) {
    return regExp.firstMatch(source)?.group(1)?.trim() ?? '';
  }
  Case _parseTextAndCreateCase(String text) {
    final insuredName = _extractText(text, RegExp(r"피보험자명\s*:\s*(.*)"));
    final address = _extractText(text, RegExp(r"피보험자 계약상주소지\s*:\s*(.*)"));
    final contact = _extractText(text, RegExp(r"피보험자 연락처\s*:\s*(.*)"));
    final caseNumber = _extractText(text, RegExp(r"청구번호\s*:\s*(.*)"));
    final agentName = _extractText(text, RegExp(r"담당자\s*:\s*(.*?)\s*\/"));
    final agentInfo = _extractText(text, RegExp(r"담당자\s*:\s*(.*)"));
    final accidentDate = _extractText(text, RegExp(r"사고일\s*:\s*(.*)"));
    final accidentDetails = _extractText(text, RegExp(r"사고내용\s*:\s*(.*)"));
    final investigationType = _extractText(text, RegExp(r"조사유형\s*:\s*(.*)"));
    final assignmentReason = _extractText(text, RegExp(r"위임사유\s*:\s*(.*)"));
    String instructions = '';
    final instructionsMatch = RegExp(r"■ 위임지시사항\s*([\s\S]*)").firstMatch(text);
    if (instructionsMatch != null) {
      instructions = instructionsMatch.group(1)!.trim();
    }
    final assignmentDate = "${DateTime.now().year.toString().substring(2)}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    return Case(
      insuredName: insuredName.isEmpty ? '정보 없음' : insuredName,
      insuredAddress: address,
      insuredContact: contact,
      caseNumber: caseNumber.isEmpty ? '정보 없음' : caseNumber,
      agentName: agentName.isEmpty ? '정보 없음' : agentName,
      assignmentDate: assignmentDate,
      accidentDate: accidentDate,
      instructions: instructions,
      agentInfo: agentInfo,
      accidentDetails: accidentDetails,
      investigationType: investigationType,
      assignmentReason: assignmentReason,
    );
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    _pasteController.dispose();
    _insuredController.dispose();
    _addressController.dispose();
    _caseNumberController.dispose();
    _agentController.dispose();
    _dateController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TabBar(
        controller: _tabController,
        tabs: const <Widget>[
          Tab(text: '자동 추출'),
          Tab(text: '직접 입력'),
        ],
        labelColor: Colors.blueGrey,
        unselectedLabelColor: Colors.grey,
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextField(
                controller: _pasteController,
                maxLines: 15,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            ListView(
              children: <Widget>[
                TextField(controller: _insuredController, decoration: const InputDecoration(labelText: '피보험자')),
                TextField(controller: _addressController, decoration: const InputDecoration(labelText: '주소지')),
                TextField(controller: _caseNumberController, decoration: const InputDecoration(labelText: '사고번호')),
                TextField(controller: _agentController, decoration: const InputDecoration(labelText: '담당자명')),
                TextField(controller: _dateController, decoration: const InputDecoration(labelText: '배당일자 (예: 25-10-05)')),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('취소'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('추가'),
          onPressed: () {
            Case newCase;
            if (_tabController.index == 0) {
              newCase = _parseTextAndCreateCase(_pasteController.text);
            } else {
              newCase = Case(
                insuredName: _insuredController.text,
                insuredAddress: _addressController.text,
                caseNumber: _caseNumberController.text,
                agentName: _agentController.text,
                assignmentDate: _dateController.text,
              );
            }
            widget.onCaseAdded(newCase);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}