import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/book_model.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final isbnController = TextEditingController();
  final genreController = TextEditingController();
  final publicationDateController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isLoading = false;

  Future<void> addBook() async {
    if (titleController.text.trim().isEmpty ||
        authorController.text.trim().isEmpty) {
      showMessage("Please fill in title and author");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showMessage("User not logged in");
        return;
      }

      final book = BookModel(
        title: titleController.text.trim(),
        author: authorController.text.trim(),
        isbn: isbnController.text.trim().isEmpty ? null : isbnController.text.trim(),
        genre: genreController.text.trim().isEmpty ? null : genreController.text.trim(),
        publicationDate: publicationDateController.text.trim().isEmpty
            ? null
            : publicationDateController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        userId: user.uid,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('books').add(book.toJson());

      if (mounted) {
        showMessage("Book Added Successfully!");
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      showMessage("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    isbnController.dispose();
    genreController.dispose();
    publicationDateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.only(top: 40, bottom: 30),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.library_add,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Add New Book",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Add a new book to your library",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    _buildLabel("Book Title *"),
                    _buildTextField(
                      controller: titleController,
                      hintText: "Enter book title",
                      icon: Icons.book,
                    ),
                    const SizedBox(height: 20),

                    // Author Field
                    _buildLabel("Author *"),
                    _buildTextField(
                      controller: authorController,
                      hintText: "Enter author name",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),

                    // ISBN Field
                    _buildLabel("ISBN"),
                    _buildTextField(
                      controller: isbnController,
                      hintText: "Enter ISBN (optional)",
                      icon: Icons.code,
                    ),
                    const SizedBox(height: 20),

                    // Genre Field
                    _buildLabel("Genre"),
                    _buildTextField(
                      controller: genreController,
                      hintText: "Enter genre (optional)",
                      icon: Icons.category,
                    ),
                    const SizedBox(height: 20),

                    // Publication Date Field
                    _buildLabel("Publication Date"),
                    _buildTextField(
                      controller: publicationDateController,
                      hintText: "e.g., 2024-03-18 (optional)",
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 20),

                    // Description Field
                    _buildLabel("Description"),
                    _buildTextAreaField(
                      controller: descriptionController,
                      hintText: "Enter book description (optional)",
                    ),
                    const SizedBox(height: 30),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : addBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Add Book",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF667eea),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Color(0xFF667eea)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
    );
  }
}
