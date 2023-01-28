part of appwrite.models;

/// Metric
class Metric implements Model {
    /// The value of this metric at the timestamp.
    final int value;
    /// The UNIX timestamp at which this metric was aggregated.
    final int date;

    Metric({
        required this.value,
        required this.date,
    });

    factory Metric.fromMap(Map<String, dynamic> map) {
        return Metric(
            value: map['value'],
            date: map['date'],
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "value": value,
            "date": date,
        };
    }
}
