class Notice {
  const Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.author,
    required this.priority,
    required this.postedAt,
  });

  static const departments = ['CSE', 'ECE', 'EEE', 'Mech', 'Civil', 'General'];

  static const priorities = ['Low', 'Normal', 'High'];

  final String id;
  final String title;
  final String description;
  final String department;
  final String author;
  final String priority;
  final DateTime postedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'department': department,
    'author': author,
    'priority': priority,
    'postedAt': postedAt.toIso8601String(),
  };

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      department: json['department'] as String,
      author: json['author'] as String,
      priority: json['priority'] as String,
      postedAt: DateTime.parse(json['postedAt'] as String),
    );
  }
}
