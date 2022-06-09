import 'package:console_flutter_sdk/appwrite.dart';
import 'package:console_flutter_sdk/models.dart' as models;
import 'package:data_migrator/infastructure/data_origins/data_origin_configration.dart';

class AppwriteConfiguration extends DataOriginConfiguration {
  AppwriteConfiguration({
    Client? client,
    this.currentAPIKey,
    this.endpoint,
    this.migratorFunct,
    this.migratorFunctDeployment,
    this.selectedProject,
    this.session,
    this.bundleByteSize = 500000, // 500KB
    this.bucketId = 'data_migrator_upload_bucket_id',
  }) : client = client ?? Client();

  String? endpoint;
  models.Session? session;
  final Client client;
  models.Project? selectedProject;
  models.Funct? migratorFunct;
  final String migratorFunctionId = "MigratorInsertFunctionId";
  models.Deployment? migratorFunctDeployment;
  String? currentAPIKey;
  int bundleByteSize;
  String bucketId;
}
