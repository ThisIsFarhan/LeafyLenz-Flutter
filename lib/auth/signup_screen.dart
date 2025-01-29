import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:leafy_lenz/services/auth_services.dart';

import '../utils/wrapper.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _auth = AuthService();

  final _name = TextEditingController();
  final _age = TextEditingController();
  //final _gender = TextEditingController();
  String? _gender;
  final _email = TextEditingController();
  final _pass = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await _auth.createUserWithEmailAndPassword(_email.text, _pass.text, _name.text, _gender!, _age.text);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Wrapper()));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _name.dispose();
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
              const Text("Sign Up", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter Name",
                          labelText: "Name",
                        ),
                        controller: _name,
                        keyboardType: TextInputType.text,
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25,),
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter Age",
                          labelText: "Age",
                        ),
                        controller: _age,
                        keyboardType: TextInputType.number,
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return 'Please enter your age';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25,),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Gender",
                        ),
                        value: _gender,
                        onChanged: (String? newValue) {
                          setState(() {
                            _gender = newValue;
                          });
                        },
                        items: <String>['Male', 'Female'] // Two gender options
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your gender';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25,),
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
                      const SizedBox(height: 25,),
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter Password",
                          labelText: "Password",
                        ),
                        controller: _pass,
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
                    ],
                  ),
              ),
              const SizedBox(height: 10,),
              ElevatedButton(onPressed: _submitForm, child: const Text("Signup"), ),
              const SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        const TextSpan(text: "Already have an account?  "),
                        TextSpan(
                            text: "Signin",
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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

  // Future<void> _signup() async {
  //   await _auth.createUserWithEmailAndPassword(_email.text, _pass.text, _name.text, _gender.text, _age.text);
  //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Wrapper()));
  // }
}
