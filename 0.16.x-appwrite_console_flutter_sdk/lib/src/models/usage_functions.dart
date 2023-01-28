part of appwrite.models;

/// UsageFunctions
class UsageFunctions implements Model {
    /// The time range of the usage stats.
    final String range;
    /// Aggregated stats for number of function executions.
    final List<MetricList> executionsTotal;
    /// Aggregated stats for function execution failures.
    final List<MetricList> executionsFailure;
    /// Aggregated stats for function execution successes.
    final List<MetricList> executionsSuccess;
    /// Aggregated stats for function execution duration.
    final List<MetricList> executionsTime;
    /// Aggregated stats for number of function builds.
    final List<MetricList> buildsTotal;
    /// Aggregated stats for function build failures.
    final List<MetricList> buildsFailure;
    /// Aggregated stats for function build successes.
    final List<MetricList> buildsSuccess;
    /// Aggregated stats for function build duration.
    final List<MetricList> buildsTime;

    UsageFunctions({
        required this.range,
        required this.executionsTotal,
        required this.executionsFailure,
        required this.executionsSuccess,
        required this.executionsTime,
        required this.buildsTotal,
        required this.buildsFailure,
        required this.buildsSuccess,
        required this.buildsTime,
    });

    factory UsageFunctions.fromMap(Map<String, dynamic> map) {
        return UsageFunctions(
            range: map['range'].toString(),
            executionsTotal: List<MetricList>.from(map['executionsTotal'].map((p) => MetricList.fromMap(p))),
            executionsFailure: List<MetricList>.from(map['executionsFailure'].map((p) => MetricList.fromMap(p))),
            executionsSuccess: List<MetricList>.from(map['executionsSuccess'].map((p) => MetricList.fromMap(p))),
            executionsTime: List<MetricList>.from(map['executionsTime'].map((p) => MetricList.fromMap(p))),
            buildsTotal: List<MetricList>.from(map['buildsTotal'].map((p) => MetricList.fromMap(p))),
            buildsFailure: List<MetricList>.from(map['buildsFailure'].map((p) => MetricList.fromMap(p))),
            buildsSuccess: List<MetricList>.from(map['buildsSuccess'].map((p) => MetricList.fromMap(p))),
            buildsTime: List<MetricList>.from(map['buildsTime'].map((p) => MetricList.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "range": range,
            "executionsTotal": executionsTotal.map((p) => p.toMap()),
            "executionsFailure": executionsFailure.map((p) => p.toMap()),
            "executionsSuccess": executionsSuccess.map((p) => p.toMap()),
            "executionsTime": executionsTime.map((p) => p.toMap()),
            "buildsTotal": buildsTotal.map((p) => p.toMap()),
            "buildsFailure": buildsFailure.map((p) => p.toMap()),
            "buildsSuccess": buildsSuccess.map((p) => p.toMap()),
            "buildsTime": buildsTime.map((p) => p.toMap()),
        };
    }
}
