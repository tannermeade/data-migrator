part of appwrite.models;

/// Indexes List
class IndexList implements Model {
    /// Total number of items available on the server.
    final int sum;
    /// List of indexes.
    final List<Index> indexes;

    IndexList({
        required this.sum,
        required this.indexes,
    });

    factory IndexList.fromMap(Map<String, dynamic> map) {
        return IndexList(
            sum: map['sum'],
            indexes: List<Index>.from(map['indexes'].map((p) => Index.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "sum": sum,
            "indexes": indexes.map((p) => p.toMap()),
        };
    }
}
