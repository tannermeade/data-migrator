part of appwrite.models;

/// Key
class Key implements Model {
    /// Key ID.
    final String $id;
    /// Key creation date in Datetime
    final String $createdAt;
    /// Key update date in Datetime
    final String $updatedAt;
    /// Key name.
    final String name;
    /// Key expiration date in Datetime
    final String expire;
    /// Allowed permission scopes.
    final List scopes;
    /// Secret key.
    final String secret;
    /// Most recent access date in Unix timestamp.
    final String accessedAt;
    /// List of SDK user agents that used this key.
    final List sdks;

    Key({
        required this.$id,
        required this.$createdAt,
        required this.$updatedAt,
        required this.name,
        required this.expire,
        required this.scopes,
        required this.secret,
        required this.accessedAt,
        required this.sdks,
    });

    factory Key.fromMap(Map<String, dynamic> map) {
        return Key(
            $id: map['\$id'].toString(),
            $createdAt: map['\$createdAt'].toString(),
            $updatedAt: map['\$updatedAt'].toString(),
            name: map['name'].toString(),
            expire: map['expire'].toString(),
            scopes: map['scopes'],
            secret: map['secret'].toString(),
            accessedAt: map['accessedAt'].toString(),
            sdks: map['sdks'],
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "\$id": $id,
            "\$createdAt": $createdAt,
            "\$updatedAt": $updatedAt,
            "name": name,
            "expire": expire,
            "scopes": scopes,
            "secret": secret,
            "accessedAt": accessedAt,
            "sdks": sdks,
        };
    }
}
