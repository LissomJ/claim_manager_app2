// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CaseAdapter extends TypeAdapter<Case> {
  @override
  final int typeId = 0;

  @override
  Case read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Case(
      insuredName: fields[0] as String,
      caseNumber: fields[2] as String,
      agentName: fields[3] as String,
      assignmentDate: fields[4] as String,
      isContacted: fields[5] as bool,
      insuredAddress: fields[1] as String,
      insuredContact: fields[6] as String,
      accidentDate: fields[7] as String,
      instructions: fields[8] as String,
      agentInfo: fields[9] as String,
      accidentDetails: fields[10] as String,
      investigationType: fields[11] as String,
      assignmentReason: fields[12] as String,
      timeline: (fields[13] as List?)?.cast<String>(),
      colorTag: fields[14] as String?,
      isClosed: fields[15] as bool,
      closingDate: fields[16] as String?,
      invoiceSent: fields[17] as bool,
      auditChecked: fields[18] as bool,
      todos: (fields[19] as HiveList?)?.castHiveList(),
      mainNote: fields[20] as String?,
      pdfPaths: (fields[21] as List?)?.cast<String>(),
      idPhotoPaths: (fields[22] as List?)?.cast<String>(),
      textAnnotations: (fields[23] as HiveList?)?.castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, Case obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.insuredName)
      ..writeByte(1)
      ..write(obj.insuredAddress)
      ..writeByte(2)
      ..write(obj.caseNumber)
      ..writeByte(3)
      ..write(obj.agentName)
      ..writeByte(4)
      ..write(obj.assignmentDate)
      ..writeByte(5)
      ..write(obj.isContacted)
      ..writeByte(6)
      ..write(obj.insuredContact)
      ..writeByte(7)
      ..write(obj.accidentDate)
      ..writeByte(8)
      ..write(obj.instructions)
      ..writeByte(9)
      ..write(obj.agentInfo)
      ..writeByte(10)
      ..write(obj.accidentDetails)
      ..writeByte(11)
      ..write(obj.investigationType)
      ..writeByte(12)
      ..write(obj.assignmentReason)
      ..writeByte(13)
      ..write(obj.timeline)
      ..writeByte(14)
      ..write(obj.colorTag)
      ..writeByte(15)
      ..write(obj.isClosed)
      ..writeByte(16)
      ..write(obj.closingDate)
      ..writeByte(17)
      ..write(obj.invoiceSent)
      ..writeByte(18)
      ..write(obj.auditChecked)
      ..writeByte(19)
      ..write(obj.todos)
      ..writeByte(20)
      ..write(obj.mainNote)
      ..writeByte(21)
      ..write(obj.pdfPaths)
      ..writeByte(22)
      ..write(obj.idPhotoPaths)
      ..writeByte(23)
      ..write(obj.textAnnotations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
