import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin.dart';

class MysqlOrigin extends DataOrigin {
  MysqlOrigin() : super();

  @override
  bool get isConversionReady => false;

  @override
  void endDataStream(List<int> schemaIndex) {
    // TODO: implement endDataStream
  }

  @override
  Stream<List<List>> getDataStream(List<int> schemaIndex) {
    // TODO: implement getStream
    throw UnimplementedError();
  }

  @override
  void pauseDataStream(List<int> schemaIndex) {
    // TODO: implement pauseDataStream
  }

  @override
  Stream<List<List>> startDataStream(List<int> schemaIndex) {
    // TODO: implement startDataStream
    throw UnimplementedError();
  }

  @override
  Stream<List<List>>? playDataStream(List<int> schemaIndex) {
    // TODO: implement playDataStream
    throw UnimplementedError();
  }

  @override
  // TODO: implement schema
  List<SchemaMap> get schema => throw UnimplementedError();

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
  void removeSchema(schemaObj) {
    // TODO: implement removeSchema
  }
}
