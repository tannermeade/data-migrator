import 'dart:async';
import 'dart:io';
import 'package:data_migrator/infastructure/confirmation/confirmation_data.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_object.dart';
import 'package:data_migrator/infastructure/data_origins/csv_origin/csv_configuration.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'csv_file.dart';

class CsvOrigin extends DataOrigin {
  CsvOrigin() : super();

  List<CsvFile> csvFiles = [];

  @override
  CSVConfiguration get config => CSVConfiguration();

  @override
  bool get isConversionReady => csvFiles.isNotEmpty;

  @override
  List<SchemaMap> getSchema() => csvFiles.map((f) => f.schema).toList();

  @override
  void addToSchema({required SchemaObject newObj, required SchemaObject parentObj}) {
    // TODO: implement addToSchema
  }

  @override
  void deleteFromSchema({required SchemaObject schemaObj}) {
    for (int i = 0; i < csvFiles.length; i++) {
      if (csvFiles[i].schema.hashCode == schemaObj.hashCode) csvFiles.removeAt(i);
    }
  }

  @override
  void updateSchema({required SchemaObject newObj, required SchemaObject oldObj}) {
    // TODO: implement updateSchema
  }

  StreamController<List<List>>? _streamController;
  bool _cancelStream = false;
  int? byteCount;

  @override
  Stream<List<List>> startDataStream(List<int> schemaIndex) {
    _streamController = StreamController<List<List>>();
    _beginStream(csvFiles[schemaIndex.first], csvFiles[schemaIndex.first].schemaByteEnd).firstWhere(
      _handleStream,
      orElse: () {
        if (_streamController != null) {
          _streamController!.close();
          _cancelStream = false;
        }
        return [];
      },
    );
    return _streamController!.stream;
  }

  String _streamLastLine = "";

  bool _handleStream(List<int> bytes) {
    byteCount = (byteCount ?? 0) + bytes.length;
    var lines = String.fromCharCodes(bytes).split("\n");
    lines.first = _streamLastLine + lines.first;
    _streamLastLine = lines.length > 1 ? lines.last : "";
    if ((lines.length > 1 && lines.last.isEmpty) || (byteCount != null && byteCount! < csvFiles.first.file.size - 1)) {
      lines = lines.sublist(0, lines.length - 1);
    }
    var rows = lines.map((l) {
      var data = _convertCsvStringToData(l);
      return data.isEmpty ? [] : data.first;
    }).toList();
    _streamController!.sink.add(rows);
    if (_cancelStream) {
      _streamController!.close();
      _cancelStream = false;
      return true;
    }
    return _cancelStream;
  }

  Stream<List<int>> _beginStream(CsvFile csvFile, int startByte) {
    File file = File(csvFile.file.path!);
    byteCount = startByte;
    _cancelStream = false;
    return file.openRead(startByte + 1);
  }

  @override
  Stream<List<List>>? getDataStream(List<int> schemaIndex) {
    return _streamController != null ? _streamController!.stream : null;
  }

  @override
  void endDataStream(List<int> schemaIndex) {
    _cancelStream = true;
  }

  @override
  void pauseDataStream(List<int> schemaIndex) {
    _cancelStream = true;
  }

  @override
  Stream<List<List>> playDataStream(List<int> schemaIndex) {
    _streamController = StreamController<List<List>>();
    _beginStream(csvFiles[schemaIndex.first], byteCount ?? csvFiles[schemaIndex.first].schemaByteEnd)
        .firstWhere(_handleStream);
    return _streamController!.stream;
  }

  Future<FilePickerResult?> loadCSV() async => await _loadFiles();

  Future<FilePickerResult?> _loadFiles() async {
    var pickedFiles = await _pickFiles();
    if (pickedFiles == null || pickedFiles.files.isEmpty) return null;

    for (var platformFile in pickedFiles.files) {
      csvFiles.add(await _parseFile(platformFile));
    }
    return pickedFiles;
  }

  Future<CsvFile> _parseFile(PlatformFile platformFile) async {
    var file = File(platformFile.path!);
    var schemaString = await _readFileSchema(file);
    var schemaData = _convertCsvStringToData(schemaString).first;
    SchemaMap schema = await _parseSchema(schemaData, platformFile.name);

    int schemaByteEnd = schemaString.codeUnits.length;

    var types = await _calculateTypesForNRows(
      file: file,
      rowCount: 1000,
      schemaByteEnd: schemaByteEnd,
    );
    List<SchemaField> fields = [];
    for (int i = 0; i < schema.fields.length; i++) {
      var fieldTypes = types[i].isNotEmpty ? types[i] : {String};
      fields.add(SchemaField.copyWith(
        schema.fields[i],
        types: SchemaField.setTypes(fieldTypes),
      ));
    }

    return CsvFile(
      file: platformFile,
      schema: SchemaMap.copyWith(schema, fields: fields),
      schemaByteEnd: schemaByteEnd,
    );
  }

