import 'package:flutterlearning/friend.dart';
class Favor{
  final String uuid;
  final String description;
  final DateTime dueDate;
  final bool accepted;
  final DateTime completed;
  final Friend friend;
  Favor({
   this.uuid,
   this.description,
   this.dueDate,
   this.accepted,
   this.completed,
   this.friend,
});

  get isDoing => accepted == true && completed == null;

  get isRequested => accepted == null;

  get isCompleted => completed != null;

  get isRefused => accepted == false;

  Favor copyWith({
    String uuid,
    String description,
    DateTime dueDate,
    bool accepted,
    DateTime completed,
    Friend friend,
  }) {
    return Favor(
      uuid: uuid ?? this.uuid,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      accepted: accepted ?? this.accepted,
      completed: completed ?? this.completed,
      friend: friend ?? this.friend,
    );
  }
}