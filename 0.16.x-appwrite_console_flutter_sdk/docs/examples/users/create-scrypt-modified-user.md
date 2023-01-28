import 'package:appwrite/appwrite.dart';

void main() { // Init SDK
  Client client = Client();
  Users users = Users(client);

  client
    .setEndpoint('https://[HOSTNAME_OR_IP]/v1') // Your API Endpoint
    .setProject('5df5acd0d48c2') // Your project ID
  ;
  Future result = users.createScryptModifiedUser(
    userId: '[USER_ID]',
    email: 'email@example.com',
    password: 'password',
    passwordSalt: '[PASSWORD_SALT]',
    passwordSaltSeparator: '[PASSWORD_SALT_SEPARATOR]',
    passwordSignerKey: '[PASSWORD_SIGNER_KEY]',
  );

  result
    .then((response) {
      print(response);
    }).catchError((error) {
      print(error.response);
  });
}
