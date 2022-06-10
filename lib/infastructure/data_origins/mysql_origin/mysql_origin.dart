import 'package:data_migrator/infastructure/confirmation/confirmation_data.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_object.dart';
import 'package:data_migrator/domain/data_types/schema_data_type.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin_configration.dart';
import 'package:data_migrator/infastructure/data_origins/mysql_origin/mysql_configuration.dart';

class MysqlOrigin extends DataOrigin {
  MysqlOrigin() : super();

  @override
  MySQLConfiguration get config => MySQLConfiguration();

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
  void addToSchema({required SchemaObject newObj, required SchemaObject parentObj}) {
    // TODO: implement addToSchema
  }

  @override
  void deleteFromSchema({required SchemaObject schemaObj}) {
    // TODO: implement deleteFromSchema
  }

  @override
  List<SchemaMap> getSchema() {
    // TODO: implement getSchema
    throw UnimplementedError();
  }

  @override
  void updateSchema({required SchemaObject newObj, required SchemaObject oldObj}) {
    // TODO: implement updateSchema
  }

  @override
  Future<List<ConfirmationData>> validate() async {
    // TODO: implement validate
    throw UnimplementedError();
  }

  @override
  void addCustomSchema(Type type) {
    // TODO: implement addCustomSchema
  }

  @override
  Map<String, Type> getCustomSchemaTypes() => {};
}
