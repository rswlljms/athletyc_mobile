import 'dart:convert';

import 'package:athletyc/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyAccount extends StatefulWidget{

   @override
  MyAccountState createState() => MyAccountState();
}


class MyAccountState extends State<MyAccount> {



  List<dynamic> regions = [];
  List<dynamic> provinces = [];
  List<dynamic> cities = [];
  List<dynamic> barangays = [];

  String? selectedRegion = null;
  String? selectedProvince = null;
  String? selectedCity = null;
  String? selectedBarangay = null;
  var streetController = TextEditingController();


  Map<String, dynamic> accountDetails = {};
  bool isLoading = true;




   //REGION
  Future<void> loadRegions() async {
  final response = await http.get(Uri.parse('https://psgc.cloud/api/regions'));

  if (response.statusCode == 200) {
    setState(() {
      regions = jsonDecode(response.body);
      selectedRegion = regions.isNotEmpty ? regions[0]['code'] : null;
    });
  } else {
    print('Failed to load regions');
  }
}

Future<void> loadProvinces(String regionCode) async {
  final response = await http.get(Uri.parse('https://psgc.cloud/api/regions/$regionCode/provinces'));

  if (response.statusCode == 200) {
    setState(() {
      provinces = jsonDecode(response.body);
      selectedProvince = provinces.isNotEmpty ? provinces[0]['code'] : null;
      cities.clear(); // Clear cities and barangays
      barangays.clear();
    });
  } else {
    print('Failed to load provinces');
  }
}

Future<void> loadCities(String provinceCode) async {
  try {
    final citiesResponse = await http.get(Uri.parse('https://psgc.cloud/api/provinces/$provinceCode/cities'));
    final municipalitiesResponse = await http.get(Uri.parse('https://psgc.cloud/api/provinces/$provinceCode/municipalities'));

    if (citiesResponse.statusCode == 200 && municipalitiesResponse.statusCode == 200) {
      final List<dynamic> cityList = jsonDecode(citiesResponse.body);
      final List<dynamic> municipalityList = jsonDecode(municipalitiesResponse.body);

      setState(() {
        cities = [...cityList, ...municipalityList]; // Merge them into one list
        selectedCity = cities.isNotEmpty ? cities[0]['code'] : null;  // Set default city
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
  final barangayResponse = await http.get(Uri.parse('https://psgc.cloud/api/cities-municipalities/$cityOrMunicipalityCode/barangays'));

  if (barangayResponse.statusCode == 200) {
    setState(() {
      barangays = jsonDecode(barangayResponse.body);
      selectedBarangay = barangays.isNotEmpty ? barangays[0]['code'] : null; // Default to first barangay
    });
  } else {
    print('Failed to load barangays');
  }
}

// Future<void> saveAddress(String email) async {
//   final response = await http.post(
//     Uri.parse('http://192.168.94.39:5000/api/update_address'),
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({
//       'email': email,
//       'region': selectedRegion,
//       'province': selectedProvince,
//       'city': selectedCity,
//       'brgy': selectedBarangay,
//     }),
//   );

//   if (response.statusCode == 200) {
//     print("Address updated!");
//   } else {
//     print("Failed to update address");
//   }
// }

@override
void initState() {
  super.initState();
  loadRegions();
  _loadEmailAndFetchAccount();
}

Future<void> _loadEmailAndFetchAccount() async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');

  if (email != null) {
    await _fetchAccountDetails(email);
  } else {
    setState(() {
      isLoading = false;
    });
  }
}

Future<void> _fetchAccountDetails(String email) async {
  final response = await http.post(
    AppConfig.profile,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    String? fetchedRegion = data['region'];
    String? fetchedProvince = data['province'];
    String? fetchedCity = data['city'];
    String? fetchedBarangay = data['brgy'];

    await loadRegions();
    
    // Find matching region code by name
    String? fetchedRegionCode = regions.firstWhere(
      (region) => region['name'] == fetchedRegion,
      orElse: () => null,
    )?['code'];

  if (fetchedRegionCode != null) {
    await loadProvinces(fetchedRegionCode!);
  } else {
    print("Error: Region code is null");
  }

    String? fetchedProvinceCode = provinces.firstWhere(
      (prov) => prov['name'] == fetchedProvince,
      orElse: () => null,
    )?['code'];

    
    if (fetchedRegionCode != null) {
      await loadCities(fetchedProvinceCode!);
    } else {
      print("Error: Region code is null");
      // Optionally show a user-facing error or handle fallback
    }


    String? fetchedCityCode = cities.firstWhere(
      (city) => city['name'] == fetchedCity,
      orElse: () => null,
    )?['code'];

    if (fetchedCityCode != null) {
      await loadBarangays(fetchedCityCode!);
    }


    String? fetchedBarangayCode = barangays.firstWhere(
      (b) => b['name'] == fetchedBarangay,
      orElse: () => null,
    )?['code'];

    setState(() {
      isLoading = false;
      accountDetails = data;
      selectedRegion = fetchedRegionCode;
      selectedProvince = fetchedProvinceCode;
      selectedCity = fetchedCityCode;
      selectedBarangay = fetchedBarangayCode;
    });
  } else {
    setState(() {
      isLoading = false;
    });
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('My Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
          child: Column(
            
                  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///NAME
              Row(
              
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                       flex: 3,
                      child: Text(
                        'Name:', 
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                    Expanded(
                       flex: 5,
                      child: Text(
                        accountDetails['name'] ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 84, 84, 84))),
                    ),
                  
                      //Expanded(child: const Icon(Icons.keyboard_arrow_right, size: 20))
                  ],
                ),
                const SizedBox(height: 5),
                ///const Divider(),
                const SizedBox(height: 5),

                 ///MOBILE NUMBER
              Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Mobile Number:', 
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        accountDetails['mobile_no'] ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 84, 84, 84))),
                    ),
                  
                      //Expanded(child: const Icon(Icons.keyboard_arrow_right, size: 20))
                  ],
                ),
                const SizedBox(height: 5),
                //const Divider(),
                const SizedBox(height: 5),

                 ///EMAIL
              Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Email:', 
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        accountDetails['email'] ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 84, 84, 84))),
                    ),
                  
                      //Expanded(child: const Icon(Icons.keyboard_arrow_right, size: 20))
                  ],
                ),
                const SizedBox(height: 5),
                //const Divider(),
                const SizedBox(height: 5),


              //    ///PASSWORD
              // GestureDetector(
              //   child: Row(
              //       children: [
              //         const SizedBox(width: 16),
              //         Expanded(
              //           flex: 5,
              //           child: Text(
              //             'Password', 
              //             overflow: TextOverflow.ellipsis,
              //             maxLines: 1,
              //             textAlign: TextAlign.left,
              //             style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              //         ),
              //         Expanded(
              //           flex: 3,
              //           child: Text(
              //             'Change Password', 
              //             overflow: TextOverflow.ellipsis,
              //             maxLines: 1,
              //             textAlign: TextAlign.left,
              //             style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 84, 84, 84))),
              //         ),
                    
              //           Expanded(child: const Icon(Icons.keyboard_arrow_right, size: 20))
              //       ],
              //     ),
              // ),
              //   const SizedBox(height: 5),
              //   const Divider(),
              //   const SizedBox(height: 5),


                 ///ADDRESS
              Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Address:', 
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        '${accountDetails['region'] ?? 'N/A'}, ${accountDetails['province'] ?? 'N/A'}, ${accountDetails['city'] ?? 'N/A'}, ${accountDetails['brgy'] ?? 'N/A'}, ${accountDetails['street'] ?? ''}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 84, 84, 84))),
                    ),
                  
                      //Expanded(child: const Icon(Icons.keyboard_arrow_right, size: 20))
                  ],
                ),
                const SizedBox(height: 5),
              //   //const Divider(),
              //   const SizedBox(height: 5),

              //    //---------ADDRESS

              //     Padding(
              //       padding: const EdgeInsets.all(16.0),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             'Edit Address', 
              //             overflow: TextOverflow.ellipsis,
              //             maxLines: 1,
              //             textAlign: TextAlign.left,
              //             style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    
                    
              //            ////REGION
              //           Text("Region *", style: TextStyle(fontSize: 16),),
              //           const SizedBox(height: 8.0,),
                    
              //            RegionDropDown(), //NASA BABA
                          
              //           const SizedBox(height: 8.0),
                    
                      
                    
                    
              //           ///PROVINCE
              //           Text("Province *", style: TextStyle(fontSize: 16),),
              //           const SizedBox(height: 8.0,),
                        
              //           ProvinceDropDown(), //nasa baba
              //           const SizedBox(height: 8.0,),
                    
                    
              //           ///------CITY
              //           Text("City/Municipalty *", style: TextStyle(fontSize: 16),),
              //           const SizedBox(height: 8.0,),
                    
              //           CityDropDown(), //baba
              //           const SizedBox(height: 8.0,),
                    
                    
              //           ///BARANGAY
              //           Text("Barangay *", style: TextStyle(fontSize: 16),),
              //           const SizedBox(height: 8.0,),
              //           BrgyDropDown(),//nasa baba
              //           const SizedBox(height: 8.0,),


              //           ///STREET
              //           Text("Street Name, Building, House No.", style: TextStyle(fontSize: 16),),
              //           const SizedBox(height: 8.0,),

              //           TextFormField(
              //             controller: streetController,
                          
              //             decoration: InputDecoration(
              //               hintText: accountDetails['street'] ?? '',
              //               contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
              //               enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color.fromARGB(255, 225, 225, 225))),
              //               focusedBorder: OutlineInputBorder(
              //                 borderRadius: BorderRadius.circular(10),
              //                 borderSide: const BorderSide(color: Colors.black),
              //               ),
              //             ),
              //           ),
              //           const SizedBox(height: 16.0,),
              //         ],
              //       ),
              //     ),

              //    //---SUBMIT BUTTON 
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: 50,
              //     child: ElevatedButton(
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.black,
              //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              //       ),
              //       onPressed: () async {
              //         // Validate all required fields
              //         if (selectedRegion == null ||
              //             selectedProvince == null ||
              //             selectedCity == null ||
              //             selectedBarangay == null) {
              //           ScaffoldMessenger.of(context).showSnackBar(
              //             const SnackBar(content: Text("Please complete all required fields.")),
              //           );
              //           return;
              //         }
                
              //         // Optional: show loading indicator
              //         setState(() {
              //           isLoading = true;
              //         });
                
              //         final prefs = await SharedPreferences.getInstance();
              //         final email = prefs.getString('email');
                
              //         final regionName = regions.firstWhere((r) => r['code'] == selectedRegion)['name'];
              //         final provinceName = provinces.firstWhere((p) => p['code'] == selectedProvince)['name'];
              //         final cityName = cities.firstWhere((c) => c['code'] == selectedCity)['name'];
              //         final barangayName = barangays.firstWhere((b) => b['code'] == selectedBarangay)['name'];


              //         final addressData = {
              //           'email': email,
              //           'region': regionName,
              //           'province': provinceName,
              //           'city': cityName,
              //           'brgy': barangayName,
              //           'street': streetController.text.trim(),
              //         };
                
              //         try {
              //           final response = await http.post(
              //             Uri.parse('http://192.168.94.39:5000/api/update_address'),
              //             headers: {'Content-Type': 'application/json'},
              //             body: jsonEncode(addressData),
              //           );
                
              //           if (response.statusCode == 200) {
              //             ScaffoldMessenger.of(context).showSnackBar(
              //               const SnackBar(content: Text("Address updated successfully.")),
              //             );
              //           } else {
              //             ScaffoldMessenger.of(context).showSnackBar(
              //               const SnackBar(content: Text("Failed to update address.")),
              //             );
              //           }
              //         } catch (e) {
              //           ScaffoldMessenger.of(context).showSnackBar(
              //             SnackBar(content: Text("Error: $e")),
              //           );
              //         } finally {
              //           setState(() {
              //             isLoading = false;
              //           });
              //         }
              //       },
              //       child: const Text("Save Address", style: TextStyle(color: Colors.white)),
              //     ),
              //   ),
              // )

            ],
          ),
        ),
      ),
    );

    
  }
  


