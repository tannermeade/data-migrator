part of appwrite.models;

/// Webhooks List
class WebhookList implements Model {
    /// Total number of items available on the server.
    final int sum;
    /// List of webhooks.
    final List<Webhook> webhooks;

    WebhookList({
        required this.sum,
        required this.webhooks,
    });

    factory WebhookList.fromMap(Map<String, dynamic> map) {
        return WebhookList(
            sum: map['sum'],
            webhooks: List<Webhook>.from(map['webhooks'].map((p) => Webhook.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "sum": sum,
            "webhooks": webhooks.map((p) => p.toMap()),
        };
    }
}
