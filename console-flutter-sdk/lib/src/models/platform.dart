part of appwrite.models;

/// Platform
class Platform implements Model {
    /// Platform ID.
    final String $id;
    /// Platform name.
    final String name;
    /// Platform type. Possible values are: web, flutter-ios, flutter-android, ios, android, and unity.
    final String type;
    /// Platform Key. iOS bundle ID or Android package name.  Empty string for other platforms.
    final String key;
    /// App store or Google Play store ID.
    final String store;
    /// Web app hostname. Empty string for other platforms.
    final String hostname;
    /// HTTP basic authentication username.
    final String httpUser;
    /// HTTP basic authentication password.
    final String httpPass;

    Platform({
        required this.$id,
        required this.name,
        required this.type,
        required this.key,
        required this.store,
        required this.hostname,
        required this.httpUser,
        required this.httpPass,
    });

    factory Platform.fromMap(Map<String, dynamic> map) {
        return Platform(
            $id: map['\$id'].toString(),
            name: map['name'].toString(),
            type: map['type'].toString(),
            key: map['key'].toString(),
            store: map['store'].toString(),
            hostname: map['hostname'].toString(),
            httpUser: map['httpUser'].toString(),
            httpPass: map['httpPass'].toString(),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "\$id": $id,
            "name": name,
            "type": type,
            "key": key,
            "store": store,
            "hostname": hostname,
            "httpUser": httpUser,
            "httpPass": httpPass,
        };
    }
}
