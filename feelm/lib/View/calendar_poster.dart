import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PosterListView extends StatelessWidget {
  final String currentUser;

  const PosterListView({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser)
            .collection('favorite')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching data'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No favorite movies added yet.',
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.bold),
              ),
            );
          }

          final favoriteMovies = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: favoriteMovies.length,
            itemBuilder: (context, index) {
              final movie = favoriteMovies[index];
              final title = movie['title'] ?? 'Unknown';
              final poster = movie['poster'] ?? '';

              return Container(
                margin: EdgeInsets.only(left: index == 0 ? 40 : 20, right: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //포스터 이미지
                    Container(
                      width: 120,
                      height: 180,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: poster.isNotEmpty
                            ? Image.network(
                                poster,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.movie,
                                color: Colors.black54,
                                size: 50,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
