import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelm/View/mainScreen.dart';
import 'register.dart'; // SignUpScreen import

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static final TextEditingController _userName = TextEditingController();
  static final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBAD3EE), // 배경색 변경
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 구름 이미지 로고
              Image.asset(
                'assets/cloud.png', // 구름 이미지 경로 설정
                width: 296,
                height: 175,
              ),
              const SizedBox(height: 40),

              // 사용자 이름 입력 필드
              TextField(
                controller: _userName,
                decoration: InputDecoration(
                  hintText: 'username',
                  hintStyle: const TextStyle(color: Color(0xFF666666)),
                  filled: true,
                  fillColor: const Color(0xFFEFEFEF),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF333631)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 비밀번호 입력 필드
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Color(0xFF666666)),
                  filled: true,
                  fillColor: const Color(0xFFEFEFEF),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF333631)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF323232),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 로그인 버튼
              ElevatedButton(
                onPressed: () async {
                  final username = _userName.text.trim();
                  final password = _password.text.trim();

                  if (username.isEmpty || password.isEmpty) {
                    _showErrorDialog(context, '모든 필드를 채워주세요.');
                    return;
                  }

                  try {
                    print('Firestore에서 사용자 정보 가져오는 중...');
                    final doc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(username)
                        .get();

                    if (doc.exists) {
                      print('사용자 정보 존재 확인: ${doc.data()}');
                      if (doc['password'] == password) {
                        print('로그인 성공');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                        );
                      } else {
                        print('비밀번호 불일치');
                        _showErrorDialog(
                            context, '아이디 또는 비밀번호가 올바르지 않습니다.');
                      }
                    } else {
                      print('사용자 정보 없음');
                      _showErrorDialog(
                          context, '아이디 또는 비밀번호가 올바르지 않습니다.');
                    }
                  } catch (e) {
                    print('로그인 실패: $e');
                    _showErrorDialog(context, '로그인 실패: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000000),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'LogIn',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 비밀번호 찾기
              const Text(
                'forgot password?',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // 회원가입 링크
              RichText(
                text: TextSpan(
                  text: "Don't have an account, ",
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                    ),
                    const TextSpan(text: ' now.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
