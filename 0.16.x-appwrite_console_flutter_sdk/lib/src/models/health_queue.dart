part of appwrite.models;

/// Health Queue
class HealthQueue implements Model {
    /// Amount of actions in the queue.
    final int size;

    HealthQueue({
        required this.size,
    });

    factory HealthQueue.fromMap(Map<String, dynamic> map) {
        return HealthQueue(
            size: map['size'],
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "size": size,
        };
    }
}
