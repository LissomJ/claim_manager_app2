// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_text_annotation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfTextAnnotationAdapter extends TypeAdapter<PdfTextAnnotation> {
  @override
  final int typeId = 2;

  @override
  PdfTextAnnotation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdfTextAnnotation(
      text: fields[0] as String,
      dx: fields[1] as double,
      dy: fields[2] as double,
      fontSize: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PdfTextAnnotation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.dx)
      ..writeByte(2)
      ..write(obj.dy)
      ..writeByte(3)
      ..write(obj.fontSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfTextAnnotationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
