import 'package:appwrite/appwrite.dart';

void main() { // Init SDK
  Client client = Client();
  Functions functions = Functions(client);

  client
    .setEndpoint('https://[HOSTNAME_OR_IP]/v1') // Your API Endpoint
    .setProject('5df5acd0d48c2') // Your project ID
  ;
  Future result = functions.retryBuild(
    functionId: '[FUNCTION_ID]',
    deploymentId: '[DEPLOYMENT_ID]',
    buildId: '[BUILD_ID]',
  );

  result
    .then((response) {
      print(response);
    }).catchError((error) {
      print(error.response);
  });
}
