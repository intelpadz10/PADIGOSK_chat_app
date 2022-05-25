// ignore_for_file: prefer_const_constructors

import 'package:chat_app/service_locators.dart';
import 'package:chat_app/src/controllers/navigation/navigation_service.dart';
import 'package:chat_app/src/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  static const String route = 'auth-screen';

  const AuthScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCon = TextEditingController(),
      _passCon = TextEditingController(),
      _pass2Con = TextEditingController(),
      _usernameCon = TextEditingController();
  final AuthController _authController = locator<AuthController>();

  String prompts = '';

  @override
  void initState() {
    _authController.addListener(handleLogin);
    super.initState();
  }

  @override
  void dispose() {
    _authController.removeListener(handleLogin);
    super.dispose();
  }

  void handleLogin() {
    if (_authController.currentUser != null) {
      locator<NavigationService>().pushReplacementNamed(HomeScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _authController,
        builder: (context, Widget? w) {
          if (_authController.working) {
            return const Scaffold(
              resizeToAvoidBottomInset: false,
              body: Center(
                child: SizedBox(
                  width: 50,
                  height: 900,
                  // child: CircularProgressIndicator()
                ),
              ),
            );
          } else {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text('Social Media'),
                centerTitle: true,
                backgroundColor: Color.fromARGB(255, 179, 117, 255),
              ),
              backgroundColor: Color.fromARGB(255, 255, 197, 153),
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 3 / 3,
                          child: Card(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Form(
                                  key: _formKey,
                                  onChanged: () {
                                    _formKey.currentState?.validate();
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  child: DefaultTabController(
                                    length: 2,
                                    initialIndex: 0,
                                    child: Column(
                                      children: [
                                        const TabBar(tabs: [
                                          Tab(
                                            child: Text(
                                              'Log In',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      221, 1, 1, 1)),
                                            ),
                                          ),
                                          Tab(
                                            child: Text(
                                              'Register',
                                              style: TextStyle(
                                                  color: Colors.black87),
                                            ),
                                          )
                                        ]),
                                        Expanded(
                                          child: TabBarView(
                                            children: [
                                              ///login
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(_authController
                                                          .error?.message ??
                                                      ''),
                                                  Flexible(
                                                    child: TextFormField(
                                                      decoration:
                                                          const InputDecoration(
                                                              hintText:
                                                                  'Email'),
                                                      controller: _emailCon,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please enter your email';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    obscureText: true,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'Password',
                                                    ),
                                                    controller: _passCon,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter your password';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: (_formKey
                                                                .currentState
                                                                ?.validate() ??
                                                            false)
                                                        ? () {
                                                            _authController
                                                                .login(
                                                                    _emailCon
                                                                        .text
                                                                        .trim(),
                                                                    _passCon
                                                                        .text
                                                                        .trim());
                                                          }
                                                        : null,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                            ),
                                                            primary: (_formKey
                                                                        .currentState
                                                                        ?.validate() ??
                                                                    false)
                                                                ? const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    161,
                                                                    50,
                                                                    231)
                                                                : Colors.grey),
                                                    child: const Text('Log in'),
                                                  )
                                                ],
                                              ),

                                              ///register
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(_authController
                                                          .error?.message ??
                                                      ''),
                                                  TextFormField(
                                                    decoration:
                                                        const InputDecoration(
                                                            hintText: 'Email'),
                                                    controller: _emailCon,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter your email';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    obscureText: true,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'Password',
                                                    ),
                                                    controller: _passCon,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter your password';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    obscureText: true,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          'Confirm Password',
                                                    ),
                                                    controller: _pass2Con,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please confirm your password';
                                                      } else if (_passCon
                                                              .text !=
                                                          _pass2Con.text) {
                                                        return 'Passwords do not match!';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                                'Username'),
                                                    controller: _usernameCon,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter your username';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: (_formKey
                                                                .currentState
                                                                ?.validate() ??
                                                            false)
                                                        ? () {
                                                            _authController.register(
                                                                email: _emailCon
                                                                    .text
                                                                    .trim(),
                                                                password:
                                                                    _passCon
                                                                        .text
                                                                        .trim(),
                                                                username:
                                                                    _usernameCon
                                                                        .text
                                                                        .trim());
                                                          }
                                                        : null,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                            ),
                                                            primary: (_formKey
                                                                        .currentState
                                                                        ?.validate() ??
                                                                    false)
                                                                ? const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    161,
                                                                    50,
                                                                    231)
                                                                : Colors.grey),
                                                    child:
                                                        const Text('Register'),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}
