part of appwrite.models;

/// Key
class Key implements Model {
    /// Key ID.
    final String $id;
    /// Key name.
    final String name;
    /// Allowed permission scopes.
    final List scopes;
    /// Secret key.
    final String secret;

    Key({
        required this.$id,
        required this.name,
        required this.scopes,
        required this.secret,
    });

    factory Key.fromMap(Map<String, dynamic> map) {
        return Key(
            $id: map['\$id'].toString(),
            name: map['name'].toString(),
            scopes: map['scopes'],
            secret: map['secret'].toString(),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "\$id": $id,
            "name": name,
            "scopes": scopes,
            "secret": secret,
        };
    }
}