  Future<List<Set<Type>>> _calculateTypesForNRows({
    required File file,
    required int rowCount,
    required int schemaByteEnd,
  }) async {
    List<String> dataStrings = await _readFileData(file, schemaByteEnd, rowCount);
    var types = await _getFieldTypes(dataStrings);
    return types;
  }

  Future<List<Set<Type>>> _getFieldTypes(List<String> dataStrings) async {
    List<Set<Type>> fieldTypes = [];
    int x;
    for (int i = 0; i < dataStrings.length; i++) {
      List<List> data = _convertCsvStringToData(dataStrings[i]);
      if (data.isEmpty) continue;
      // reset column counter
      x = 0;
      // needs data.first because converter put row in a list
      for (var field in data.first) {
        // empty string don't provide valuable info on the data type
        bool isEmptyString = field.runtimeType == String && (field as String).isEmpty;
        if (i == 0) {
          // initialize sets
          fieldTypes.add(isEmptyString ? {} : {field.runtimeType});
        } else if (!isEmptyString) {
          fieldTypes[x].add(field.runtimeType);
        }
        // increment column
        x++;
      }
    }
    return fieldTypes;
  }

  Future<List<String>> _readFileData(File file, int startByte, int dataRows) async {
    List<String> strLines = [];
    String lastLine = "";
    int byteCount = 0;
    try {
      await file.openRead(startByte).firstWhere((bytes) {
        byteCount += bytes.length;
        var lines = String.fromCharCodes(bytes).split("\n");
        lines.first = lastLine + lines.first;
        lastLine = lines.length > 1 ? lines.last : "";
        strLines.addAll(lines);
        return lines.length > dataRows;
      });
    } catch (e) {
      print(
          "WARNING: Error thrown while reading csv file. Probably tried reading more row than available in file. Error "
          "handled and continuing with program...");
    }

    int totalBytes = file.openSync().lengthSync();
    if (totalBytes != startByte + byteCount) strLines.removeLast();
    if (strLines.first.isEmpty) strLines.removeAt(0);

    return strLines;
  }

  Future<SchemaMap> _parseSchema(List<dynamic> data, String mapName) async {
    var fields = data
        .map((d) => SchemaField(
              types: [],
              title: d,
              isList: false,
              required: true,
            ))
        .toList();

    return SchemaMap(
      fields: fields,
      name: mapName,
    );
  }

  Future<String> _readFileSchema(File file) async {
    List<String> strLines = [];
    await file.openRead().firstWhere((bytes) {
      var lines = String.fromCharCodes(bytes).split("\n");
      strLines.addAll(lines);
      return lines.length > 1;
    });

    return strLines.first;
  }

  Future<FilePickerResult?> _pickFiles() async {
    var pickedFiles = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: true,
    );
    print("done picking file...");
    print(pickedFiles != null ? pickedFiles.count : "result is null");
    print(pickedFiles != null ? pickedFiles.names : "result is null");
    print(pickedFiles != null ? pickedFiles.files.first.path : "result is null");
    return pickedFiles;
  }

  Future<String?> _getWholeFile() async {
    var pickedFiles = await _pickFiles();
    if (pickedFiles == null || pickedFiles.files.isEmpty) return null;

    var file = File(pickedFiles.files.first.path!);
    var fileString = await file.readAsString();
    print(fileString);
    return fileString;
  }

  List<List<dynamic>> _convertCsvStringToData(String csvStr) {
    var rowsAsListOfValues = const CsvToListConverter().convert(
      csvStr,
      shouldParseNumbers: true,
    );
    return rowsAsListOfValues;
  }

  @override
  Sink<List<List>>? getDataSink(List<int> schemaIndex) {
    // TODO: implement getDataSink
    throw UnimplementedError();
  }

  @override
  void closeDataSink(List<int> schemaIndex) {
    // TODO: implement closeDataSink
  }

  @override
  Future<Sink<List<List>>> openDataSink(List<int> schemaIndex) {
    // TODO: implement openDataSink
    throw UnimplementedError();
  }

  @override
  Future<List<ConfirmationData>> validate() async {
    if (csvFiles.isEmpty) throw Exception("No CSV files selected.");
    return [];
  }

  @override
  void addCustomSchema(Type type) {
    // TODO: implement addCustomSchema
  }

  @override
  Map<String, Type> getCustomSchemaTypes() => {};
}
