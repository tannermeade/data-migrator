part of appwrite.models;

/// Metric List
class MetricList implements Model {
  /// Total number of items available on the server.
  final int sum;

  /// List of metrics.
  final List<Metric> metrics;

  MetricList({
    required this.sum,
    required this.metrics,
  });

  factory MetricList.fromMap(Map<String, dynamic> map) {
    return MetricList(
      sum: map['sum'],
      metrics: [], //List<Metric>.from(map['metrics'].map((p) => Metric.fromMap(p))),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "sum": sum,
      "metrics": [], //metrics.map((p) => p.toMap()),
    };
  }
}
