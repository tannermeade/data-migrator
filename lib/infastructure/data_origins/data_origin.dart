import 'package:data_migrator/domain/data_types/schema_map.dart';

abstract class DataOrigin {
  DataOrigin();

  List<SchemaMap> get schema;
  void removeSchema(dynamic schemaObj);

  Stream<List<List>>? getDataStream(List<int> schemaIndex);
  Stream<List<List>> startDataStream(List<int> schemaIndex);
  Stream<List<List>>? playDataStream(List<int> schemaIndex);
  void pauseDataStream(List<int> schemaIndex);
  void endDataStream(List<int> schemaIndex);

  Sink<List<List>>? getDataSink(List<int> schemaIndex);
  Future<Sink<List<List>>> openDataSink(List<int> schemaIndex);
  void closeDataSink(List<int> schemaIndex);

  bool get isConversionReady;
}
