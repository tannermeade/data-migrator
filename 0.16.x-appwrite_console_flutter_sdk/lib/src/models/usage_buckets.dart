part of appwrite.models;

/// UsageBuckets
class UsageBuckets implements Model {
    /// The time range of the usage stats.
    final String range;
    /// Aggregated stats for total number of files in this bucket.
    final List<MetricList> filesCount;
    /// Aggregated stats for total storage of files in this bucket.
    final List<MetricList> filesStorage;
    /// Aggregated stats for files created.
    final List<MetricList> filesCreate;
    /// Aggregated stats for files read.
    final List<MetricList> filesRead;
    /// Aggregated stats for files updated.
    final List<MetricList> filesUpdate;
    /// Aggregated stats for files deleted.
    final List<MetricList> filesDelete;

    UsageBuckets({
        required this.range,
        required this.filesCount,
        required this.filesStorage,
        required this.filesCreate,
        required this.filesRead,
        required this.filesUpdate,
        required this.filesDelete,
    });

    factory UsageBuckets.fromMap(Map<String, dynamic> map) {
        return UsageBuckets(
            range: map['range'].toString(),
            filesCount: List<MetricList>.from(map['filesCount'].map((p) => MetricList.fromMap(p))),
            filesStorage: List<MetricList>.from(map['filesStorage'].map((p) => MetricList.fromMap(p))),
            filesCreate: List<MetricList>.from(map['filesCreate'].map((p) => MetricList.fromMap(p))),
            filesRead: List<MetricList>.from(map['filesRead'].map((p) => MetricList.fromMap(p))),
            filesUpdate: List<MetricList>.from(map['filesUpdate'].map((p) => MetricList.fromMap(p))),
            filesDelete: List<MetricList>.from(map['filesDelete'].map((p) => MetricList.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "range": range,
            "filesCount": filesCount.map((p) => p.toMap()),
            "filesStorage": filesStorage.map((p) => p.toMap()),
            "filesCreate": filesCreate.map((p) => p.toMap()),
            "filesRead": filesRead.map((p) => p.toMap()),
            "filesUpdate": filesUpdate.map((p) => p.toMap()),
            "filesDelete": filesDelete.map((p) => p.toMap()),
        };
    }
}
