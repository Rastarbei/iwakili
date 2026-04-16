import 'package:i_wakili/screens/signin_screen.dart';
import 'package:i_wakili/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:i_wakili/widgets/custom_scaffold.dart';
import 'package:i_wakili/widgets/welcome_button.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  CustomScaffold(
        child: Column(
          children: [
            Flexible(
                flex: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 40.0,
                  ),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                          children: [
                            TextSpan(
                                text: 'i-Wakili\n',
                                style: TextStyle(
                                  fontSize: 45.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.greenAccent,
                                )),
                            TextSpan(
                                text: '\nWelcome back, you have been missed!',
                                style: TextStyle(
                                  fontSize: 20,
                                ))
                          ]
                      ),
                    ),
                  ),
                )),
            const Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  children: [
                    Expanded(
                      child: WelcomeButton(
                        buttonText: 'Sign in',
                        onTap: SignInScreen(),
                        color: Colors.transparent,
                        textColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: WelcomeButton(
                        buttonText: 'Sign up',
                        onTap: SignUpScreen(),
                        color: Colors.greenAccent,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        )
    );
  }
}


