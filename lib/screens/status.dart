import 'package:flutter/material.dart';
import 'package:fishers_e_register/reuse.dart';

class Status extends StatefulWidget {
  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  bool _isLoading = true;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToHome() async {
    setState(() => _isNavigating = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isNavigating = false);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isNavigating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigation error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkStatus() async {
    setState(() => _isNavigating = true);
    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isNavigating = false);
        // Navigate to status list view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatusListView(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isNavigating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error checking status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isNavigating) {
          _navigateToHome();
        }
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/n.jpg'),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Registration Successful',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        myBox(20, 0),
                        const Text(
                          'Thank you for registering with us. ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        myBox(30, 0),
                        myButton(context, () {
                          if (!_isNavigating) {
                            _checkStatus();
                          }
                        }, 'Check Status'),
                        myBox(10, 0),
                        myButton1(context, () {
                          if (!_isNavigating) {
                            _navigateToHome();
                          }
                        }, 'Back to Home'),
                        myBox(20, 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading || _isNavigating)
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
      ),
    );
  }
}

class StatusListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
        backgroundColor: const Color(0xFF87CEEB), // Sky blue
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF87CEEB), // Sky blue
              const Color(0xFF87CEEB).withOpacity(0.7),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusItem(
              'Pending Registration',
              '2 hours ago',
              Icons.pending_actions,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              'Requirements Issue',
              '1 day ago',
              Icons.error_outline,
              Colors.red,
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              'Registration Successful',
              'Click to View...',
              Icons.check_circle_outline,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
      String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Handle status item tap
        },
      ),
    );
  }
}
