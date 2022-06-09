import 'dart:async';
import 'package:data_migrator/infastructure/confirmation/confirmation_data.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_object.dart';
import 'package:data_migrator/domain/data_types/schema_map.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/data_types/appwrite_configuration.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/tools/appwrite_adapter.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/tools/appwrite_pipeline_destination.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/tools/appwrite_schema_modification.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/tools/appwrite_schema_validation.dart';
import 'package:data_migrator/infastructure/data_origins/data_origin.dart';
import 'package:console_flutter_sdk/models.dart' as model;

class AppwriteOrigin extends DataOrigin {
  AppwriteOrigin() : super() {
    _pipelineDestination = AppwritePipelineDestination(adapter: _adapter);
    _schemaValidation = AppwriteSchemaValidation(adapter: _adapter);
  }

  final AppwriteAdapter _adapter = AppwriteAdapter();
  late final AppwritePipelineDestination _pipelineDestination;
  late final AppwriteSchemaValidation _schemaValidation;

  List<SchemaMap> _schema = [];
  List<SchemaMap> get schema => _schema;

  @override
  AppwriteConfiguration get config => _adapter.config;

  @override
  bool get isConversionReady =>
      _schema.isNotEmpty &&
      isAuthenticated &&
      _adapter.config.selectedProject != null &&
      _adapter.config.endpoint != null &&
      _adapter.config.currentAPIKey != null &&
      _adapter.config.bundleByteSize > 0;

  bool get isAuthenticated =>
      _adapter.config.session != null &&
      DateTime.fromMillisecondsSinceEpoch(_adapter.config.session!.expire * 1000).compareTo(DateTime.now()) > 0;
  model.Project? get selectedProject => _adapter.config.selectedProject;
  String? get currentEndpoint => _adapter.config.endpoint;
  set apiKey(String str) => _adapter.config.currentAPIKey = str;
  String? get currentAPIKey => _adapter.config.currentAPIKey;

  @override
  List<SchemaMap> getSchema() => _schema;

  @override
  void addToSchema({required SchemaObject newObj, required SchemaObject parentObj}) {
    // TODO: implement addToSchema
  }

  @override
  void deleteFromSchema({required SchemaObject schemaObj}) {
    var result = deleteFromSchemaRecursive(_schema, schemaObj.hashCode);
    _schema = result;
  }

  @override
  void updateSchema({required SchemaObject newObj, required SchemaObject oldObj}) {
    var result = updateSchemaRecursive(_schema, oldObj.hashCode, newObj);
    _schema = result;
  }

  @override
  Stream<List<List>> startDataStream(List<int> schemaIndex) {
    // TODO: implement startDataStream
    throw UnimplementedError();
  }

  @override
  Stream<List<List>> getDataStream(List<int> schemaIndex) {
    // TODO: implement getStream
    throw UnimplementedError();
  }

  @override
  void endDataStream(List<int> schemaIndex) {
    // TODO: implement endDataStream
  }

  @override
  void pauseDataStream(List<int> schemaIndex) {
    // TODO: implement pauseDataStream
  }

  @override
  Stream<List<List>>? playDataStream(List<int> schemaIndex) {
    // TODO: implement playDataStream
    throw UnimplementedError();
  }

  void addSchemaFromSchema(List<SchemaMap> sourceSchema) {
    AppwriteSchemaModification.addSchemaFromSchema(sourceSchema, (s) => _schema.add(s));
  }

  Future logout() async => await _adapter.logout();

  Future authenticate({
    required String email,
    required String password,
    required String endpoint,
  }) async =>
      await _adapter.authenticate(email: email, password: password, endpoint: endpoint);

  Future selectProject(model.Project project) async => await _adapter.selectProject(project);

  Future<model.ProjectList> getProjects() async => await _adapter.getProjects();

  Future<List<SchemaMap>> getRemoteSchema() async {
    var collectionsList = await _adapter.getCollections();
    var schemaMaps = AppwriteSchemaModification.collectionsToSchema(collectionsList);
    return schemaMaps;
  }

  @override
  Sink<List<List>>? getDataSink(List<int> schemaIndex) => _pipelineDestination.getDataSink(schemaIndex);

  @override
  void closeDataSink(List<int> schemaIndex) => _pipelineDestination.closeDataSink(schemaIndex);

  @override
  Future<Sink<List<List>>> openDataSink(List<int> schemaIndex) async =>
      _pipelineDestination.openDataSink(schemaIndex, _schema);

  @override
  Future<List<ConfirmationData>> validate() async => await _schemaValidation.validate(_schema);
}
