part of appwrite.models;

/// Projects List
class ProjectList implements Model {
    /// Total number of items available on the server.
    final int sum;
    /// List of projects.
    final List<Project> projects;

    ProjectList({
        required this.sum,
        required this.projects,
    });

    factory ProjectList.fromMap(Map<String, dynamic> map) {
        return ProjectList(
            sum: map['sum'],
            projects: List<Project>.from(map['projects'].map((p) => Project.fromMap(p))),
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "sum": sum,
            "projects": projects.map((p) => p.toMap()),
        };
    }
}
