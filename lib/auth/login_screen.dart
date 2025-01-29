import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:leafy_lenz/services/auth_services.dart';
import 'package:leafy_lenz/utils/wrapper.dart';

import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await _auth.signinUserWithEmailAndPassword(_email.text, _pass.text);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Wrapper()));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _email.dispose();
    _pass.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30,),
              Image.asset("asset/flowers.png", height: 150,),
              const Text("Login", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter Email",
                        labelText: "Email",
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: _email,
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Please enter your email';
                        }else if((!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                            .hasMatch(value))){
                          return 'Please enter a valid email';
                        }else{
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 20,),
                    TextFormField(
                      controller: _pass,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter Password",
                        labelText: "Password",
                      ),
                      obscureText: true,
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Please enter your password';
                        }
                        else if(value.length < 6){
                          return 'Password must be atleast 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24,),
                    ElevatedButton(onPressed: _submitForm, child: const Text("Log In"))
                  ],
                ),
              ),
              const SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        const TextSpan(text: "Don't have an account?  "),
                        TextSpan(
                            text: "Signup",
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                                      ..onTap = (){
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                                      }
                        )
                      ],
                    ),
        
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _signin() async {
  //    await _auth.signinUserWithEmailAndPassword(_email.text, _pass.text);
  //
  // }
}
