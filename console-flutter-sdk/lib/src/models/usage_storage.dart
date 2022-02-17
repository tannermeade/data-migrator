part of appwrite.models;

/// StorageUsage
class UsageStorage implements Model {
    /// The time range of the usage stats.
    final String range;
    /// Aggregated stats for the occupied storage size (in bytes).
    final List<MetricList> storage;
    /// Aggregated stats for total number of files.
    final List<MetricList> files;

    UsageStorage({
        required this.range,
        required this.storage,
        required this.files,
    });

    factory UsageStorage.fromMap(Map<String, dynamic> map) {
        return UsageStorage(
            range: map['range'].toString(),
            storage: List<MetricList>.from(map['storage'].map((p) => MetricList.fromMap(p))),
            files: List<MetricList>.from(map['files'].map((p) => MetricList.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "range": range,
            "storage": storage.map((p) => p.toMap()),
            "files": files.map((p) => p.toMap()),
        };
    }
}
