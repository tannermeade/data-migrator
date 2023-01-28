part of appwrite.models;

/// UsageCollection
class UsageCollection implements Model {
    /// The time range of the usage stats.
    final String range;
    /// Aggregated stats for total number of documents.
    final List<MetricList> documentsCount;
    /// Aggregated stats for documents created.
    final List<MetricList> documentsCreate;
    /// Aggregated stats for documents read.
    final List<MetricList> documentsRead;
    /// Aggregated stats for documents updated.
    final List<MetricList> documentsUpdate;
    /// Aggregated stats for documents deleted.
    final List<MetricList> documentsDelete;

    UsageCollection({
        required this.range,
        required this.documentsCount,
        required this.documentsCreate,
        required this.documentsRead,
        required this.documentsUpdate,
        required this.documentsDelete,
    });

    factory UsageCollection.fromMap(Map<String, dynamic> map) {
        return UsageCollection(
            range: map['range'].toString(),
            documentsCount: List<MetricList>.from(map['documentsCount'].map((p) => MetricList.fromMap(p))),
            documentsCreate: List<MetricList>.from(map['documentsCreate'].map((p) => MetricList.fromMap(p))),
            documentsRead: List<MetricList>.from(map['documentsRead'].map((p) => MetricList.fromMap(p))),
            documentsUpdate: List<MetricList>.from(map['documentsUpdate'].map((p) => MetricList.fromMap(p))),
            documentsDelete: List<MetricList>.from(map['documentsDelete'].map((p) => MetricList.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "range": range,
            "documentsCount": documentsCount.map((p) => p.toMap()),
            "documentsCreate": documentsCreate.map((p) => p.toMap()),
            "documentsRead": documentsRead.map((p) => p.toMap()),
            "documentsUpdate": documentsUpdate.map((p) => p.toMap()),
            "documentsDelete": documentsDelete.map((p) => p.toMap()),
        };
    }
}
