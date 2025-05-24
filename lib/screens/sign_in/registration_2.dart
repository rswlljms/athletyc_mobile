import 'package:athletyc/utils/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:athletyc/screens/sign_in/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegAddress extends StatefulWidget{
  const RegAddress({super.key});

  @override
  State<RegAddress> createState() => _RegAddress();
}

class _RegAddress extends State<RegAddress>{

  late String name;
  late String gender;
  late String birthday;
  late String phone;
  //late String validID;

  List<dynamic> regions = [];
  List<dynamic> provinces = [];
  List<dynamic> cities = [];
  List<dynamic> barangays = [];

  Map<String, dynamic>? selectedRegion;
  Map<String, dynamic>? selectedProvince;
  Map<String, dynamic>? selectedCity;
  Map<String, dynamic>? selectedBarangay;

  // String? selectedProvince = null;
  // String? selectedCity = null;
  // String? selectedBarangay = null;

  
  var formKey = GlobalKey<FormState>();
  var streetController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var cfrmPassController = TextEditingController();
  var isObsecure = true.obs;
  var isObsecure1 = true.obs; //for password icon


   //REGION
 Future<void> loadRegions() async {
  final response = await http.get(Uri.parse('https://psgc.cloud/api/regions'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      regions = data;
      selectedRegion = regions.isNotEmpty ? regions[0] : null;
    });
  } else {
    print('Failed to load regions');
  }
}


  // Fetch provinces for a given region
  Future<void> loadProvinces(String regionCode) async {
  final response = await http.get(Uri.parse('https://psgc.cloud/api/regions/$regionCode/provinces'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      provinces = data;
      selectedProvince = provinces.isNotEmpty ? provinces[0] : null;
      cities.clear();
      barangays.clear();
    });
  } else {
    print('Failed to load provinces');
  }
}

  //LFOR CITIES
  Future<void> loadCities(String provinceCode) async {
    try {
      final citiesResponse = await http.get(Uri.parse('https://psgc.cloud/api/provinces/$provinceCode/cities'));
      final municipalitiesResponse = await http.get(Uri.parse('https://psgc.cloud/api/provinces/$provinceCode/municipalities'));

      if (citiesResponse.statusCode == 200 && municipalitiesResponse.statusCode == 200) {
        final cityList = jsonDecode(citiesResponse.body);
        final municipalityList = jsonDecode(municipalitiesResponse.body);

        setState(() {
          cities = [...cityList, ...municipalityList];
          selectedCity = null;
          barangays.clear();
        });
      } else {
        print('Failed to load cities or municipalities');
      }
    } catch (e) {
      print('Error loading cities/municipalities: $e');
    }
  }



  Future<void> loadBarangays(String cityOrMunicipalityCode) async {
    final response = await http.get(Uri.parse('https://psgc.cloud/api/cities-municipalities/$cityOrMunicipalityCode/barangays'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        barangays = data;
        selectedBarangay = null;
      });
    } else {
      print('Failed to load barangays');
    }
  }



  @override
  void initState() {
    super.initState();
    final previousData = Get.arguments;
    name = previousData['name'];
    gender = previousData['gender'];
    birthday = previousData['birthday'];
    phone = previousData['phone'];
    //validID = previousData['valid_id'];


    loadRegions();

  }
  
  //SUBMIT REGISTRATION FOR BUTTON
  void submitRegistration() async {

    // Validate email
    String email = emailController.text.trim();
    RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (email.isEmpty || passwordController.text.trim().isEmpty || 
    cfrmPassController.text.trim().isEmpty || selectedRegion == null || 
    selectedProvince == null || selectedCity == null || selectedBarangay == null) {
      Get.snackbar(
        "Error", 
        "Please fill all fields.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; 
    } else if (!emailRegExp.hasMatch(email)) {
      Get.snackbar(
        "Error", 
        "Please enter a valid email address",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      
      print('Sending request with data: ${jsonEncode({
  'name': name,
  'gender': gender,
  'birthday': birthday,
  'phone': phone,
  //'valid_id': validID,
  'region': selectedRegion?['name'],
  'province': selectedProvince?['name'],
  'city': selectedCity?['name'],
  'barangay': selectedBarangay?['name'],
  'street': streetController.text,
  'email': email,
  'password': passwordController.text,
})}');


      final response = await http.post(
        //ip address
        AppConfig.register,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': name,
          'gender': gender,
          'birthday': birthday,
          'phone': phone,
          //'valid_id': validID,
          'region': selectedRegion?['name'],
          'province': selectedProvince?['name'],
          'city': selectedCity?['name'],
          'barangay': selectedBarangay?['name'],
          'street': streetController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
           'confirmpassword': cfrmPassController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {

         // Clear the text fields
        emailController.clear();
        passwordController.clear();
        streetController.clear();
        cfrmPassController.clear();
        streetController.clear();
        selectedBarangay = null;
        selectedCity = null;
        selectedProvince = null;
        selectedRegion = null;

        Get.snackbar(
          "Registration Success", 
          "Please wait for the approval of your account.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate to Login or Home page
      } else {
        Get.snackbar(
          "Error", 
          data['message'] ?? "Registration Failed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error during registration: $e');
       Get.snackbar(
        "Error", 
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }





  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(),
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

              //---------FORM
              Form(
                key: formKey,

                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //---------ADDRESS

                  ////REGION
                  Text("Region *", style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 8.0,),

                   RegionDropDown(), //NASA BABA
  
                  const SizedBox(height: 8.0),

                 


                  ///PROVINCE
                  Text("Province *", style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 8.0,),
                  
                  ProvinceDropDown(), //nasa baba
                  const SizedBox(height: 8.0,),


                  ///------CITY
                  Text("City/Municipalty *", style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 8.0,),

                  CityDropDown(), //baba
                  const SizedBox(height: 8.0,),


                  ///BARANGAY
                  Text("Barangay *", style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 8.0,),
                  BrgyDropDown(),//nasa baba
                  const SizedBox(height: 8.0,),


                  ///STREET
                  Text("Street Name, Building, House No.", style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 8.0,),

                  TextFormField(
                    controller: streetController,
                    
                    decoration: InputDecoration(
                      hintText: "(optional)",
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color.fromARGB(255, 225, 225, 225))),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                     ),
                  ),
                  const SizedBox(height: 16.0,),

                  
                  ///EMAIL
                  Text("Email *", style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 8.0,),

                  TextFormField(
                    controller: emailController,
                    validator: (val) {
                      // Check if the email field is empty
                      if (val == null || val.isEmpty) {
                        return "Email is missing";
                      }
                      // Check if the email format is valid using a regular expression
                      RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegExp.hasMatch(val)) {
                        return "Please enter a valid email address";
                      }
                      return null; // Valid email
                    },
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color.fromARGB(255, 225, 225, 225))),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                     ),
                  ),
                  const SizedBox(height: 16.0,),

                  ///PASSWORD
                  Text("Password *", style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 8.0,),

                  Obx(
                    () => TextFormField(
                    controller: passwordController,
                    obscureText: isObsecure.value,
                    validator: (val) => val == "" ? "Password is missing" : null, ///if no input 

                    decoration: InputDecoration(

                      suffixIcon: Obx(
                          ()=> GestureDetector(
                            onTap: (){isObsecure.value = !isObsecure.value;},
                            child: Icon(
                              isObsecure.value ? Icons.visibility_off : Icons.visibility,
                              color: const Color.fromARGB(255, 86, 86, 86),
                            ),
                          )
                        ),

                      hintText: "Enter your password",
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color.fromARGB(255, 225, 225, 225))),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                     ),
                    ),
                  ),
                  Text("Password must be 8 characters long"),
                  const SizedBox(height: 16.0,),

                  ///-------CONFIRM PASSWORD
                  Text("Confirm Password *", style: TextStyle(fontSize: 16),),
                  const SizedBox(height: 8.0,),
                  
                  Obx(
                    () => TextFormField(
                    controller: cfrmPassController,
                    obscureText: isObsecure1.value,
                    validator: (val) => val == "" ? "Password is missing" : null, ///if no input 
                 
                    decoration: InputDecoration(

                      suffixIcon: Obx(
                          ()=> GestureDetector(
                            onTap: (){isObsecure1.value = !isObsecure1.value;},
                            child: Icon(
                              isObsecure1.value ? Icons.visibility_off : Icons.visibility,
                              color: const Color.fromARGB(255, 86, 86, 86),
                            ),
                          )
                        ),
                      
                      hintText: "Confirm your password",
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color.fromARGB(255, 225, 225, 225))),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                     ),
                    ),
                  ),
                  const SizedBox(height: 46.0,),


                  //---SUBMIT BUTTON 
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, 
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                  onPressed: ()
                  {
                    submitRegistration(); ///NASA PINAKATAAS FULL CONTENT

                  }, 
                  child: const Text('Create Account', style: TextStyle(color: Colors.white),),)),
                const SizedBox(height: 16.0 / 2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: TextStyle(fontSize: 16),),
                    TextButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),);}, 
                    child: const Text('Login', style: TextStyle(color: Colors.blue, fontSize: 16),)),
                    const SizedBox(height: 32.0,),
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



