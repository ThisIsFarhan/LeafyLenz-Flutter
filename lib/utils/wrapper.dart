import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leafy_lenz/auth/login_screen.dart';
import 'package:leafy_lenz/screens/navigation_screen.dart';
import 'package:leafy_lenz/services/notification_services.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    //notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value){
      print("Device Token: ");
      print(value);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            else if(snapshot.hasError){
              return const Center(
                child: Text("Error"),
              );
            }
            else{
              if(snapshot.data == null){
                //not logged in (signed out)
                return const LoginScreen();
              }
              else{
                //User logged in
                return const NavigationScreen();
              }
            }
          }
      ),
    );
  }
}
