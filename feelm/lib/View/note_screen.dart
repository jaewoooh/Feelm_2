import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';

class NoteScreen extends StatefulWidget {
  final String selectedDate;
  final String selectedPosterImageUrl; // 선택된 포스터 이미지 URL 추가

  const NoteScreen({
    super.key,
    required this.selectedDate,
    required this.selectedPosterImageUrl,
  });

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _noteController = TextEditingController();
  //File? _selectedImage1;
  File? _selectedImage2;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
                  widget.selectedDate,
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
                imageUrl: widget.selectedPosterImageUrl,
              ),
              // 두 번째 이미지 업로드 박스
              _buildImageUploadBox(
                width: 160,
                height: 120,
                selectedImage: _selectedImage2,
                onTap: _pickImageFromGallery2,
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
                  initialRating: 3.5,
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
                    log('Rating updated to: $rating');
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

  // 이미지 업로드 박스 생성
  Widget _buildImageUploadBox({
    required double width,
    required double height,
    String? imageUrl,
    File? selectedImage,
    VoidCallback? onTap,
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
            : (imageUrl != null
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : const Center(
                    child: Icon(Icons.camera_alt, color: Colors.grey),
                  )),
      ),
    );
  }

  // 두 번째 이미지 업로드 박스에서 이미지 가져오기
  void _pickImageFromGallery2() async {
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

  Future<void> _handleSave(BuildContext context) async {
    final enteredText = _noteController.text;

    if (enteredText.isEmpty) {
      _showEmptyContentDialog(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('저장되었습니다: $enteredText')),
    );

    Navigator.pop(context);
  }
  // // 저장 확인 다이얼로그
  // Future<bool> _showSaveDialog(BuildContext localContext) async {
  //   if (!mounted) return false;
  //   return await showDialog<bool>(
  //         context: localContext,
  //         builder: (context) {
  //           return AlertDialog(
  //             title: const Text('저장하시겠습니까?'),
  //             actions: [
  //               ElevatedButton(
  //                 onPressed: () => Navigator.of(context).pop(false),
  //                 child: const Text('취소'),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () => Navigator.of(context).pop(true),
  //                 child: const Text('저장'),
  //               ),
  //             ],
  //           );
  //         },
  //       ) ??
  //       false;
  // }

  // 빈 입력 필드 다이얼로그
  void _showEmptyContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("내용을 입력해주세요."),
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
  }
}
