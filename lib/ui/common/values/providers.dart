import 'package:data_migrator/domain/conversion/conversion/schema_converter.dart';
import 'package:data_migrator/infastructure/data_origins/appwrite_origin/appwrite_origin.dart';
import 'package:data_migrator/infastructure/data_origins/csv_origin/csv_origin.dart';
import 'package:console_flutter_sdk/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sourceOriginProvider = StateProvider((ref) => AppwriteOrigin());
final destinationOriginProvider = StateProvider((ref) => AppwriteOrigin());
final converterProvider = StateProvider((ref) => SchemaConverter());
