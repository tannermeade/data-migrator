part of appwrite.models;

/// Platforms List
class PlatformList implements Model {
    /// Total number of platforms documents that matched your query.
    final int total;
    /// List of platforms.
    final List<Platform> platforms;

    PlatformList({
        required this.total,
        required this.platforms,
    });

    factory PlatformList.fromMap(Map<String, dynamic> map) {
        return PlatformList(
            total: map['total'],
            platforms: List<Platform>.from(map['platforms'].map((p) => Platform.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "total": total,
            "platforms": platforms.map((p) => p.toMap()),
        };
    }
}
