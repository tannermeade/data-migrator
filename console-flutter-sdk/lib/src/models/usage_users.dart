part of appwrite.models;

/// UsageUsers
class UsageUsers implements Model {
    /// The time range of the usage stats.
    final String range;
    /// Aggregated stats for total number of users.
    final List<MetricList> usersCount;
    /// Aggregated stats for users created.
    final List<MetricList> usersCreate;
    /// Aggregated stats for users read.
    final List<MetricList> usersRead;
    /// Aggregated stats for users updated.
    final List<MetricList> usersUpdate;
    /// Aggregated stats for users deleted.
    final List<MetricList> usersDelete;
    /// Aggregated stats for sessions created.
    final List<MetricList> sessionsCreate;
    /// Aggregated stats for sessions created for a provider ( email, anonymous or oauth2 ).
    final List<MetricList> sessionsProviderCreate;
    /// Aggregated stats for sessions deleted.
    final List<MetricList> sessionsDelete;

    UsageUsers({
        required this.range,
        required this.usersCount,
        required this.usersCreate,
        required this.usersRead,
        required this.usersUpdate,
        required this.usersDelete,
        required this.sessionsCreate,
        required this.sessionsProviderCreate,
        required this.sessionsDelete,
    });

    factory UsageUsers.fromMap(Map<String, dynamic> map) {
        return UsageUsers(
            range: map['range'].toString(),
            usersCount: List<MetricList>.from(map['usersCount'].map((p) => MetricList.fromMap(p))),
            usersCreate: List<MetricList>.from(map['usersCreate'].map((p) => MetricList.fromMap(p))),
            usersRead: List<MetricList>.from(map['usersRead'].map((p) => MetricList.fromMap(p))),
            usersUpdate: List<MetricList>.from(map['usersUpdate'].map((p) => MetricList.fromMap(p))),
            usersDelete: List<MetricList>.from(map['usersDelete'].map((p) => MetricList.fromMap(p))),
            sessionsCreate: List<MetricList>.from(map['sessionsCreate'].map((p) => MetricList.fromMap(p))),
            sessionsProviderCreate: List<MetricList>.from(map['sessionsProviderCreate'].map((p) => MetricList.fromMap(p))),
            sessionsDelete: List<MetricList>.from(map['sessionsDelete'].map((p) => MetricList.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "range": range,
            "usersCount": usersCount.map((p) => p.toMap()),
            "usersCreate": usersCreate.map((p) => p.toMap()),
            "usersRead": usersRead.map((p) => p.toMap()),
            "usersUpdate": usersUpdate.map((p) => p.toMap()),
            "usersDelete": usersDelete.map((p) => p.toMap()),
            "sessionsCreate": sessionsCreate.map((p) => p.toMap()),
            "sessionsProviderCreate": sessionsProviderCreate.map((p) => p.toMap()),
            "sessionsDelete": sessionsDelete.map((p) => p.toMap()),
        };
    }
}
