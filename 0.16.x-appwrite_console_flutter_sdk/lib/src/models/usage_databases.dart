part of appwrite.models;

/// UsageDatabases
class UsageDatabases implements Model {
    /// The time range of the usage stats.
    final String range;
    /// Aggregated stats for total number of documents.
    final List<MetricList> databasesCount;
    /// Aggregated stats for total number of documents.
    final List<MetricList> documentsCount;
    /// Aggregated stats for total number of collections.
    final List<MetricList> collectionsCount;
    /// Aggregated stats for documents created.
    final List<MetricList> databasesCreate;
    /// Aggregated stats for documents read.
    final List<MetricList> databasesRead;
    /// Aggregated stats for documents updated.
    final List<MetricList> databasesUpdate;
    /// Aggregated stats for total number of collections.
    final List<MetricList> databasesDelete;
    /// Aggregated stats for documents created.
    final List<MetricList> documentsCreate;
    /// Aggregated stats for documents read.
    final List<MetricList> documentsRead;
    /// Aggregated stats for documents updated.
    final List<MetricList> documentsUpdate;
    /// Aggregated stats for documents deleted.
    final List<MetricList> documentsDelete;
    /// Aggregated stats for collections created.
    final List<MetricList> collectionsCreate;
    /// Aggregated stats for collections read.
    final List<MetricList> collectionsRead;
    /// Aggregated stats for collections updated.
    final List<MetricList> collectionsUpdate;
    /// Aggregated stats for collections delete.
    final List<MetricList> collectionsDelete;

    UsageDatabases({
        required this.range,
        required this.databasesCount,
        required this.documentsCount,
        required this.collectionsCount,
        required this.databasesCreate,
        required this.databasesRead,
        required this.databasesUpdate,
        required this.databasesDelete,
        required this.documentsCreate,
        required this.documentsRead,
        required this.documentsUpdate,
        required this.documentsDelete,
        required this.collectionsCreate,
        required this.collectionsRead,
        required this.collectionsUpdate,
        required this.collectionsDelete,
    });

    factory UsageDatabases.fromMap(Map<String, dynamic> map) {
        return UsageDatabases(
            range: map['range'].toString(),
            databasesCount: List<MetricList>.from(map['databasesCount'].map((p) => MetricList.fromMap(p))),
            documentsCount: List<MetricList>.from(map['documentsCount'].map((p) => MetricList.fromMap(p))),
            collectionsCount: List<MetricList>.from(map['collectionsCount'].map((p) => MetricList.fromMap(p))),
            databasesCreate: List<MetricList>.from(map['databasesCreate'].map((p) => MetricList.fromMap(p))),
            databasesRead: List<MetricList>.from(map['databasesRead'].map((p) => MetricList.fromMap(p))),
            databasesUpdate: List<MetricList>.from(map['databasesUpdate'].map((p) => MetricList.fromMap(p))),
            databasesDelete: List<MetricList>.from(map['databasesDelete'].map((p) => MetricList.fromMap(p))),
            documentsCreate: List<MetricList>.from(map['documentsCreate'].map((p) => MetricList.fromMap(p))),
            documentsRead: List<MetricList>.from(map['documentsRead'].map((p) => MetricList.fromMap(p))),
            documentsUpdate: List<MetricList>.from(map['documentsUpdate'].map((p) => MetricList.fromMap(p))),
            documentsDelete: List<MetricList>.from(map['documentsDelete'].map((p) => MetricList.fromMap(p))),
            collectionsCreate: List<MetricList>.from(map['collectionsCreate'].map((p) => MetricList.fromMap(p))),
            collectionsRead: List<MetricList>.from(map['collectionsRead'].map((p) => MetricList.fromMap(p))),
            collectionsUpdate: List<MetricList>.from(map['collectionsUpdate'].map((p) => MetricList.fromMap(p))),
            collectionsDelete: List<MetricList>.from(map['collectionsDelete'].map((p) => MetricList.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "range": range,
            "databasesCount": databasesCount.map((p) => p.toMap()),
            "documentsCount": documentsCount.map((p) => p.toMap()),
            "collectionsCount": collectionsCount.map((p) => p.toMap()),
            "databasesCreate": databasesCreate.map((p) => p.toMap()),
            "databasesRead": databasesRead.map((p) => p.toMap()),
            "databasesUpdate": databasesUpdate.map((p) => p.toMap()),
            "databasesDelete": databasesDelete.map((p) => p.toMap()),
            "documentsCreate": documentsCreate.map((p) => p.toMap()),
            "documentsRead": documentsRead.map((p) => p.toMap()),
            "documentsUpdate": documentsUpdate.map((p) => p.toMap()),
            "documentsDelete": documentsDelete.map((p) => p.toMap()),
            "collectionsCreate": collectionsCreate.map((p) => p.toMap()),
            "collectionsRead": collectionsRead.map((p) => p.toMap()),
            "collectionsUpdate": collectionsUpdate.map((p) => p.toMap()),
            "collectionsDelete": collectionsDelete.map((p) => p.toMap()),
        };
    }
}
