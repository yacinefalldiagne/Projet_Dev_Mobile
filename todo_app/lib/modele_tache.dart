class Task {
  final int? id;
  final String title;
  final String description;
  final bool completed;
  final String status;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0,
      'status': status,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      completed: map['completed'] == 1,
      status: map['status'] ?? '',
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    String? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      status: status ?? this.status,
    );
  }
}
