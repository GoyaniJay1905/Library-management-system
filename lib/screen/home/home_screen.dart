import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../service/firebase_service.dart';
import '../../models/book_model.dart';
import '../auth/login.dart';
import '../book/add_book.dart';
import '../book/edit_book.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String searchQuery = '';
  String filterStatus = 'all';

  final Color kPrimary = const Color(0xFF6366F1);
  final Color kBackground = const Color(0xFF090B0D);
  final Color kCardSurface = const Color(0xFF161A1F);
  final Color kSuccess = const Color(0xFF10B981);
  final Color kWarning = const Color(0xFFF59E0B);

  void showDeleteDialog(BuildContext context, BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardSurface,
        title: const Text("Delete Book?", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this book?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('books').doc(book.id).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Book deleted successfully!")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
  Future<void> togglePublish(BookModel book) async {
    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(book.id)
          .update({'isPublished': !book.isPublished});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(book.isPublished ? "Unpublished!" : "Published!"),
            backgroundColor: kPrimary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          user == null
              ? const Center(child: Text("User not logged in", style: TextStyle(color: Colors.white)))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('books')
                      .where('userId', isEqualTo: user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                    }

                    final books = snapshot.data?.docs.map((doc) {
                          return BookModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
                        }).toList() ??
                        [];

                    final filteredBooks = books.where((book) {
                      final matchesSearch = book.title.toLowerCase().contains(searchQuery) ||
                          book.author.toLowerCase().contains(searchQuery);

                      final matchesFilter = filterStatus == 'all' ||
                          (filterStatus == 'published' && book.isPublished) ||
                          (filterStatus == 'draft' && !book.isPublished);

                      return matchesSearch && matchesFilter;
                    }).toList();

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildHeader(books.length, service),
                        _buildSearchAndFilters(books),

                        if (filteredBooks.isEmpty)
                          _buildEmptyState()
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildBookCard(filteredBooks[index]),
                                childCount: filteredBooks.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHeader(int count, FirebaseService service) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kPrimary.withOpacity(0.9),
              kPrimary.withOpacity(0.5),
              kBackground,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("My Library",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text("$count books",
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            await service.logout();
            if (mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
            }
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(List<BookModel> books) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: TextField(
                  onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search books...",
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: kPrimary),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip("All", "all", books.length),
                  const SizedBox(width: 8),
                  _filterChip("Published", "published", books.where((b) => b.isPublished).length),
                  const SizedBox(width: 8),
                  _filterChip("Drafts", "draft", books.where((b) => !b.isPublished).length),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value, int count) {
    bool isSelected = filterStatus == value;

    return GestureDetector(
      onTap: () => setState(() => filterStatus = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [kPrimary, kPrimary.withOpacity(0.6)])
              : null,
          color: isSelected ? null : kCardSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text("$label ($count)",
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCardSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 6,
          decoration: BoxDecoration(
            color: book.isPublished ? kSuccess : kWarning,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        title: Text(book.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(book.author,
            style: TextStyle(color: Colors.white.withOpacity(0.5))),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          color: kCardSurface,
          onSelected: (val) {
            if (val == 'edit') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditBookPage(book: book)));
            } else if (val == 'publish') {
              togglePublish(book);
            } else if (val == 'delete') {
              showDeleteDialog(context, book);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text("Edit", style: TextStyle(color: Colors.white))),
            PopupMenuItem(value: 'publish', child: Text(book.isPublished ? "Unpublish" : "Publish", style: const TextStyle(color: Colors.white))),
            const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.redAccent))),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBookPage())),
      backgroundColor: kPrimary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text("Add Book", style: TextStyle(color: Colors.white)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildEmptyState() {
    return const SliverFillRemaining(
      child: Center(
        child: Text("No books found matching your criteria.",
            style: TextStyle(color: Colors.white24)),
      ),
    );
  }
}