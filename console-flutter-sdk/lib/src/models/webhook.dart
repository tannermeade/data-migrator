part of appwrite.models;

/// Webhook
class Webhook implements Model {
    /// Webhook ID.
    final String $id;
    /// Webhook name.
    final String name;
    /// Webhook URL endpoint.
    final String url;
    /// Webhook trigger events.
    final List events;
    /// Indicated if SSL / TLS Certificate verification is enabled.
    final bool security;
    /// HTTP basic authentication username.
    final String httpUser;
    /// HTTP basic authentication password.
    final String httpPass;

    Webhook({
        required this.$id,
        required this.name,
        required this.url,
        required this.events,
        required this.security,
        required this.httpUser,
        required this.httpPass,
    });

    factory Webhook.fromMap(Map<String, dynamic> map) {
        return Webhook(
            $id: map['\$id'].toString(),
            name: map['name'].toString(),
            url: map['url'].toString(),
            events: map['events'],
            security: map['security'],
            httpUser: map['httpUser'].toString(),
            httpPass: map['httpPass'].toString(),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "\$id": $id,
            "name": name,
            "url": url,
            "events": events,
            "security": security,
            "httpUser": httpUser,
            "httpPass": httpPass,
        };
    }
}
