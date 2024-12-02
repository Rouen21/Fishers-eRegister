import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fishers_e_register/reuse.dart';
import 'package:fishers_e_register/screens/status.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Process extends StatefulWidget {
  const Process({super.key});

  @override
  _ProcessState createState() => _ProcessState();
}

class _ProcessState extends State<Process> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Controllers for text fields
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _boatNameController;
  late TextEditingController _lengthController;
  late TextEditingController _widthController;
  String? _selectedBoatType;
  String? _selectedDate;
  String? _selectedMonth;
  String? _selectedYear;

  // Variables for image names and base64 strings
  String? _imageNameBoat;
  String? _imageNameClearance;
  String? _imageNameCertificate;
  String? _imageNameID;
  String? _imageNameCedula;

  // Variables to store base64 strings
  String? _base64Boat;
  String? _base64Clearance;
  String? _base64Certificate;
  String? _base64ID;
  String? _base64Cedula;

  bool _hasShownError = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _contactController = TextEditingController();
    _addressController = TextEditingController();
    _boatNameController = TextEditingController();
    _lengthController = TextEditingController();
    _widthController = TextEditingController();
  }

  // Function to validate all required fields
  bool _validateFields() {
    // Print values for debugging
    print(
        'Name: ${_firstNameController.text} ${_middleNameController.text} ${_lastNameController.text}');
    print('Contact: ${_contactController.text}');
    print('Address: ${_addressController.text}');
    print('Boat Name: ${_boatNameController.text}');
    print('Length: ${_lengthController.text}');
    print('Width: ${_widthController.text}');
    print('Type: $_selectedBoatType');
    print('Date: $_selectedDate');
    print('Month: $_selectedMonth');
    print('Year: $_selectedYear');

    // Check text fields
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _contactController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _boatNameController.text.trim().isEmpty ||
        _lengthController.text.trim().isEmpty ||
        _widthController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check dropdown selections
    if (_selectedBoatType == null ||
        _selectedDate == null ||
        _selectedMonth == null ||
        _selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all dropdown fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check images
    if (_base64Boat == null ||
        _base64Clearance == null ||
        _base64Certificate == null ||
        _base64ID == null ||
        _base64Cedula == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required images'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _pickImage(String type) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        // Read the file
        final bytes = await pickedFile.readAsBytes();
        // Convert to base64
        final base64String = base64Encode(bytes);

        setState(() {
          switch (type) {
            case 'boat':
              _imageNameBoat = pickedFile.name;
              _base64Boat = base64String;
              break;
            case 'clearance':
              _imageNameClearance = pickedFile.name;
              _base64Clearance = base64String;
              break;
            case 'certificate':
              _imageNameCertificate = pickedFile.name;
              _base64Certificate = base64String;
              break;
            case 'id':
              _imageNameID = pickedFile.name;
              _base64ID = base64String;
              break;
            case 'cedula':
              _imageNameCedula = pickedFile.name;
              _base64Cedula = base64String;
              break;
          }
        });
      }
    } catch (e) {
      print('Error picking image: $e'); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to store all information in Firestore
  Future<void> storeInformation() async {
    // Show initial loading animation
    setState(() => _isLoading = true);

    // Add a small delay to show loading
    await Future.delayed(const Duration(milliseconds: 500));

    // Check validation
    if (!_validateFields()) {
      setState(() => _isLoading = false); // Hide loading if validation fails
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('information').add({
        'ownerName': _firstNameController.text.trim(),
        'boatName': _boatNameController.text.trim(),
        'registrationNumber': DateTime.now().millisecondsSinceEpoch.toString(),
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),

        // Additional details
        'details': {
          'first_name': _firstNameController.text.trim(),
          'middle_name': _middleNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'contact_number': _contactController.text.trim(),
          'address': _addressController.text.trim(),
          'type': _selectedBoatType,
          'measurements': {
            'length': double.parse(_lengthController.text),
            'width': double.parse(_widthController.text),
            'unit': 'feet'
          },
          'date': int.parse(_selectedDate!),
          'month': int.parse(_selectedMonth!),
          'year': int.parse(_selectedYear!),
          'userId': FirebaseAuth.instance.currentUser?.uid,
        },

        // Images
        'images': {
          'boat_image': _base64Boat,
          'clearance_image': _base64Clearance,
          'certificate_image': _base64Certificate,
          'id_image': _base64ID,
          'cedula_image': _base64Cedula,
        }
      });

      // Switch to success animation
      setState(() {
        _isLoading = false;
        _isSubmitting = true;
      });

      // Show success animation
      await Future.delayed(const Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Information successfully saved!'),
          backgroundColor: Colors.green,
        ),
      );

      _clearFields();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Status()),
      );
    } catch (e) {
      print('Error saving to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving information: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isSubmitting = false;
      });
    }
  }

  void _clearFields() {
    setState(() {
      _firstNameController.clear();
      _middleNameController.clear();
      _lastNameController.clear();
      _contactController.clear();
      _addressController.clear();
      _boatNameController.clear();
      _lengthController.clear();
      _widthController.clear();
      _selectedBoatType = null;
      _selectedDate = null;
      _selectedMonth = null;
      _selectedYear = null;
      _imageNameBoat = null;
      _imageNameClearance = null;
      _imageNameCertificate = null;
      _imageNameID = null;
      _imageNameCedula = null;
      _base64Boat = null;
      _base64Clearance = null;
      _base64Certificate = null;
      _base64ID = null;
      _base64Cedula = null;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _boatNameController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  // Add this method to show confirmation dialog
  Future<void> _showResetConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text(
            'Are you sure you want to reset all fields? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reset'),
              onPressed: () {
                Navigator.of(context).pop();
                _clearFields();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All fields have been reset'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 110, 186, 249),  // Match app bar to background
        elevation: 0,  // Remove app bar shadow
      ),
      body: Stack(
        children: [
          Container(
            color: const Color.fromARGB(255, 174, 219, 255), // Sky blue background
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Welcome to the Boat Registration Portal',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  myBox(30, 0),
                  const Text(
                    'Owner Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  myBox(20, 0),
                  Row(
                    children: [
                      Expanded(
                        child: myText1(
                          context,
                          'First Name',
                          controller: _firstNameController,
                        ),
                      ),
                      myBox(0, 10),
                      Expanded(
                        child: myText1(
                          context,
                          'Middle Name',
                          controller: _middleNameController,
                        ),
                      ),
                      myBox(0, 10),
                      Expanded(
                        child: myText1(
                          context,
                          'Last Name',
                          controller: _lastNameController,
                        ),
                      ),
                    ],
                  ),
                  myBox(20, 0),
                  myText1(
                    context,
                    'Enter Contact Number',
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      if (value.isEmpty || !value.startsWith('09')) {
                        _contactController.text = '09';
                        _contactController.selection =
                            TextSelection.fromPosition(
                          const TextPosition(offset: 2),
                        );
                        _hasShownError = false;
                      } else if (value.length > 11) {
                        _contactController.text = value.substring(0, 11);
                        _contactController.selection =
                            TextSelection.fromPosition(
                          const TextPosition(offset: 11),
                        );
                      }

                      // Show warning only once if number is not 11 digits and error hasn't been shown
                      if (value.length < 11 &&
                          !_hasShownError &&
                          value.length > 2) {
                        _hasShownError = true;
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Contact number must be 11 digits'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                            ),
                          );
                      }

                      // Reset error flag if number is complete
                      if (value.length == 11) {
                        _hasShownError = false;
                      }
                    },
                  ),
                  myBox(20, 0),
                  myText1(
                    context,
                    'Enter Address',
                    controller: _addressController,
                  ),
                  myBox(20, 0),
                  const Text(
                    'Vessel Registration',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  myBox(20, 0),
                  myText1(
                    context,
                    'Enter Boat Name',
                    controller: _boatNameController,
                  ),
                  myBox(20, 0),
                  myBoatTypeDropdown(
                    context,
                    'Select Boat Type',
                    value: _selectedBoatType,
                    onChanged: (value) {
                      setState(() {
                        _selectedBoatType = value;
                      });
                    },
                  ),
                  myBox(20, 0),
                  myDateDropdowns(
                    context,
                    'Select Date',
                    selectedYear: _selectedYear != null
                        ? int.parse(_selectedYear!)
                        : null,
                    selectedMonth: _selectedMonth != null
                        ? int.parse(_selectedMonth!)
                        : null,
                    selectedDate: _selectedDate != null
                        ? int.parse(_selectedDate!)
                        : null,
                    onYearChanged: (value) {
                      setState(() {
                        _selectedYear = value?.toString();
                      });
                    },
                    onMonthChanged: (value) {
                      setState(() {
                        _selectedMonth = value?.toString();
                      });
                    },
                    onDateChanged: (value) {
                      setState(() {
                        _selectedDate = value?.toString();
                      });
                    },
                  ),
                  const Text(
                    'Note: This indicates the date the boat was created.',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  myBox(10, 0),
                  Row(
                    children: [
                      Expanded(
                        child: myText1(
                          context,
                          'Length (feet)',
                          controller: _lengthController,
                        ),
                      ),
                      myBox(0, 10),
                      Expanded(
                        child: myText1(
                          context,
                          'Width (feet)',
                          controller: _widthController,
                        ),
                      ),
                    ],
                  ),
                  myBox(20, 0),
                  const Text(
                    'Insert Images',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  myBox(20, 0),
                  const Text('1 Copy of Boat/Vessel'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                              TextEditingController(text: _imageNameBoat),
                          readOnly: true,
                          enabled: false,
                          decoration: const InputDecoration(
                            hintText: 'Selected Image',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      myBox(0, 10),
                      myImageButton(
                          context,
                          _isLoading ? null : () => _pickImage('boat'),
                          'Choose Image'),
                    ],
                  ),
                  myBox(20, 0),
                  const Text('1 Copy of Barangay Clearance'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                              TextEditingController(text: _imageNameClearance),
                          readOnly: true,
                          enabled: false,
                          decoration: const InputDecoration(
                            hintText: 'Selected Image',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      myBox(0, 10),
                      myImageButton(
                          context,
                          _isLoading ? null : () => _pickImage('clearance'),
                          'Choose Image'),
                    ],
                  ),
                  myBox(20, 0),
                  const Text('1 Copy of Barangay Certificate of Ownership'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                              text: _imageNameCertificate),
                          readOnly: true,
                          enabled: false,
                          decoration: const InputDecoration(
                            hintText: 'Selected Image',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      myBox(0, 10),
                      myImageButton(
                          context,
                          _isLoading ? null : () => _pickImage('certificate'),
                          'Choose Image'),
                    ],
                  ),
                  myBox(20, 0),
                  const Text('1 Copy of Government Issued ID'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: _imageNameID),
                          readOnly: true,
                          enabled: false,
                          decoration: const InputDecoration(
                            hintText: 'Selected Image',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      myBox(0, 10),
                      myImageButton(
                          context,
                          _isLoading ? null : () => _pickImage('id'),
                          'Choose Image'),
                    ],
                  ),
                  myBox(20, 0),
                  const Text('1 Copy of Barangay Cedula'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                              TextEditingController(text: _imageNameCedula),
                          readOnly: true,
                          enabled: false,
                          decoration: const InputDecoration(
                            hintText: 'Selected Image',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      myBox(0, 10),
                      myImageButton(
                          context,
                          _isLoading ? null : () => _pickImage('cedula'),
                          'Choose Image'),
                    ],
                  ),
                  myBox(30, 0),
                  myButton2(
                    context,
                    () {
                      if (!_isLoading) {
                        storeInformation();
                      }
                    },
                    'Submit Registration',
                  ),
                  myBox(10, 0),
                  myButton3(
                    context,
                    () {
                      if (!_isLoading) {
                        _showResetConfirmation();
                      }
                    },
                    'Reset',
                  ),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Image.asset(
                  'assets/3.gif', // Loading animation
                  width: 150,
                  height: 150,
                ),
              ),
            ),

          // Success overlay
          if (_isSubmitting)
            Container(
              color: Colors.black54,
              child: Center(
                child: Image.asset(
                  'assets/4.gif', // Success animation
                  width: 150,
                  height: 150,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(String label, String type) {
    String? imageName;
    switch (type) {
      case 'boat':
        imageName = _imageNameBoat;
        break;
      case 'clearance':
        imageName = _imageNameClearance;
        break;
      case 'certificate':
        imageName = _imageNameCertificate;
        break;
      case 'id':
        imageName = _imageNameID;
        break;
      case 'cedula':
        imageName = _imageNameCedula;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(text: imageName),
                readOnly: true,
                enabled: false,
                decoration: const InputDecoration(
                  hintText: 'Selected Image',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            myBox(0, 10),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _pickImage(type),
              child: const Text('Choose Image'),
            ),
          ],
        ),
        myBox(20, 0),
      ],
    );
  }
}
