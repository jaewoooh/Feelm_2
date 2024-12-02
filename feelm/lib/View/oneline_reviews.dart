import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelm/main.dart';
import 'package:flutter/material.dart';

class OnelineReviews extends StatefulWidget {
  final String movieName; // 영화 이름을 기반으로 리뷰 관리

  const OnelineReviews({super.key, required this.movieName});

  @override
  State<OnelineReviews> createState() => _OnelineReviewsState();
}

class _OnelineReviewsState extends State<OnelineReviews> {
  final TextEditingController _reviewController = TextEditingController();

  final String? loginId = prefs.getString('username'); //로그인된 아이디 가져오기

  Future<void> _addReview() async {
    final String reviewText = _reviewController.text.trim();
    if (reviewText.isEmpty || loginId == null) {
      log("리뷰 텍스트가 비어있거나 로그인되지 않았습니다.");
      return;
    }

    try {
      // Firestore에 접근하여 onelineReview 컬렉션 생성
      final CollectionReference reviewCollection = FirebaseFirestore.instance
          .collection('onelineReview')
          .doc(widget.movieName)
          .collection('reviews');

      // 이미 작성된 리뷰가 있는지 확인
      final DocumentSnapshot existingReview =
          await reviewCollection.doc(loginId).get();

      if (existingReview.exists) {
        // Dialog 표시: 이미 작성된 리뷰가 있을 경우
        if (!mounted) return; // BuildContext가 여전히 유효한지 확인
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                "이미 작성한 한줄평이 있습니다.\n다시 작성하겠습니까?",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),

              actionsAlignment: MainAxisAlignment.spaceEvenly, // 버튼 동일
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                  child: const Text("취소"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    // 기존 리뷰를 덮어쓰기
                    await reviewCollection.doc(loginId).set({
                      'userId': loginId,
                      'onelineText': reviewText,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    log("리뷰가 성공적으로 업데이트되었습니다.");
                    setState(() {
                      _reviewController.clear(); // 입력 필드 초기화
                    });
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
        return; // 이미 리뷰가 있는 경우 추가 작업 중단
      }
      // 새로운 리뷰 추가
      await reviewCollection.doc(loginId).set({
        'userId': loginId,
        'onelineText': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      log("리뷰가 성공적으로 저장되었습니다.");
      setState(() {
        _reviewController.clear(); // 입력 필드 초기화
      });
    } catch (e) {
      log("리뷰 저장 중 오류 발생: $e");
    }
  }

  Future<void> _deleteReview(String userId, String reviewText) async {
    if (userId != loginId) {
      log("삭제 권한이 없습니다.");
      return;
    }

    try {
      final CollectionReference reviewCollection = FirebaseFirestore.instance
          .collection('onelineReview')
          .doc(widget.movieName)
          .collection('reviews');

      final QuerySnapshot query = await reviewCollection
          .where('userId', isEqualTo: loginId)
          .where('onelineText', isEqualTo: reviewText)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }

      log("리뷰가 성공적으로 삭제되었습니다.");
    } catch (e) {
      log("리뷰 삭제 중 오류 발생: $e");
    }
  }

  void _confirmDelete(String userId, String reviewText) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text("삭제하시겠습니까?"),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly, // 버튼 동일
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteReview(userId, reviewText);
              },
              child: const Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            '한줄평',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 로그인된 아이디를 표시하는 텍스트
            Padding(
              padding: const EdgeInsets.only(bottom: 10), // 왼쪽에 10 정도의 패딩
              child: Text(
                prefs.getString('username') ?? '유저',
                style: const TextStyle(
                  color: Colors.white, // 텍스트 색상을 하얀색으로 설정
                  fontSize: 16, // 텍스트 크기를 16으로 설정
                ),
              ),
            ),
            //const SizedBox(height: 5), // 아이디와 입력 박스 사이 간격
            Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _reviewController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1, // 한 줄만 입력 가능
                          decoration: InputDecoration(
                            isDense: true, // 내부 패딩을 줄여 높이를 축소
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10), // 높이를 줄이기 위한 패딩
                            hintText: '한줄평을 남겨보세요!',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.grey[700],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: _addReview, //_addReview, // 리뷰 추가 함수 연결
                    icon: const Icon(Icons.send, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        // 스크롤 가능한 리뷰 리스트 컨테이너
        SizedBox(
          height: 300, // 고정된 높이 설정
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('onelineReview')
                .doc(widget.movieName)
                .collection('reviews')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    '아직 작성된 리뷰가 없습니다.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              final reviews = snapshot.data!.docs;

              return ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final reviewData =
                      reviews[index].data() as Map<String, dynamic>;
                  final userId = reviewData['userId'] ?? '알 수 없는 사용자';
                  final reviewText = reviewData['onelineText'] ?? '내용 없음';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            userId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          if (userId == loginId)
                            IconButton(
                              onPressed: () =>
                                  _confirmDelete(userId, reviewText),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 25,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        reviewText,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      const Divider(color: Colors.green),
                    ],
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}
