part of appwrite.models;

/// Collections List
class CollectionList implements Model {
    /// Total number of items available on the server.
    final int sum;
    /// List of collections.
    final List<Collection> collections;

    CollectionList({
        required this.sum,
        required this.collections,
    });

    factory CollectionList.fromMap(Map<String, dynamic> map) {
        return CollectionList(
            sum: map['sum'],
            collections: List<Collection>.from(map['collections'].map((p) => Collection.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "sum": sum,
            "collections": collections.map((p) => p.toMap()),
        };
    }
}
