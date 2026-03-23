import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book_model.dart';

class EditBookPage extends StatefulWidget {
  final BookModel book;

  const EditBookPage({required this.book, super.key});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController isbnController;
  late TextEditingController genreController;
  late TextEditingController publicationDateController;
  late TextEditingController descriptionController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.book.title);
    authorController = TextEditingController(text: widget.book.author);
    isbnController = TextEditingController(text: widget.book.isbn ?? '');
    genreController = TextEditingController(text: widget.book.genre ?? '');
    publicationDateController =
        TextEditingController(text: widget.book.publicationDate ?? '');
    descriptionController =
        TextEditingController(text: widget.book.description ?? '');
  }

  Future<void> editBook() async {
    if (titleController.text.trim().isEmpty ||
        authorController.text.trim().isEmpty) {
      showMessage("Please fill in title and author");
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.book.id)
          .update({
        'title': titleController.text.trim(),
        'author': authorController.text.trim(),
        'isbn': isbnController.text.trim().isEmpty
            ? null
            : isbnController.text.trim(),
        'genre': genreController.text.trim().isEmpty
            ? null
            : genreController.text.trim(),
        'publicationDate': publicationDateController.text.trim().isEmpty
            ? null
            : publicationDateController.text.trim(),
        'description': descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      });

      if (mounted) {
        showMessage("Book Updated Successfully!");
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

  Future<void> deleteBook() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Book?"),
        content: const Text("Are you sure you want to delete this book?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      setState(() => isLoading = true);
      try {
        await FirebaseFirestore.instance
            .collection('books')
            .doc(widget.book.id)
            .delete();

        if (mounted) {
          showMessage("Book Deleted Successfully!");
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } catch (e) {
        showMessage("Error: $e");
        if (mounted) setState(() => isLoading = false);
      }
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
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
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
                        Icons.edit_document,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Edit Book",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Update book information",
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

                    // Update Book Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : editBook,
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
                                "Update Book",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Delete Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : deleteBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Delete Book",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
      enabled: !isLoading,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
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
      enabled: !isLoading,
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