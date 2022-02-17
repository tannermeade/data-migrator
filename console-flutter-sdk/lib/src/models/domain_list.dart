part of appwrite.models;

/// Domains List
class DomainList implements Model {
    /// Total number of items available on the server.
    final int sum;
    /// List of domains.
    final List<Domain> domains;

    DomainList({
        required this.sum,
        required this.domains,
    });

    factory DomainList.fromMap(Map<String, dynamic> map) {
        return DomainList(
            sum: map['sum'],
            domains: List<Domain>.from(map['domains'].map((p) => Domain.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "sum": sum,
            "domains": domains.map((p) => p.toMap()),
        };
    }
}
