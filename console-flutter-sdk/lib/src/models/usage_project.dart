part of appwrite.models;

/// UsageProject
class UsageProject implements Model {
    /// The time range of the usage stats.
    final String range;
    /// Aggregated stats for number of requests.
    final List<MetricList> requests;
    /// Aggregated stats for consumed bandwidth.
    final List<MetricList> network;
    /// Aggregated stats for function executions.
    final List<MetricList> functions;
    /// Aggregated stats for number of documents.
    final List<MetricList> documents;
    /// Aggregated stats for number of collections.
    final List<MetricList> collections;
    /// Aggregated stats for number of users.
    final List<MetricList> users;
    /// Aggregated stats for the occupied storage size (in bytes).
    final List<MetricList> storage;

    UsageProject({
        required this.range,
        required this.requests,
        required this.network,
        required this.functions,
        required this.documents,
        required this.collections,
        required this.users,
        required this.storage,
    });

    factory UsageProject.fromMap(Map<String, dynamic> map) {
        return UsageProject(
            range: map['range'].toString(),
            requests: List<MetricList>.from(map['requests'].map((p) => MetricList.fromMap(p))),
            network: List<MetricList>.from(map['network'].map((p) => MetricList.fromMap(p))),
            functions: List<MetricList>.from(map['functions'].map((p) => MetricList.fromMap(p))),
            documents: List<MetricList>.from(map['documents'].map((p) => MetricList.fromMap(p))),
            collections: List<MetricList>.from(map['collections'].map((p) => MetricList.fromMap(p))),
            users: List<MetricList>.from(map['users'].map((p) => MetricList.fromMap(p))),
            storage: List<MetricList>.from(map['storage'].map((p) => MetricList.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "range": range,
            "requests": requests.map((p) => p.toMap()),
            "network": network.map((p) => p.toMap()),
            "functions": functions.map((p) => p.toMap()),
            "documents": documents.map((p) => p.toMap()),
            "collections": collections.map((p) => p.toMap()),
            "users": users.map((p) => p.toMap()),
            "storage": storage.map((p) => p.toMap()),
        };
    }
}
