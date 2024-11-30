import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';

class DiaryCalendar extends StatelessWidget {
  final String selectedDate;

  // 선택된 날짜를 생성자로 전달받음
  const DiaryCalendar({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCD1B5),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: const Text(
                    "확인을 누르시면 저장하지 않은 입력들은 초기화됩니다.\n뒤로 가시겠습니까?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // 다이얼로그 닫기
                            Navigator.of(context).pop(); // 이전 화면으로 이동
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 180, 168, 113),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            '네',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text("$selectedDate Diary"),
        backgroundColor: const Color(0xFFDCD1B5),
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.black,
              height: 1.0,
            )),
      ),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/diaryCloud.png',
                    width: 300,
                    height: 150,
                  ),
                  NoteScreen(selectedDate: selectedDate),
                ],
              ),
            ),
          )),
    );
  }
}

//노트쪽 감싸고 있는 Container부터import 'dart:io';

class NoteScreen extends StatefulWidget {
  final String selectedDate;

  const NoteScreen({super.key, required this.selectedDate});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _noteController = TextEditingController();
  File? _selectedImage1;
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
                selectedImage: _selectedImage1,
                onTap: _pickImageFromGallery1,
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

  // 첫 번째 이미지 업로드 박스에서 이미지 가져오기
  void _pickImageFromGallery1() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _selectedImage1 = File(image.path);
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

  // 이미지 업로드 박스 생성
  Widget _buildImageUploadBox({
    required double width,
    required double height,
    required File? selectedImage,
    required VoidCallback onTap,
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
            : const Center(
                child: Icon(Icons.camera_alt, color: Colors.grey),
              ),
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
        // SnackBar는 안전하게 호출
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('저장되었습니다: $enteredText')),
            );
          });
        }

        // Navigator.pop도 안전하게 호출
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
        }
      } else {
        // 빈 입력 다이얼로그 호출
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showEmptyContentDialog(context);
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
              title: const Text('저장하시겠습니까?'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('저장'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // 빈 입력 필드 다이얼로그
  void _showEmptyContentDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });
  }
}
