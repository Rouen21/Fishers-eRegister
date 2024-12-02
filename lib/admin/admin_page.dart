import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';

const Color kPrimaryColor = Color(0xFF1E88E5);
const Color kBackgroundColor = Color(0xFF87CEEB);
const Color kCardColor = Colors.white;
const Color kSearchBarColor = Colors.white;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/admin',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error signing out'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImageWithLoading(String base64String, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:'),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FutureBuilder<Uint8List>(
            future: Future.value(base64Decode(base64String)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Text('Error loading image: ${snapshot.error}');
              }
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          backgroundColor: Colors.black,
                          leading: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        body: Container(
                          color: Colors.black,
                          child: Center(
                            child: InteractiveViewer(
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Image.memory(
                  snapshot.data!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  bool _filterBoat(Map<String, dynamic> boat) {
    final query = _searchQuery.toLowerCase();
    final ownerName = (boat['ownerName'] ?? '').toString().toLowerCase();

    return ownerName.contains(query);
  }

  Widget _buildRegisteredBoatsTab() {
    return Container(
      color: kBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by owner name...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('register')
                  .orderBy('registrationDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 60, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'Something went wrong',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                  );
                }

                final boats = snapshot.data?.docs ?? [];
                final filteredBoats = boats
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .where(_filterBoat)
                    .toList();

                if (filteredBoats.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60,
                            color: Color.fromARGB(255, 255, 255, 255)),
                        SizedBox(height: 16),
                        Text(
                          'No boats found',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  itemCount: filteredBoats.length,
                  itemBuilder: (context, index) {
                    final boat = filteredBoats[index];
                    final docId = boats
                        .firstWhere((doc) =>
                            (doc.data() as Map<String, dynamic>)['boatId'] ==
                            boat['boatId'])
                        .id;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kCardColor,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_boat,
                              color: kPrimaryColor,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            'Boat ID: ${boat['boatId'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.person,
                                  'Owner Name: ${boat['ownerName'] ?? 'N/A'}'),
                              _buildInfoRow(Icons.directions_boat,
                                  'Boat Name: ${boat['boatName'] ?? 'N/A'}'),
                              _buildInfoRow(Icons.calendar_today,
                                  'Registration: ${boat['registrationDate']?.toDate().toString().substring(0, 19) ?? 'N/A'}'),
                              _buildInfoRow(Icons.event_busy,
                                  'Expiration: ${boat['expirationDate']?.toDate().toString().split(' ')[0] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () =>
                                _showDeleteConfirmation(context, docId),
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String docId) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this boat registration?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await FirebaseFirestore.instance
                      .collection('register')
                      .doc(docId)
                      .delete();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Boat registration deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Error deleting registration: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteUserConfirmation(
      BuildContext context, String docId, Map<String, dynamic> user) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this user account?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  // This line deletes the user document from Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(docId)
                      .delete();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User account deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting user: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateBoatStatus(String docId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('information')
          .doc(docId)
          .update({
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _checkExistingRegistrations(String userId) async {
    try {
      // Check for existing registrations in 'information' collection
      final existingRegistrations = await FirebaseFirestore.instance
          .collection('information')
          .where('userId', isEqualTo: userId)
          .get();

      // Check for already registered boats
      final existingBoats = await FirebaseFirestore.instance
          .collection('register')
          .where('userId', isEqualTo: userId)
          .get();

      // Return true if user already has a registration or boat
      return existingRegistrations.docs.isNotEmpty ||
          existingBoats.docs.isNotEmpty;
    } catch (e) {
      print('Error checking registrations: $e');
      return false;
    }
  }

  Future<void> _approveRegistration(
      String docId, Map<String, dynamic> details) async {
    try {
      String userId = details['userId'] ?? '';

      // Check if user already has a registration
      bool hasExisting = await _checkExistingRegistrations(userId);
      if (hasExisting) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'User already has a registered boat or pending registration'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      String boatId = 'BOAT-${DateTime.now().millisecondsSinceEpoch}';

      // Continue with existing approval logic
      await FirebaseFirestore.instance
          .collection('information')
          .doc(docId)
          .update({
        'status': 'approved',
        'boatId': boatId,
      });

      // Add to registered boats collection with userId
      await FirebaseFirestore.instance.collection('register').add({
        'boatId': boatId,
        'userId': userId, // Add userId to track ownership
        'ownerName': '${details['first_name']} ${details['last_name']}',
        'boatName': details['boat_name'] ?? 'N/A',
        'registrationDate': DateTime.now(),
        'expirationDate': DateTime.now().add(const Duration(days: 365)),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving registration: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectRegistration(String docId) async {
    try {
      await updateBoatStatus(docId, 'rejected');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration rejected successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting registration: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Container(
        color: kBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // Custom header with tabs
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fisher\'s eRegister',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout,
                              color: Color(0xFF1E88E5)),
                          onPressed: _signOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: const UnderlineTabIndicator(
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        tabs: const [
                          Tab(
                            child: Text(
                              'Accounts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Tab(
                            child: Text(
                              'Registration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Tab(
                            child: Text(
                              'Registered Boats',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        labelColor: const Color(0xFF1E88E5),
                        unselectedLabelColor: Colors.grey,
                        padding: EdgeInsets.zero,
                        indicatorPadding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    // Accounts Tab
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 60, color: Colors.red[300]),
                                const SizedBox(height: 16),
                                const Text(
                                  'Something went wrong',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kPrimaryColor),
                            ),
                          );
                        }

                        final users = snapshot.data?.docs ?? [];

                        if (users.isEmpty) {
                          return Container(
                            color: kBackgroundColor,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_off,
                                    size: 60,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No accounts found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Container(
                          color: kBackgroundColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user =
                                  users[index].data() as Map<String, dynamic>;
                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: kCardColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: kPrimaryColor,
                                        size: 28,
                                      ),
                                    ),
                                    title: Text(
                                      user['name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        _buildInfoRow(Icons.email,
                                            user['email'] ?? 'No Email'),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _showDeleteUserConfirmation(
                                              context, users[index].id, user),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    // Registration Tab
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('information')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 60, color: Colors.red[300]),
                                const SizedBox(height: 16),
                                const Text(
                                  'Something went wrong',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kPrimaryColor),
                            ),
                          );
                        }

                        final boats = snapshot.data?.docs ?? [];

                        if (boats.isEmpty) {
                          return Container(
                            color: kBackgroundColor,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.directions_boat,
                                    size: 60,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No registrations found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Container(
                          color: kBackgroundColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: boats.length,
                            itemBuilder: (context, index) {
                              final boat = boats[index].data() as Map<String, dynamic>;
                              final docId = boats[index].id;
                              final details = boat['details'] as Map<String, dynamic>? ?? {};
                              final measurements = details['measurements']
                                      as Map<String, dynamic>? ??
                                  {};

                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: kCardColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.all(8),
                                      childrenPadding: const EdgeInsets.all(8),
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: kPrimaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.directions_boat,
                                          color: kPrimaryColor,
                                          size: 28,
                                        ),
                                      ),
                                      title: Text(
                                        '${details['first_name'] ?? ''} ${details['last_name'] ?? ''}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(boat['status'])
                                              ?.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Status: ${boat['status'] ?? 'pending'}',
                                          style: TextStyle(
                                            color:
                                                _getStatusColor(boat['status']),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildSectionTitle(
                                                  'Owner Information'),
                                              const SizedBox(height: 8),
                                              _buildInfoRow(Icons.person,
                                                  'First Name: ${details['first_name'] ?? 'N/A'}'),
                                              _buildInfoRow(
                                                  Icons.person_outline,
                                                  'Middle Name: ${details['middle_name'] ?? 'N/A'}'),
                                              _buildInfoRow(Icons.person,
                                                  'Last Name: ${details['last_name'] ?? 'N/A'}'),
                                              _buildInfoRow(Icons.phone,
                                                  'Contact: ${details['contact_number'] ?? 'N/A'}'),
                                              _buildInfoRow(Icons.location_on,
                                                  'Address: ${details['address'] ?? 'N/A'}'),
                                              const SizedBox(height: 16),
                                              _buildSectionTitle(
                                                  'Boat Information'),
                                              const SizedBox(height: 8),
                                              _buildInfoRow(
                                                  Icons.directions_boat,
                                                  'Boat Name: ${boat['boatName'] ?? 'N/A'}'),
                                              _buildInfoRow(Icons.category,
                                                  'Boat Type: ${details['type'] ?? 'N/A'}'),
                                              _buildInfoRow(Icons.straighten,
                                                  'Length: ${measurements['length']} ${measurements['unit'] ?? 'feet'}'),
                                              _buildInfoRow(Icons.width_normal,
                                                  'Width: ${measurements['width']} ${measurements['unit'] ?? 'feet'}'),
                                              const SizedBox(height: 16),
                                              _buildSectionTitle(
                                                  'Registration Date'),
                                              const SizedBox(height: 8),
                                              _buildInfoRow(
                                                  Icons.calendar_today,
                                                  'Date: ${details['date']}/${details['month']}/${details['year']}'),
                                              if (boat['images'] != null) ...[
                                                const SizedBox(height: 16),
                                                _buildSectionTitle(
                                                    'Submitted Documents'),
                                                const SizedBox(height: 8),
                                                _buildDocumentsSection(
                                                    boat['images']),
                                              ],
                                              const SizedBox(height: 16),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 16, bottom: 16),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                                      onPressed: () => _approveRegistration(docId, details),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                                      onPressed: () => _rejectRegistration(docId),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                      onPressed: () => _showDeleteRegistrationConfirmation(context, docId),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    // Registered Boats Tab (New)
                    _buildRegisteredBoatsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: kPrimaryColor,
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }

  Color? _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildDocumentsSection(Map<String, dynamic> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images['boat_image'] != null)
          _buildImageWithLoading(images['boat_image'], 'Boat Image'),
        if (images['clearance_image'] != null)
          _buildImageWithLoading(
              images['clearance_image'], 'Barangay Clearance'),
        if (images['certificate_image'] != null)
          _buildImageWithLoading(
              images['certificate_image'], 'Certificate of Ownership'),
        if (images['id_image'] != null)
          _buildImageWithLoading(images['id_image'], 'Government ID'),
        if (images['cedula_image'] != null)
          _buildImageWithLoading(images['cedula_image'], 'Cedula'),
      ],
    );
  }

  Future<void> _showDeleteRegistrationConfirmation(BuildContext context, String docId) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this registration?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await FirebaseFirestore.instance
                      .collection('information')
                      .doc(docId)
                      .delete();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting registration: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
