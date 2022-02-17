part of appwrite.models;

/// UsageFunctions
class UsageFunctions implements Model {
    /// The time range of the usage stats.
    final String range;
    /// Aggregated stats for function executions.
    final List<MetricList> functionsExecutions;
    /// Aggregated stats for function execution failures.
    final List<MetricList> functionsFailures;
    /// Aggregated stats for function execution duration.
    final List<MetricList> functionsCompute;

    UsageFunctions({
        required this.range,
        required this.functionsExecutions,
        required this.functionsFailures,
        required this.functionsCompute,
    });

    factory UsageFunctions.fromMap(Map<String, dynamic> map) {
        return UsageFunctions(
            range: map['range'].toString(),
            functionsExecutions: List<MetricList>.from(map['functionsExecutions'].map((p) => MetricList.fromMap(p))),
            functionsFailures: List<MetricList>.from(map['functionsFailures'].map((p) => MetricList.fromMap(p))),
            functionsCompute: List<MetricList>.from(map['functionsCompute'].map((p) => MetricList.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "range": range,
            "functionsExecutions": functionsExecutions.map((p) => p.toMap()),
            "functionsFailures": functionsFailures.map((p) => p.toMap()),
            "functionsCompute": functionsCompute.map((p) => p.toMap()),
        };
    }
}
