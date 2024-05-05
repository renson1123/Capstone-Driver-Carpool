import 'package:capstone_driver_carpool/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController firstNameTextEditingController = TextEditingController();
  TextEditingController middleNameTextEditingController = TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController employeeNumberTextEditingController = TextEditingController();
  TextEditingController phoneNumberTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController usernameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    signUpFormValidation();
  }

  signUpFormValidation()
  {
    if(firstNameTextEditingController.text.trim().isEmpty)
      {
        cMethods.displaySnackBar("First name cannot be empty", context);
      }
    else if (middleNameTextEditingController.text.trim().isEmpty)
      {
        cMethods.displaySnackBar("Middle name cannot be empty", context);
      }
    else if (lastNameTextEditingController.text.trim().isEmpty)
      {
        cMethods.displaySnackBar("Last name cannot be empty", context);
      }
    else if (employeeNumberTextEditingController.text.trim().isEmpty)
      {
        cMethods.displaySnackBar("Employee number cannot be empty", context);
      }
    else if (phoneNumberTextEditingController.text.trim().length != 11)
      {
        cMethods.displaySnackBar("Phone number must be 11 digits", context);
      }
    else if (!emailTextEditingController.text.contains("@"))
      {
        cMethods.displaySnackBar("Please enter a valid email.", context);
      }
    else if (passwordTextEditingController.text.trim().length < 5)
      {
        cMethods.displaySnackBar("Password must be at least 6 or more characters.", context);
      }
    else
      {
        registerNewUser();
      }
  }

  registerNewUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Registering your account..."),
    );

    // User Authentication
    final User? userFirebase = (
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
      ).catchError((errorMsg)
      {
        Navigator.pop(context);
        cMethods.displaySnackBar(errorMsg, context);
      })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);
    Map userDataMap =
        {
          "name": usernameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "phone": phoneNumberTextEditingController.text.trim(),
          "id": userFirebase.uid,
          "blockStatus": "no",
        };

    usersRef.set(userDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c) => Dashboard()));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [

                const SizedBox(
                  height: 40,
                ),

                const CircleAvatar(
                  radius: 86,
                  backgroundImage: AssetImage("assets/images/avatarman.png"),
                ),

                const SizedBox(
                  height: 10,
                ),


              const SizedBox(height: 32),

              GestureDetector(
                onTap: ()
                {
                  
                },
                  child: const Text(
                    "Select Profile",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ),

              const SizedBox(height: 32),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Name
                  TextField(
                    controller: firstNameTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "First Name",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Middle Name
                  TextField(
                    controller: middleNameTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Middle Name",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Last Name
                  TextField(
                    controller: lastNameTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Last Name",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Employee Number
                  TextField(
                    controller: employeeNumberTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Employee Number",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Phone Number
                  TextField(
                    controller: phoneNumberTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Email
                  TextField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email Address",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Username
                  TextField(
                    controller: usernameTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Password
                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),

              Center(
                child: ElevatedButton(
                  onPressed: ()
                  {
                    checkIfNetworkIsAvailable();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                  ),
                  child: const Text("SIGN UP"),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                  },
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
