//CalendarPoster

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelm/View/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class PosterListView extends StatefulWidget {
  final String currentUser;
  final Function(String?) onPosterSelected; // 선택된 포스터를 전달하는 콜백

  const PosterListView({
    super.key,
    required this.currentUser,
    required this.onPosterSelected,
  });

  @override
  PosterListViewState createState() => PosterListViewState();
}

class PosterListViewState extends State<PosterListView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  // final ValueNotifier<String?> selectedPosterTitle =
  //     ValueNotifier<String?>(null); // ValueNotifier로 선택 상태 관리

  @override
  bool get wantKeepAlive => true; // 상태 유지 활성화

  @override
  void dispose() {
    _scrollController.dispose(); // ScrollController 해제
    //selectedPosterTitle.dispose(); // ValueNotifier 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 사용 시 필수
    return SizedBox(
      height: 280,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUser)
            .collection('favorite')
            .where('diaryText', isEqualTo: "") // diaryText가 null인 경우
            .where('savedDate', isEqualTo: "") // savedDate가 null인 경우
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
                '즐겨찾기에 영화를 추가해주세요.',
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.bold),
              ),
            );
          }

          final favoriteMovies = snapshot.data!.docs;

          return ValueListenableBuilder<String?>(
            valueListenable: CalendarscreenState
                .selectedPosterTitleNotifier, // 선택 상태를 ValueNotifier로 관찰
            builder: (context, selectedTitle, child) {
              return ListView.builder(
                controller: _scrollController, // ScrollController 유지
                scrollDirection: Axis.horizontal,
                itemCount: favoriteMovies.length,
                itemBuilder: (context, index) {
                  final movie = favoriteMovies[index];
                  final title = movie['title'] ?? 'Unknown';
                  final poster = movie['poster'] ?? '';

                  final isSelected = title == selectedTitle;
                  final borderColor =
                      isSelected ? Colors.yellow : Colors.transparent;
                  final borderWidth = isSelected ? 3.0 : 1.0;

                  return GestureDetector(
                    onTap: () {
                      CalendarscreenState.selectedPosterTitleNotifier.value =
                          title;
                      widget.onPosterSelected(title); // 선택된 포스터 전달
                      log("Selected movie: $title");

                      // 선택한 포스터로 스크롤 유지
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            index * 140.0, // 각 포스터의 너비에 맞게 조정
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          left: index == 0 ? 40 : 20, right: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: borderColor, width: borderWidth),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: poster.isNotEmpty
                                  ? Image.network(
                                      poster,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
