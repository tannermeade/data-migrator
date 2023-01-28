part of appwrite.models;

/// Functions List
class FunctionList implements Model {
    /// Total number of functions documents that matched your query.
    final int total;
    /// List of functions.
    final List<Funct> functions;

    FunctionList({
        required this.total,
        required this.functions,
    });

    factory FunctionList.fromMap(Map<String, dynamic> map) {
        return FunctionList(
            total: map['total'],
            functions: List<Funct>.from(map['functions'].map((p) => Funct.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "total": total,
            "functions": functions.map((p) => p.toMap()),
        };
    }
}
