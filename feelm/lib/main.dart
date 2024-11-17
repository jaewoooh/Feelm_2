//import 'package:flutter/cupertino.dart';

import 'package:feelm/View/mainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:feelm/View/myPageScreen.dart'; // Mypagescreen 파일을 import
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Firebase 초기화 전에 반드시 호출
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // firebase_options.dart 파일 사용
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Mypagescreen(), // Mypagescreen을 초기 화면으로 설정
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static final TextEditingController _userName =
      TextEditingController(); // _붙인거 private
  static final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
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
                hintStyle:
                    const TextStyle(color: Color(0xFF666666)), // 텍스트 색상 666666
                filled: true,
                fillColor: const Color(0xFFEFEFEF), // 입력 필드 배경색 EFEFEF
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFF333631)), // 테두리 색상 333631
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
                hintStyle:
                    const TextStyle(color: Color(0xFF666666)), // 텍스트 색상 666666
                filled: true,
                fillColor: const Color(0xFFEFEFEF), // 입력 필드 배경색 EFEFEF
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFF333631)), // 테두리 색상 333631
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFF323232), width: 2), // 포커스 테두리 색상 323232
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 로그인 버튼
            ElevatedButton(
              onPressed: () {
                if (_userName.text == "a" && _password.text == "1") {
                  // 새로운 페이지 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                  _userName.text = '';
                  _password.text = '';
                } else {
                  //아이디와 비밀번호가 올바르지 않을때 Alert
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          title: const Text(
                            "오류",
                            textAlign: TextAlign.center,
                          ),
                          content: const Text("아이디 또는 비밀번호가 올바르지 않습니다."),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              iconAlignment: IconAlignment.end,
                              child: const Text(
                                "확인",
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        );
                      });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000000), // 버튼 배경색 000000
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
                    color: Color(0xFFFFFFFF), fontSize: 16), // 텍스트 색상 FFFFFF
              ),
            ),
            const SizedBox(height: 20),

            // 비밀번호 찾기
            const Text(
              'forgot password?',
              style: TextStyle(
                color: Color(0xFF666666), // 회색 텍스트 666666
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // 회원가입 링크
            RichText(
              text: TextSpan(
                text: "Don't have an account, ",
                style: const TextStyle(
                    color: Color(0xFF666666), fontSize: 14), // 텍스트 색상 666666
                children: [
                  TextSpan(
                    text: 'Sign Up',
                    style: const TextStyle(
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.bold), // 텍스트 색상 000000
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // 회원가입 페이지로 이동
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
    );
  }
}
// 회원가입 화면
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: const Color(0xFF000000), // 앱바 색상 000000
      ),
      body: const Center(
        child: Text('Sign Up Page'),
      ),
    );
  }
}
//--------------------------------------------------------------------------------------------
// //앱의 root widget 클래스
// //root widget 클래스는 두개의 옵션 중 하나를 return 해야한다. (material(구글) / cupertino(애플))
// class App extends StatelessWidget{
//   //build 메소드는 무조건 위젯 클래스 안에 필수적으로 구현해야한다. -- 재우
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Color.fromARGB(255, 159, 225, 44),
//           title: Text('Hello flutter!'),
//         ),
//         body: Center(child: Text('Hello world!')
//         ),
//       ),
//     );
//   }
// }
//----------------------------------------------------------------------------------------------

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 153, 255, 0)),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

