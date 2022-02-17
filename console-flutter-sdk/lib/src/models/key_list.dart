part of appwrite.models;

/// API Keys List
class KeyList implements Model {
    /// Total number of items available on the server.
    final int sum;
    /// List of keys.
    final List<Key> keys;

    KeyList({
        required this.sum,
        required this.keys,
    });

    factory KeyList.fromMap(Map<String, dynamic> map) {
        return KeyList(
            sum: map['sum'],
            keys: List<Key>.from(map['keys'].map((p) => Key.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "sum": sum,
            "keys": keys.map((p) => p.toMap()),
        };
    }
}
