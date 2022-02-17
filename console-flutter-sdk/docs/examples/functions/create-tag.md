import 'package:appwrite/appwrite.dart';

void main() { // Init SDK
  Client client = Client();
  Functions functions = Functions(client);

  client
    .setEndpoint('https://[HOSTNAME_OR_IP]/v1') // Your API Endpoint
    .setProject('5df5acd0d48c2') // Your project ID
  ;
  Future result = functions.createTag(
    functionId: '[FUNCTION_ID]',
    command: '[COMMAND]',
    code: await MultipartFile.fromPath('code', './path-to-files/image.jpg', 'image.jpg'),
  );

  result
    .then((response) {
      print(response);
    }).catchError((error) {
      print(error.response);
  });
}
