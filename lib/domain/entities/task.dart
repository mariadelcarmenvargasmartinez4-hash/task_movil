class HomeTask {
  final String id;
  final String title;
  final String assignee;
  final String time;
  final int points;
  final bool isCompleted;

  const HomeTask({
    required this.id,
    required this.title,
    required this.assignee,
    required this.time,
    required this.points,
    this.isCompleted = false,
  });

  HomeTask copyWith({
    String? id,
    String? title,
    String? assignee,
    String? time,
    int? points,
    bool? isCompleted,
  }) {
    return HomeTask(
      id: id ?? this.id,
      title: title ?? this.title,
      assignee: assignee ?? this.assignee,
      time: time ?? this.time,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