//------BARANGAY
   DropdownButtonFormField<Map<String, dynamic>> BrgyDropDown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
                  value: selectedBarangay,
                  hint: const Text("Select your barangay"),
                  isExpanded: true,
                  items: barangays.map<DropdownMenuItem<Map<String, dynamic>>>((barangay) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: barangay, 
                      child: Text(barangay['name']),
                    );
                  }).toList(),
                  onChanged: (value) {  // Ensure the 'onChanged' accepts a String? type
                    setState(() {
                      selectedBarangay = value;
                    });
                    // Handle the selected value
                    print('Selected Barangay: ${value?['name']}');
                  },
                  decoration: InputDecoration(
                    hintText: "Select your barangay",
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
                );
  }


//-------CITY
DropdownButtonFormField<Map<String, dynamic>> CityDropDown() {
  return DropdownButtonFormField<Map<String, dynamic>>(
    value: selectedCity,
    hint: const Text("Select your city/municipality"),
    isExpanded: true,
    items: cities.map<DropdownMenuItem<Map<String, dynamic>>>((city) {
      return DropdownMenuItem<Map<String, dynamic>>(
        value: city,
        child: Text(city['name']), // Add (City) or (Municipality)
      );
    }).toList(),
    onChanged: (value) {
      setState(() {
        selectedCity = value;
        loadBarangays(value!['code']);
      });
      print('Selected City: ${value?['name']}');
    },
    decoration: InputDecoration(
      hintText: "Select your city/municipality",
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
  );
}


//---------PROVINCE
  DropdownButtonFormField<Map<String, dynamic>> ProvinceDropDown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
                  value: selectedProvince,
                  hint: const Text("Select your province"),
                  isExpanded: true,
                  items: provinces.map<DropdownMenuItem<Map<String, dynamic>>>((province) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: province,
                      child: Text(province['name']),
                    );
                  }).toList(),
                  onChanged: (value) {  // Ensure the 'onChanged' accepts a String? type
                    setState(() {
                      selectedProvince = value;
                      loadCities(value!['code']);
                    });
                    // Handle the selected value
                    print('Selected Province: $value');
                  },
                  decoration: InputDecoration(
                    hintText: "Select your province",
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
                );
  }



///-------region
  DropdownButtonFormField<Map<String, dynamic>> RegionDropDown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
                  value: selectedRegion,
                  hint: const Text("Select your region"),
                  isExpanded: true,
                  items: regions.map<DropdownMenuItem<Map<String, dynamic>>>((region) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: region,
                      child: Text(region['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRegion = value;
                      loadProvinces(value!['code']); // Load provinces for selected region
                    });
                    print('Selected Region: ${value?['name']}');
                  },
                  decoration: InputDecoration(
                    hintText: "Select your Region",
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
                );
  }
}
