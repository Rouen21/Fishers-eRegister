import 'package:firebase_auth/firebase_auth.dart';
import 'package:fishers_e_register/reuse.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;
  bool _isLoading = false;
  bool _hasRegistration = false;

  @override
  void initState() {
    super.initState();
    _checkExistingRegistration();
  }

  Future<void> _checkExistingRegistration() async {
    final status = await checkRegistrationStatus(user.uid);
    setState(() {
      _hasRegistration = status != null && status['exists'] == true;
    });
  }

  Widget _buildActionButton() {
    if (_hasRegistration) {
      return myButton(
        context,
        () {
          Navigator.pushNamed(context, '/status');
        },
        'CHECK STATUS',
      );
    } else {
      return myButton(
        context,
        () {
          if (!_isLoading) {
            _navigateToProcess();
          }
        },
        'GET STARTED',
      );
    }
  }

  Future<void> _navigateToProcess() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushNamed(context, '/process').then((_) {
        _checkExistingRegistration();
      });
    }
  }

  Future<Map<String, dynamic>?> checkRegistrationStatus(String userId) async {
    try {
      print('Checking status for userId: $userId');

      // Check in information collection
      final registrationQuery = await FirebaseFirestore.instance
          .collection('information')
          .where('details.userId', isEqualTo: userId)
          .get();

      // Check in register collection
      final approvedBoatQuery = await FirebaseFirestore.instance
          .collection('register')
          .where('userId', isEqualTo: userId)
          .get();

      print('Found ${registrationQuery.docs.length} registrations');
      print('Found ${approvedBoatQuery.docs.length} approved boats');

      if (registrationQuery.docs.isNotEmpty) {
        final data = registrationQuery.docs.first.data();
        print('Registration status: ${data['status']}');
        return {
          'exists': true,
          'status': data['status'],
          'type': 'registration',
          'data': data
        };
      }

      if (approvedBoatQuery.docs.isNotEmpty) {
        final data = approvedBoatQuery.docs.first.data();
        print('Boat status: approved');
        return {
          'exists': true,
          'status': 'approved',
          'type': 'boat',
          'data': data
        };
      }

      return {
        'exists': false,
        'status': null,
        'type': null,
        'data': null
      };
    } catch (e) {
      print('Error checking registration status: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bch.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Welcome! ',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: (user.displayName ?? "User").toUpperCase(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      myBox(5, 0),
                      Image.asset(
                        'assets/21.png',
                        height: 180,
                      ),
                      myBox(10, 0),
                      const Text(
                        'Fisher\'s eRegister is an innovative system designed to streamline the local registration of boats, enhancing the experience for boat owners and local authorities. By digitizing the registration process, the platform offers a user-friendly interface that allows boat owners to easily navigate the necessary steps.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      myBox(30, 0),
                      _buildActionButton(),
                      myBox(10, 0),
                      myButton1(context, () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      }, 'LOG OUT'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Image.asset(
                  'assets/3.gif',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
