import 'dart:io';
import 'dart:ui';

import 'package:capstone_driver_carpool/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

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
  TextEditingController driversLicenseExpiryDateTextEditingController = TextEditingController();

  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  XFile? driversLicenseFrontFile;
  XFile? driversLicenseBackFile;
  XFile? medCertFile;
  String urlOfUploadedImage = "";
  String urlOfDriversLicenseFrontFile = "";
  String urlOfDriversLicenseBackFile = "";
  String urlOfMedCertFile = "";

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    if(imageFile != null && driversLicenseFrontFile != null && medCertFile != null) // Image Validation
      {
        signUpFormValidation();
      } else
        {
          cMethods.displaySnackBar("Please choose an image first.", context);
        }

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
    else if (driversLicenseExpiryDateTextEditingController.text.trim().isEmpty)
      {
        cMethods.displaySnackBar("License expiry date cannot be empty", context);
      }
    else
      {
        uploadFilesToStorage();
      }
  }

  uploadFilesToStorage() async
  {
    await uploadImageToStorage();
    await uploadDriversLicenseToStorage();
    await uploadMedCertToStorage();

    registerNewDriver();
  }

  uploadImageToStorage() async
  {
    String imageIDName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Profile Pic").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });
  }

  uploadDriversLicenseToStorage() async
  {
    String driversLicenseIDNameFront = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceDriversLicenseFront = FirebaseStorage.instance.ref().child("Drivers License Front").child(driversLicenseIDNameFront);

    UploadTask uploadTaskFront = referenceDriversLicenseFront.putFile(File(driversLicenseFrontFile!.path));
    TaskSnapshot snapshotFront = await uploadTaskFront;
    urlOfDriversLicenseFrontFile = await snapshotFront.ref.getDownloadURL();

    setState(() {
      urlOfDriversLicenseFrontFile;
    });
    
    String driversLicenseIDNameBack = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceDriversLicenseBack = FirebaseStorage.instance.ref().child("Drivers License Back").child(driversLicenseIDNameBack);

    UploadTask uploadTaskBack = referenceDriversLicenseBack.putFile(File(driversLicenseBackFile!.path));
    TaskSnapshot snapshotBack = await uploadTaskBack;
    urlOfDriversLicenseBackFile = await snapshotBack.ref.getDownloadURL();
  }

  uploadMedCertToStorage() async
  {
    String medCertIDName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceMedCert = FirebaseStorage.instance.ref().child("MedicalCertificates").child(medCertIDName);

    UploadTask uploadTask = referenceMedCert.putFile(File(medCertFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfMedCertFile = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfMedCertFile;
    });
  }



  registerNewDriver() async
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

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);

    Map driverDataMap =
        {
          "photo": urlOfUploadedImage,
          "firstName": firstNameTextEditingController.text.trim(),
          "middleName": middleNameTextEditingController.text.trim(),
          "lastName": lastNameTextEditingController.text.trim(),
          "phone": phoneNumberTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "name": usernameTextEditingController.text.trim(),

          "id": userFirebase.uid,
          "blockStatus": "no",
          "employeeNumber": employeeNumberTextEditingController.text.trim(),
          "licenseFrontFile": urlOfDriversLicenseFrontFile,
          "licenseBackFile": urlOfDriversLicenseBackFile,
          "medicalCertFile": urlOfMedCertFile,
          "licenseExpiryDate": driversLicenseExpiryDateTextEditingController.text.trim(),
        };

    usersRef.set(driverDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c) => Dashboard()));

  }

  chooseImageFromGallery() async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null)
    {
      setState(() {
        imageFile = pickedFile;
      });
    }  
  }

  // Method to choose Driver's License Front image
  chooseDriversLicenseFrontFile() async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null)
      {
        setState(() {
          driversLicenseFrontFile = pickedFile;
        });
      }
  }


  // Method to choose Driver's License Back image
  chooseDriversLicenseBackFile() async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null)
    {
      setState(() {
        driversLicenseBackFile = pickedFile;
      });
    }  
  }



  chooseMedCertFile() async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null)
    {
      setState(() {
        medCertFile = pickedFile;
      });
    }  
  }

  pickLicenseExpiryDate(BuildContext context) async
  {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
    );
    
    if (pickedDate != null)
    {
      setState(() {
        driversLicenseExpiryDateTextEditingController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }  
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

                imageFile == null?
                const CircleAvatar(
                  radius: 86,
                  backgroundImage: AssetImage("assets/images/avatarman.png"),
                ) : Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                    image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: FileImage(
                        File(
                          imageFile!.path,
                        ),
                      )
                    )
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),


              const SizedBox(height: 32),

              GestureDetector(
                onTap: ()
                {
                  chooseImageFromGallery();
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
                  const Text(
                    "PERSONAL INFO",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20,),

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

                  const SizedBox(height: 80),

                  const Text(
                    "ACCOUNT INFO",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 30),


                  // Upload Driver's License Front
                  GestureDetector(
                    onTap: ()
                    {
                      chooseDriversLicenseFrontFile();
                    },
                    child: const Text(
                      "Upload Driver's License Front",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20,),

                  // Upload Driver's License Back
                  GestureDetector(
                    onTap: ()
                    {
                      chooseDriversLicenseBackFile();
                    },
                    child: const Text(
                      "Upload Driver's License Back",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20,),

                  // License Expiry Date
                  TextField(
                    controller: driversLicenseExpiryDateTextEditingController,
                    readOnly: true,
                    onTap: () => pickLicenseExpiryDate(context),
                    decoration: const InputDecoration(
                      labelText: "License Expiry Date",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 30,),

                  // Uploading Medical Certificate
                  GestureDetector(
                    onTap: ()
                    {
                      chooseMedCertFile();
                    },
                    child: const Text(
                      "Upload Medical Certificate",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30,),
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
