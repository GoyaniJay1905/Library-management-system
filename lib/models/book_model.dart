import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String? id;
  final String title;
  final String author;
  final String? isbn;
  final String? genre;
  final String? publicationDate;
  final String? description;
  final String userId;
  final DateTime createdAt;
  final bool isPublished;

  BookModel({
    this.id,
    required this.title,
    required this.author,
    this.isbn,
    this.genre,
    this.publicationDate,
    this.description,
    required this.userId,
    required this.createdAt,
    this.isPublished = false,
  });

  // Convert BookModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'genre': genre,
      'publicationDate': publicationDate,
      'description': description,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublished': isPublished,
    };
  }

  // Create BookModel from Firestore data
  factory BookModel.fromJson(String id, Map<String, dynamic> json) {
    return BookModel(
      id: id,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      isbn: json['isbn'],
      genre: json['genre'],
      publicationDate: json['publicationDate'],
      description: json['description'],
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      isPublished: json['isPublished'] ?? false,
    );
  }
}
