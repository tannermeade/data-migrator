import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:file_picker/file_picker.dart';

class CsvFile {
  CsvFile({
    required this.file,
    required this.schema,
    required this.schemaByteEnd,
  });

  PlatformFile file;
  SchemaMap schema;
  int schemaByteEnd;
  Stream? stream;

  @override
  String toString() {
    return "CsvFile(\n\tfile:${file.name}, \n\tschemaByteEnd:$schemaByteEnd, \n\tschema:$schema\n)";
  }
}
