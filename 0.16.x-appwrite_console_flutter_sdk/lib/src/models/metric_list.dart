part of appwrite.models;

/// Metric List
class MetricList implements Model {
    /// Total number of metrics documents that matched your query.
    final int total;
    /// List of metrics.
    final List<Metric> metrics;

    MetricList({
        required this.total,
        required this.metrics,
    });

    factory MetricList.fromMap(Map<String, dynamic> map) {
        return MetricList(
            total: map['total'],
            metrics: List<Metric>.from(map['metrics'].map((p) => Metric.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "total": total,
            "metrics": metrics.map((p) => p.toMap()),
        };
    }
}
