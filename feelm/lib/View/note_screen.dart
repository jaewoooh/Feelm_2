import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelm/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class NoteScreen extends StatefulWidget {
  final String selectedDate;
  final String posterImageUrl; // 포스터 이미지 URL

  const NoteScreen({
    super.key,
    required this.selectedDate,
    required this.posterImageUrl,
  });

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _noteController = TextEditingController();
  File? _selectedImage1;
  File? _selectedImage2;
  double ratingPoint = 3.0;

  final String? loginId = prefs.getString('username'); //로그인된 아이디 가져오기

  @override
  void initState() {
    super.initState();

    _loadDiaryData(); // Firebase 데이터 로드 함수 호출
  }

  // Firebase에서 데이터 로드
  Future<void> _loadDiaryData() async {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(loginId); // 사용자의 문서 ID

      final favoriteCollection = userDoc.collection('favorite');

      // poster와 일치하는 영화 문서를 가져옴
      final querySnapshot = await favoriteCollection
          .where('poster', isEqualTo: widget.posterImageUrl)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;

        // Firestore에서 데이터 가져오기
        final data = doc.data();
        final loadedRating = data['rating'] as double?;
        final loadedDiaryText = data['diaryText'] as String?;
        final loadedTicketPath = data['ticket'] as String?;

        // 상태 업데이트
        setState(() {
          ratingPoint = loadedRating!;
          _noteController.text = loadedDiaryText ?? '';
          if (loadedTicketPath != null && loadedTicketPath.isNotEmpty) {
            _selectedImage2 = File(loadedTicketPath);
          }
        });
      }
    } catch (e) {
      log('Error loading diary data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('다이어리 기록이 없습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE6D9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(widget.selectedDate)),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 166, 37, 37),
                  ),
                ),
                const Text(
                  'Tickets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 첫 번째 이미지 업로드 박스
              _buildImageUploadBox(
                width: 140,
                height: 180,
                selectedImage: _selectedImage1,
                onTap: () {
                  //log("click");
                }, // null인 경우 빈 함수로 기본 처리 ,
                initialImageUrl: widget.posterImageUrl, // 전달받은 포스터 URL 사용
              ),
              // 두 번째 이미지 업로드 박스
              _buildImageUploadBox(
                width: 160,
                height: 120,
                selectedImage: _selectedImage2,
                onTap: _pickImageFromGallery,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Rating',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                RatingBar.builder(
                  initialRating: ratingPoint,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 24,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    ratingPoint = rating;

                    log('Rating updated to: $ratingPoint');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 노트 작성 영역
          Container(
            height: 300,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _noteController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: "노트를 작성하세요...",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 12, height: 2.0),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () => _handleSave(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Text(
                  '저장',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 두 번째 이미지 업로드 박스에서 이미지 가져오기
  void _pickImageFromGallery() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _selectedImage2 = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 가져오는 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  // 이미지 업로드 박스 생성
  Widget _buildImageUploadBox({
    required double width,
    required double height,
    required File? selectedImage,
    required VoidCallback onTap,
    String? initialImageUrl, // 초기 이미지 URL 추가
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: selectedImage != null
            ? Image.file(selectedImage, fit: BoxFit.cover)
            : (initialImageUrl != null
                ? Image.network(initialImageUrl, fit: BoxFit.cover)
                : const Icon(Icons.camera_alt)),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    final enteredText = _noteController.text;

    // 저장 확인 다이얼로그를 띄우기
    final shouldSave = await _showSaveDialog(context);
    if (!mounted) return; // 다이얼로그 이후 mounted 확인

    if (shouldSave) {
      if (enteredText.isNotEmpty) {
        try {
          // Firebase 업데이트 로직 추가
          final userDoc = FirebaseFirestore.instance
              .collection('users')
              .doc(loginId); // 사용자의 문서 ID

          final favoriteCollection = userDoc.collection('favorite');

          // poster와 일치하는 영화 문서를 가져옴
          final querySnapshot = await favoriteCollection
              .where('poster', isEqualTo: widget.posterImageUrl)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            final docRef = querySnapshot.docs.first.reference;

            await docRef.update({
              'rating': ratingPoint,
              'ticket': _selectedImage2 != null ? _selectedImage2!.path : '',
              'diaryText': enteredText,
              'savedDate': DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(widget.selectedDate)),
            });
            // SnackBar는 안전하게 호출
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('저장되었습니다: $enteredText, $ratingPoint')),
                );
              });
            }

            // Navigator.pop도 안전하게 호출
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context, {
                  'savedDate': DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(widget.selectedDate)),
                  'posterImageUrl': widget.posterImageUrl,
                });
              });
            }
          } else {
            // 일치하는 영화가 없는 경우
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showEmptyContentDialog(context, "저장할 영화를 찾을 수 없습니다.");
              });
            }
          }
        } catch (e) {
          // 오류 처리
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showEmptyContentDialog(context, "저장 중 오류가 발생했습니다: $e");
            });
          }
        }
      } else {
        // 빈 입력 입력 다이얼로그 호출
        String message = enteredText.isEmpty ? "내용을 입력해주세요." : "";
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showEmptyContentDialog(context, message);
          });
        }
      }
    }
  }

  // 저장 확인 다이얼로그
  Future<bool> _showSaveDialog(BuildContext localContext) async {
    if (!mounted) return false;
    return await showDialog<bool>(
          context: localContext,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                '저장하시겠습니까?',
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('저장'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // 빈 입력 필드 다이얼로그
  void _showEmptyContentDialog(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    });
  }
}
