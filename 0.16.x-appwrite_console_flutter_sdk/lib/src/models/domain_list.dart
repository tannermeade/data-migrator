part of appwrite.models;

/// Domains List
class DomainList implements Model {
    /// Total number of domains documents that matched your query.
    final int total;
    /// List of domains.
    final List<Domain> domains;

    DomainList({
        required this.total,
        required this.domains,
    });

    factory DomainList.fromMap(Map<String, dynamic> map) {
        return DomainList(
            total: map['total'],
            domains: List<Domain>.from(map['domains'].map((p) => Domain.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "total": total,
            "domains": domains.map((p) => p.toMap()),
        };
    }
}