//------BARANGAY
   DropdownButtonFormField<String> BrgyDropDown() {
    return DropdownButtonFormField<String>(
                  value: selectedBarangay ?? '',
                  hint: const Text("Select your barangay"),
                  isExpanded: true,
                  items: barangays.map<DropdownMenuItem<String>>((barangay) {
                    return DropdownMenuItem<String>(
                      value: barangay['code'], // Assuming 'region' is a map with 'code' and 'name'
                      child: Text(barangay['name']),
                    );
                  }).toList(),
                  onChanged: (String? value) {  // Ensure the 'onChanged' accepts a String? type
                    setState(() {
                      selectedBarangay = value;
                    });
                    // Handle the selected value
                    print('Selected Barangay: $value');
                  },
                  decoration: InputDecoration(
                    hintText: "Select your barangay",
                    contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
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
DropdownButtonFormField<String> CityDropDown() {
  return DropdownButtonFormField<String>(
    value: selectedCity ?? '',
    hint: const Text("Select your city/municipality"),
    isExpanded: true,
    items: cities.map<DropdownMenuItem<String>>((city) {
      return DropdownMenuItem<String>(
        value: city['code'],
        child: Text('${city['name']}'), // Add (City) or (Municipality)
      );
    }).toList(),
    onChanged: (String? value) {
      setState(() {
        selectedCity = value;
        loadBarangays(value!);
      });
      print('Selected City: $value');
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
  DropdownButtonFormField<String> ProvinceDropDown() {
    return DropdownButtonFormField<String>(
                  value: selectedProvince ?? '',
                  hint: const Text("Select your province"),
                  isExpanded: true,
                  items: provinces.map<DropdownMenuItem<String>>((province) {
                    return DropdownMenuItem<String>(
                      value: province['code'], // Assuming 'region' is a map with 'code' and 'name'
                      child: Text(province['name']),
                    );
                  }).toList(),
                  onChanged: (String? value) {  // Ensure the 'onChanged' accepts a String? type
                    setState(() {
                      selectedProvince = value;
                      loadCities(value!);
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
  //-------REGION
DropdownButtonFormField<String> RegionDropDown() {
  return DropdownButtonFormField<String>(
    value: selectedRegion ?? '',
    hint: const Text("Select your region"),
    isExpanded: true,
    items: regions.map<DropdownMenuItem<String>>((region) {
      return DropdownMenuItem<String>(
        value: region['code'],
        child: Text(region['name']),
      );
    }).toList(),
    onChanged: (String? value) {
      setState(() {
        selectedRegion = value;
        loadProvinces(value!);
      });
      print('Selected Region: $value');
    },
    decoration: InputDecoration(
      hintText: "Select your region",
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




