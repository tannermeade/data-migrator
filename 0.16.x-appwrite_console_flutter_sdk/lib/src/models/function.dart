part of appwrite.models;

/// Function
class Funct implements Model {
    /// Function ID.
    final String $id;
    /// Function creation date in Datetime
    final String $createdAt;
    /// Function update date in Datetime
    final String $updatedAt;
    /// Execution permissions.
    final List execute;
    /// Function name.
    final String name;
    /// Function status. Possible values: `disabled`, `enabled`
    final String status;
    /// Function execution runtime.
    final String runtime;
    /// Function&#039;s active deployment ID.
    final String deployment;
    /// Function variables.
    final List<Variable> vars;
    /// Function trigger events.
    final List events;
    /// Function execution schedult in CRON format.
    final String schedule;
    /// Function&#039;s next scheduled execution time in Datetime.
    final String scheduleNext;
    /// Function&#039;s previous scheduled execution time in Datetime.
    final String schedulePrevious;
    /// Function execution timeout in seconds.
    final int timeout;

    Funct({
        required this.$id,
        required this.$createdAt,
        required this.$updatedAt,
        required this.execute,
        required this.name,
        required this.status,
        required this.runtime,
        required this.deployment,
        required this.vars,
        required this.events,
        required this.schedule,
        required this.scheduleNext,
        required this.schedulePrevious,
        required this.timeout,
    });

    factory Funct.fromMap(Map<String, dynamic> map) {
        return Funct(
            $id: map['\$id'].toString(),
            $createdAt: map['\$createdAt'].toString(),
            $updatedAt: map['\$updatedAt'].toString(),
            execute: map['execute'],
            name: map['name'].toString(),
            status: map['status'].toString(),
            runtime: map['runtime'].toString(),
            deployment: map['deployment'].toString(),
            vars: List<Variable>.from(map['vars'].map((p) => Variable.fromMap(p))),
            events: map['events'],
            schedule: map['schedule'].toString(),
            scheduleNext: map['scheduleNext'].toString(),
            schedulePrevious: map['schedulePrevious'].toString(),
            timeout: map['timeout'],
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "\$id": $id,
            "\$createdAt": $createdAt,
            "\$updatedAt": $updatedAt,
            "execute": execute,
            "name": name,
            "status": status,
            "runtime": runtime,
            "deployment": deployment,
            "vars": vars.map((p) => p.toMap()),
            "events": events,
            "schedule": schedule,
            "scheduleNext": scheduleNext,
            "schedulePrevious": schedulePrevious,
            "timeout": timeout,
        };
    }
}