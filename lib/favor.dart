import 'package:flutterlearning/friend.dart';
class Favor{
  final String uuid;
  final String description;
  final DateTime dueDate;
  final bool accepted;
  final DateTime completed;
  final DateTime refuseDate;
  final Friend friend;
  final String to;
  Favor({
   this.uuid,
   this.description,
   this.dueDate,
   this.accepted,
   this.completed,
   this.friend,
   this.refuseDate,
   this.to,
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
    DateTime refuseDate,
    Friend friend,
  }) {
    return Favor(
      uuid: uuid ?? this.uuid,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      accepted: accepted ?? this.accepted,
      completed: completed ?? this.completed,
      refuseDate: refuseDate??this.refuseDate,
      friend: friend ?? this.friend,
    );
  }
  Favor.fromMap(String uid,Map<String,dynamic> data)
    :this(
    uuid: uid,
    description: data['description'],
    dueDate: DateTime.fromMicrosecondsSinceEpoch(data['dueDate']),
    accepted: data['accepted'],
    completed: data['completed'] != null ? DateTime.fromMicrosecondsSinceEpoch(data['completed']):null,
    refuseDate: data['refuseDate'] != null ? DateTime.fromMicrosecondsSinceEpoch(data['refuseDate']):null,
    friend: Friend.fromMap(data['friend']),
    to: data['to'],
  );
  Map<String, dynamic> toJson() => {
    'description': this.description,
    'dueDate': this.dueDate?.microsecondsSinceEpoch??null,
    'accepted': this.accepted,
    'completed': this.completed?.microsecondsSinceEpoch??null,
    'refuseDate': this.refuseDate?.microsecondsSinceEpoch??null,
    'friend': this.friend.toJson(),
    'to': this.to,
  };
}