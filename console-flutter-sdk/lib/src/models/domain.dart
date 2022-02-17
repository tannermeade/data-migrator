part of appwrite.models;

/// Domain
class Domain implements Model {
    /// Domain ID.
    final String $id;
    /// Domain name.
    final String domain;
    /// Registerable domain name.
    final String registerable;
    /// TLD name.
    final String tld;
    /// Verification process status.
    final bool verification;
    /// Certificate ID.
    final String certificateId;

    Domain({
        required this.$id,
        required this.domain,
        required this.registerable,
        required this.tld,
        required this.verification,
        required this.certificateId,
    });

    factory Domain.fromMap(Map<String, dynamic> map) {
        return Domain(
            $id: map['\$id'].toString(),
            domain: map['domain'].toString(),
            registerable: map['registerable'].toString(),
            tld: map['tld'].toString(),
            verification: map['verification'],
            certificateId: map['certificateId'].toString(),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "\$id": $id,
            "domain": domain,
            "registerable": registerable,
            "tld": tld,
            "verification": verification,
            "certificateId": certificateId,
        };
    }
}
