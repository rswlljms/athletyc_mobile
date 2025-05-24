import 'package:athletyc/utils/config.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

import 'package:athletyc/screens/sign_in/login.dart';
import 'package:athletyc/screens/sign_in/registration_2.dart';
import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:dotted_border/dotted_border.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}


class _RegistrationState extends State<Registration> {

  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var birthday = TextEditingController();
  var numberController = TextEditingController();
  //var validID = TextEditingController();
  String? selectedGender;

  final TextEditingController _dateController = TextEditingController();
  //File? _image;
  //final ImagePicker _picker = ImagePicker();
  
  //FOR NAME AND NUMBER
  Future<Map<String, dynamic>> login(String name, String number) async {
    final response = await http.post(
      //IP
      AppConfig.login,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'number': number
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return {'success': true, 'user': data['user']};
    } else {
      var data = jsonDecode(response.body);
      return {'success': false, 'message': data['message']};
    }
  }


  //FOR GENDER
  void validateAndSubmit() {
  if (selectedGender == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select your gender.')),
    );
    return;
  }

  // If gender is selected, proceed with registration
  print('Gender selected: $selectedGender');
  }


  ///FOR DATE
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // YYYY-MM-DD
      });
    }
  }

  ///----FOR PICTURE
  // Future<void> _pickImage() async {
  //   final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   }else {
  //   print('No image selected.');
  // }
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only( top: 30.0, left: 24.0, bottom: 54.0, right: 24.0,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //LOGO
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(width: 200, image: AssetImage('assets/image/ath1.png'),),
                  const SizedBox(height: 20.0 * 2,),
                  Text('Registration', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8.0,),
                  Text('Enter your details below', style: TextStyle(fontSize: 16)),
                   const SizedBox(height: 20.0 * 2,),
                ],
              ),

              //FORM
              Form(
                key: formKey,
            
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //NAME
                  Text("Name *", style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 8.0,),
                  TextFormField(
                    controller: nameController,
                    validator: (val) => val == "" ? "Name is missing" : null, ///if no input
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),  // Allows alphabets and spaces
                    ],

                    decoration: InputDecoration(
                      hintText: "Enter your name",

                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color.fromARGB(255, 225, 225, 225))),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                     ),
                  ),
                  const SizedBox(height: 16.0,),

                  //----------GENDER
                  Text("Gender *"),
                  const SizedBox(height: 8.0,),

                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                      // Handle the selected value
                      print('Selected: $value');
                    },
                    decoration: InputDecoration(
                      hintText: "Select your Gender",
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 225, 225, 225)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0,),

                  //BIRTHDAY
                  Text("Date of Birth *"),
                  const SizedBox(height: 8.0,),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      hintText: "Select date of birth",
                      prefixIcon: const Icon(Icons.calendar_today),
                      contentPadding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 225, 225, 225)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0,),
                  Text("Need to be at least 18 years old to register"),
                  const SizedBox(height: 16.0,),


                  ///MOBILE NUMBER
                 Text("Mobile Number *", style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 8.0,),
                  TextFormField(
                    controller: numberController,
                    validator: (val) => val == "" ? "Number is missing" : null, ///if no input of email

                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(11),  // Restrict input to 11 digits
                      FilteringTextInputFormatter.digitsOnly,  // Only allow digits
                    ],
                    decoration: InputDecoration(
                      hintText: "Enter your number",
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color.fromARGB(255, 225, 225, 225))),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                     ),
                  ),
                  const SizedBox(height: 16.0,),

                  //UPLOAD IMAGE/ID
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Text("Upload a Valid ID *", style: TextStyle(fontSize: 16),),
                  //     const SizedBox(height: 16.0,),
                  //     DottedBorder(
                  //       color: Colors.grey,
                  //       strokeWidth: 1,
                  //       dashPattern: [6, 4],
                  //       borderType: BorderType.RRect,
                  //       radius: const Radius.circular(12),
                  //       child: InkWell(
                  //         onTap: _pickImage,
                  //         child: Container(
                  //           height: 150,
                  //           width: double.infinity,
                  //           alignment: Alignment.center,
                  //           child: _image == null
                  //             ? const Text(
                  //             'Click to Upload Image',
                  //             style: TextStyle(color: Colors.grey),
                  //           )
                  //           : Image.file(_image!, fit: BoxFit.cover,)
                  //         )
                  //       )
                  //     ),
                  //   ],
                  // ),
                  
                   const SizedBox(height: 32.0,),

                  //NEXT BUTTON 
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(child: ElevatedButton(style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, 
                      shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                     onPressed: () {
                      if (nameController.text.trim().isEmpty ||
                        selectedGender == null ||
                        _dateController.text.trim().isEmpty ||
                        numberController.text.trim().isEmpty 
                        //||_image == null
                        ) {
                      // Show a snackbar if any field is empty
                      Get.snackbar(
                        "Error", 
                        "Please fill all required fields",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    } else {
                      // Calculate age from the selected birthday
                      DateTime birthDate = DateTime.parse(_dateController.text.trim());
                      int age = DateTime.now().year - birthDate.year;
                      if (DateTime.now().month < birthDate.month || 
                          (DateTime.now().month == birthDate.month && DateTime.now().day < birthDate.day)) {
                        age--;
                      }

                      if (age < 18) {
                        // Show an error message if the age is less than 18
                        Get.snackbar(
                          "Error", 
                          "You must be at least 18 years old to register.",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      } 
                      else if(numberController.text.trim().length != 11){
                        Get.snackbar(
                          "Error", 
                          "Number must be exactly 11 digits.",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                      else {
                        // Navigate to RegAddress if age is 18 or above
                        Get.to(() => RegAddress(), arguments: {
                          'name': nameController.text.trim(),
                          'gender': selectedGender,
                          'birthday': _dateController.text.trim(),
                          'phone': numberController.text.trim(),
                          //'valid_id': _image?.path, // or file path
                        });
                      }
                    }
                                      },
                      child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 16),),)),
                  ],
                ),
                const SizedBox(height: 16.0 / 2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: TextStyle(fontSize: 16),),
                    TextButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),);}, 
                    child: const Text('Login', style: TextStyle(color: Colors.blue, fontSize: 16),)),
                    const SizedBox(height: 30.0,),
                  ],
                )
                
               ],
              ),)
            ],
          ),
        ),
      ),
    );
  }
}