part of appwrite.models;

/// Platforms List
class PlatformList implements Model {
    /// Total number of items available on the server.
    final int sum;
    /// List of platforms.
    final List<Platform> platforms;

    PlatformList({
        required this.sum,
        required this.platforms,
    });

    factory PlatformList.fromMap(Map<String, dynamic> map) {
        return PlatformList(
            sum: map['sum'],
            platforms: List<Platform>.from(map['platforms'].map((p) => Platform.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "sum": sum,
            "platforms": platforms.map((p) => p.toMap()),
        };
    }
}
