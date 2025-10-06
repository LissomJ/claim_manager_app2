// lib/case_model.dart (전체 코드)
import 'package:hive/hive.dart';
import 'todo_model.dart';
import 'pdf_text_annotation.dart';

part 'case_model.g.dart';

@HiveType(typeId: 0)
class Case extends HiveObject {
  @HiveField(0)
  String insuredName;
  @HiveField(1)
  String insuredAddress;
  @HiveField(2)
  String caseNumber;
  @HiveField(3)
  String agentName;
  @HiveField(4)
  String assignmentDate;
  @HiveField(5)
  bool isContacted;
  @HiveField(6)
  String insuredContact;
  @HiveField(7)
  String accidentDate;
  @HiveField(8)
  String instructions;
  @HiveField(9)
  String agentInfo;
  @HiveField(10)
  String accidentDetails;
  @HiveField(11)
  String investigationType;
  @HiveField(12)
  String assignmentReason;
  @HiveField(13)
  List<String> timeline;
  @HiveField(14)
  String? colorTag;
  @HiveField(15)
  bool isClosed;
  @HiveField(16)
  String? closingDate;
  @HiveField(17)
  bool invoiceSent;
  @HiveField(18)
  bool auditChecked;
  @HiveField(19)
  HiveList<ToDo>? todos;
  @HiveField(20)
  String? mainNote;
  @HiveField(21)
  List<String> pdfPaths;
  @HiveField(22)
  List<String> idPhotoPaths;
  @HiveField(23)
  HiveList<PdfTextAnnotation>? textAnnotations;

  Case({
    required this.insuredName,
    required this.caseNumber,
    required this.agentName,
    required this.assignmentDate,
    this.isContacted = false,
    this.insuredAddress = '',
    this.insuredContact = '',
    this.accidentDate = '',
    this.instructions = '',
    this.agentInfo = '',
    this.accidentDetails = '',
    this.investigationType = '',
    this.assignmentReason = '',
    List<String>? timeline,
    this.colorTag,
    this.isClosed = false,
    this.closingDate,
    this.invoiceSent = false,
    this.auditChecked = false,
    this.todos,
    this.mainNote,
    List<String>? pdfPaths,
    List<String>? idPhotoPaths,
    this.textAnnotations,
  }) : timeline = timeline ?? [],
        pdfPaths = pdfPaths ?? [],
        idPhotoPaths = idPhotoPaths ?? [];
}