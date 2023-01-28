import 'dart:convert';
import 'package:console_flutter_sdk/appwrite.dart';

/*
  'req' variable has:
    'headers' - object with request headers
    'payload' - object with request body data
    'env' - object with environment variables

  'res' variable has:
    'send(text, status)' - function to return text response. Status code defaults to 200
    'json(obj, status)' - function to return JSON response. Status code defaults to 200
  
  If an error is thrown, a response with code 500 will be returned.
*/

Future<void> start(final req, final res) async {
  String resultString = 'hello world';
  // Initialise the client SDK

  final Client client = Client();
  client
      .setEndpoint(req.env['APPWRITE_ENDPOINT']!) // This is manually set
      .setProject(req.env['APPWRITE_FUNCTION_PROJECT_ID']) // this is available by default
      .setKey(req.env['APPWRITE_API_KEY']);

  resultString += '\nmade client obj';

  String? dataStr = req.env['APPWRITE_FUNCTION_DATA'];
  if (dataStr == null) return;

  var executionPayload = jsonDecode(dataStr);

  // return res.json({
  //   'areDevelopersAwesome': true,
  //   'debug': executionPayload,
  //   'result': resultString,
  // });

  String bundleId = executionPayload['fileId'];
  Map bundle = await getBundle(bundleId, client);

  resultString += '\ndone getting bundle';

  var insertResults = [];

  var destination = bundle['destination'];
  if (destination == "users") {
    print("destination: users");
    insertResults = await handleUsersInsert(client, bundle);
    print("done with user destination");
  } else {
    print("mark start.1");
    insertResults = await handleDatabaseInsert(client, bundle);
    print("mark start.2");
  }

  resultString += '--Inserted ' +
      insertResults.length.toString() +
      ' rows of data out of ' +
      bundle['data'].length.toString() +
      ' to collection \$id(' +
      'str(collectionId)' +
      ') in file \$id(' +
      bundleId +
      ')';

  return res.json({
    'areDevelopersAwesome': true,
    'debug': executionPayload,
    'result': resultString,
  });
}

Future<List> handleUsersInsert(Client client, Map bundle) async {
  print("inside handleUsersInsert()");
  // Prepare Data
  List preparedData = prepareData(bundle);
  print("done preparing data");
  print(preparedData);

  // Insert Users
  return await insertUsersData(client, preparedData);
}

Future<List> insertUsersData(Client client, List preparedData) async {
  print("inside insertUsersData()");
  // Prepare for user insert
  Users usersClient = Users(client);

  List results = [];
  for (Map userData in preparedData) {
    var userId = "unique()";
    if (userData.keys.contains("\$id") && userData["\$id"] != null) {
      userId = userData["\$id"];
    }

    var result = await usersClient.create(
      userId: userId,
      email: userData["email"],
      password: userData["password"],
      name: userData["name"],
    );
    results.add(result);
  }

  return results;
}

Future<List> handleDatabaseInsert(Client client, Map bundle) async {
  print("made to handleDatabaseInsert()");
  // Prepare Data
  List preparedData = prepareData(bundle);
  print("returned back from prepareData()");
  print(preparedData.length);
  print("mark: done preparing data");
  print(preparedData);

  // Insert Data
  var results = await insertDatabaseData(client, bundle['databaseId'], bundle['collectionId'], preparedData);
  print("mark inserting done");
  return results;
}

// Setup the appwrite SDK
Client setupClient(Map<String, String> envVars) {
  try {
    Client client = Client();
    client.setEndpoint(envVars['APPWRITE_ENDPOINT']!);
    client.setProject(envVars['APPWRITE_FUNCTION_PROJECT_ID']);
    client.setKey(envVars['APPWRITE_API_KEY']);
    return client;
  } catch (e) {
    throw Exception(
        "Failed creating client. Check cloud function's environment variables: APPWRITE_ENDPOINT, APPWRITE_FUNCTION_PROJECT_ID, APPWRITE_API_KEY");
  }
}

Future<Map> getBundle(String bundleId, Client client) async {
  try {
    // Get file from storage
    Storage storage = Storage(client);
    var data = await storage.getFileDownload(bucketId: 'data_migrator_upload_bucket_id', fileId: bundleId);
    var str = String.fromCharCodes(data);
    return jsonDecode(str);
  } catch (e) {
    print('Failed getting file from storage. Tried file \$id(' + bundleId + ')');
    throw Exception('Failed getting file from storage. Tried file \$id(' + bundleId + ')');
  }
}

List prepareData(Map bundle) {
  try {
    print("made it to prepareData()");

    // Get field list from bundle
    List fields = bundle['fields'];

    // Loop through data and prepare
    List dataList = [];
    print(">>>>>>>>>>>> preparing data");

    for (List dataRow in bundle['data']) {
      if (fields.length != dataRow.length) {
        throw Exception(
            "dataRow has a different field count than the collectin. data/fields:${dataRow.length}--${fields.length}--${fields.runtimeType}");
      }

      var dataMap = {};
      int i = 0;
      print(">>>> dataRow");
      print(dataRow);
      for (var dataField in dataRow) {
        print(">>> dataField");
        print(dataField);
        dataMap[fields[i]] = dataField;
        i += 1;
      }

      dataList.add(dataMap);
    }
    print("made it to the end of prepareData()");

    return dataList;
  } catch (e) {
    print('Failed connecting the data rows with collection attributes.');
    throw Exception('Failed connecting the data rows with collection attributes.');
  }
}

Future<List> insertDatabaseData(Client client, String databaseId, String collectionId, List preparedData) async {
  List insertResults = [];
  print("inserting... mark 1");
  try {
    // Prepare for database work
    var db = Databases(client, databaseId: databaseId);
    print("inserting... mark 2");

    // insert into database
    for (Map dataRow in preparedData) {
      print("inserting... mark 3");
      // preparing the id
      String id = 'unique()';
      if (dataRow.keys.contains('\$id')) {
        print("inserting... mark 4");
        id = dataRow['\$id'];
        dataRow.remove('\$id');
      }
      print("inserting... mark 5");
      print(id);
      print(dataRow);
      // inserting row

      var insertResult = await db.createDocument(
        collectionId: collectionId,
        documentId: id,
        data: dataRow,
        // {
        //   "address_id": 123,
        //   "address": "123 sdfsdf",
        //   "address2": "asdasdf",
        //   "district": "1234",
        //   "city_id": 12,
        //   "postal_code": "12312",
        //   "phone": "123-123-1234",
        //   "last_update": "1234-12-12",
        //   "email": "eeeeeemmaaiilll@email.email",
        //   "password": "passypassword",
        //   "hash": "hashyhashhash",
        // },
      );
      print("inserting... mark 6");
      print(insertResult);
      // return [];

      insertResults.add(insertResult);
      print("inserting... mark 7");
    }
    print("inserting... mark 8");
    // return [];
    return insertResults;
  } catch (e) {
    print('Failed inserting data rows into database. Number of rows completed were:');
    print(insertResults.length);
    throw Exception('Failed inserting data rows into database. Number of rows completed were:');
  }
}
