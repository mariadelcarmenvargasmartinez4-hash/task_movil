import '../../domain/domain.dart';

class HomeTaskModel extends HomeTask {
  const HomeTaskModel({
    required super.id,
    required super.title,
    required super.assignee,
    required super.time,
    required super.points,
    super.isCompleted,
    super.date,
    super.priority,
  });

  factory HomeTaskModel.fromJson(Map<String, dynamic> json) {
    return HomeTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      assignee: json['assignee'] as String,
      time: json['time'] as String,
      points: json['points'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      date: json['date'] as String? ?? '2026-05-27',
      priority: json['priority'] as String? ?? 'media',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'assignee': assignee,
      'time': time,
      'points': points,
      'isCompleted': isCompleted,
      'date': date,
      'priority': priority,
    };
  }

  static HomeTaskModel fromEntity(HomeTask entity) {
    return HomeTaskModel(
      id: entity.id,
      title: entity.title,
      assignee: entity.assignee,
      time: entity.time,
      points: entity.points,
      isCompleted: entity.isCompleted,
      date: entity.date,
      priority: entity.priority,
    );
  }
}
