import 'package:i_wakili/Auth/auth_service.dart';
import 'package:i_wakili/screens/homepage.dart';
import 'package:i_wakili/theme/theme.dart';
import 'package:i_wakili/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget{
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  void SignIn() async{
    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(_emailController.text, _passwordController.text);
    } catch (e) {
      showDialog(context: context, builder: ((context) => AlertDialog(
        title: Text(e.toString()),
      )));
    }
  }

  @override
  Widget build(BuildContext context){
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome back Wakili',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        controller: _emailController,
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black26,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please enter your password';
                          }
                          return null;
                        },
                        controller: _passwordController,
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter password mkuu',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black26,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                  'Remember you?',
                                  style: TextStyle(
                                    color: Colors.black26,
                                  )
                              )
                            ],
                          )
                        ],
                      ),
                      GestureDetector(
                          child: Text(
                              'Forgotten password?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              )
                          )
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formSignInKey.currentState!.validate()) {
                              try {
                                await AuthService().signInWithEmailPassword(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                                // ✅ Navigate ONLY after successful login
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePage()),
                                );

                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Login failed: $e")),
                                );
                              }
                            }
                          },
                          child: const Text('Log in'),
                        ),
                      ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Log in with',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}