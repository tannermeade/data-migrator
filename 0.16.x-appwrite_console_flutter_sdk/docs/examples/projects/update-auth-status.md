import 'package:appwrite/appwrite.dart';

void main() { // Init SDK
  Client client = Client();
  Projects projects = Projects(client);

  client
    .setEndpoint('https://[HOSTNAME_OR_IP]/v1') // Your API Endpoint
    .setProject('5df5acd0d48c2') // Your project ID
  ;
  Future result = projects.updateAuthStatus(
    projectId: '[PROJECT_ID]',
    method: 'email-password',
    status: false,
  );

  result
    .then((response) {
      print(response);
    }).catchError((error) {
      print(error.response);
  });
}