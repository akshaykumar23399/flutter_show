// To parse this JSON data, do
//
//     final note = noteFromJson(jsonString);

import 'dart:convert';


List<Note> noteFromJson(String str) => List<Note>.from(json.decode(str).map((x) => Note.fromJson(x)));

String noteToJson(List<Note> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Note {
  String title;
  int id;
  bool isDone;

  Note({
    this.title,
    this.id,
    this.isDone,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    title: json["title"],
    id: json["id"],
    isDone: json["isDone"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "id": id,
    "isDone": isDone,
  };


}