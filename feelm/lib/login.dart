import 'package:feelm/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelm/View/mainScreen.dart';
import 'register.dart'; // SignUpScreen import
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _userName.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // Widget이 dispose된 경우 guard
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

  Future<void> _handleLogin() async {
    final username = _userName.text.trim();
    final password = _password.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('모든 필드를 채워주세요.');
      return;
    }

    try {
      // Firebase Firestore에서 사용자 정보 조회
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .get();

      if (doc.exists) {
        if (doc['password'] == password) {
          // 로그인 성공
          await prefs.setString('username', username); //prefs에 username 저장
          if (!mounted) return; // Widget이 dispose된 경우 guard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        } else {
          // 비밀번호 불일치
          _showErrorDialog('아이디 또는 비밀번호가 올바르지 않습니다.');
        }
      } else {
        // 사용자 정보 없음
        _showErrorDialog('아이디 또는 비밀번호가 올바르지 않습니다.');
      }
    } catch (e) {
      // 예외 처리
      _showErrorDialog('로그인 실패: $e');
    }
  }

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
                    // Firestore에서 사용자 정보 가져오기
                    final doc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(username)
                        .get();

                    if (doc.exists) {
                      if (doc['password'] == password) {
                        // 로그인 성공 -> SharedPreferences에 사용자 정보 저장
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('username', doc['username']);
                        await prefs.setString('email', doc['email']);

                        // MainScreen으로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                        );
                      } else {
                        _showErrorDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다.');
                      }
                    } else {
                      _showErrorDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다.');
                    }
                  } catch (e) {
                    _showErrorDialog(context, '로그인 실패: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000000),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),

                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000000),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),

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
}
