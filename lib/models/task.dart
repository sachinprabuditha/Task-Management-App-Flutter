class Task {
  final int? id;
  final String title;
  final String description;
  final bool? isCompleted;
  final DateTime? createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.createdAt,
  });

  // Convert Task to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted == true ? 1 : 0,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Create Task from Map (useful for database retrieval)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: map['createdAt'] != null 
        ? DateTime.parse(map['createdAt']) 
        : null,
    );
  }
}