part of appwrite.models;

/// StorageUsage
class UsageStorage implements Model {
    /// The time range of the usage stats.
    final String range;
    /// Aggregated stats for the occupied storage size (in bytes).
    final List<MetricList> storage;
    /// Aggregated stats for total number of files.
    final List<MetricList> filesCount;
    /// Aggregated stats for total number of buckets.
    final List<MetricList> bucketsCount;
    /// Aggregated stats for buckets created.
    final List<MetricList> bucketsCreate;
    /// Aggregated stats for buckets read.
    final List<MetricList> bucketsRead;
    /// Aggregated stats for buckets updated.
    final List<MetricList> bucketsUpdate;
    /// Aggregated stats for buckets deleted.
    final List<MetricList> bucketsDelete;
    /// Aggregated stats for files created.
    final List<MetricList> filesCreate;
    /// Aggregated stats for files read.
    final List<MetricList> filesRead;
    /// Aggregated stats for files updated.
    final List<MetricList> filesUpdate;
    /// Aggregated stats for files deleted.
    final List<MetricList> filesDelete;

    UsageStorage({
        required this.range,
        required this.storage,
        required this.filesCount,
        required this.bucketsCount,
        required this.bucketsCreate,
        required this.bucketsRead,
        required this.bucketsUpdate,
        required this.bucketsDelete,
        required this.filesCreate,
        required this.filesRead,
        required this.filesUpdate,
        required this.filesDelete,
    });

    factory UsageStorage.fromMap(Map<String, dynamic> map) {
        return UsageStorage(
            range: map['range'].toString(),
            storage: List<MetricList>.from(map['storage'].map((p) => MetricList.fromMap(p))),
            filesCount: List<MetricList>.from(map['filesCount'].map((p) => MetricList.fromMap(p))),
            bucketsCount: List<MetricList>.from(map['bucketsCount'].map((p) => MetricList.fromMap(p))),
            bucketsCreate: List<MetricList>.from(map['bucketsCreate'].map((p) => MetricList.fromMap(p))),
            bucketsRead: List<MetricList>.from(map['bucketsRead'].map((p) => MetricList.fromMap(p))),
            bucketsUpdate: List<MetricList>.from(map['bucketsUpdate'].map((p) => MetricList.fromMap(p))),
            bucketsDelete: List<MetricList>.from(map['bucketsDelete'].map((p) => MetricList.fromMap(p))),
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
            "storage": storage.map((p) => p.toMap()),
            "filesCount": filesCount.map((p) => p.toMap()),
            "bucketsCount": bucketsCount.map((p) => p.toMap()),
            "bucketsCreate": bucketsCreate.map((p) => p.toMap()),
            "bucketsRead": bucketsRead.map((p) => p.toMap()),
            "bucketsUpdate": bucketsUpdate.map((p) => p.toMap()),
            "bucketsDelete": bucketsDelete.map((p) => p.toMap()),
            "filesCreate": filesCreate.map((p) => p.toMap()),
            "filesRead": filesRead.map((p) => p.toMap()),
            "filesUpdate": filesUpdate.map((p) => p.toMap()),
            "filesDelete": filesDelete.map((p) => p.toMap()),
        };
    }
}
