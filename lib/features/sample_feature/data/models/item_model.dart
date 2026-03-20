import 'package:equatable/equatable.dart';

class ItemModel extends Equatable {
  final int? id;
  final int userId;
  final String title;
  final String body;

  const ItemModel({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] is int ? json['id'] as int : null,
      userId: (json['userId'] as int?) ?? 0,
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  ItemModel copyWith({int? id, int? userId, String? title, String? body}) {
    return ItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, body];
}
