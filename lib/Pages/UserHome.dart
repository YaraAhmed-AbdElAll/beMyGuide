import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserHome extends StatefulWidget {
  const UserHome({Key? key}) : super(key: key);

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String connectionStatus = "Disconnected";
  bool inCall = false;
  bool isMuted = false;
  bool isCameraOff = false;

  String userName = '';
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserRequests();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc.data()?['firstName'] ?? 'User';
        });
      }
    }
  }

  Future<void> _loadUserRequests() async {
    final user = _auth.currentUser;
    if (user != null) {
      final querySnapshot = await _firestore
          .collection('requests')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        requests = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'status': data['status'] ?? 'Unknown',
            'volunteerName': data['volunteerName'] ?? 'Unknown',
            'volunteerPhoto': data['volunteerPhotoUrl'], // optional String URL
            'contact': data['volunteerContact'] ?? '',
            'timestamp': data['createdAt']?.toDate() ?? DateTime.now(),
          };
        }).toList();
      });
    }
  }

  void requestAssistance() {
    setState(() {
      inCall = true;
      connectionStatus = "Connecting...";
    });
    // Simulate connecting, then update to live
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        connectionStatus = "Live";
      });
      // TODO: Integrate real call logic here with Firebase or other service
    });
  }

  void endCall() {
    setState(() {
      inCall = false;
      connectionStatus = "Disconnected";
      isMuted = false;
      isCameraOff = false;
    });
    // TODO: End call logic, update Firestore if needed
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
  }

  void toggleCamera() {
    setState(() {
      isCameraOff = !isCameraOff;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color darkBackground = const Color(0xFF121212);
    final Color appBarColor = const Color(0xFF1F1F1F);
    final Color highlightColor = Colors.blueAccent;
    final TextStyle headerTextStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.grey[100],
    );
    final TextStyle subtitleTextStyle = TextStyle(
      fontSize: 16,
      color: Colors.grey[400],
    );

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Semantics(
          header: true,
          child: Text(
            "SeeTogether",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Semantics(
            label: 'Notifications',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // TODO: Navigate to notifications screen
              },
              tooltip: "Notifications",
            ),
          ),
          Semantics(
            label: 'Profile settings',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Navigate to profile/settings screen
              },
              tooltip: "Settings",
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Greeting Section
            Semantics(
              container: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $userName!",
                    style: headerTextStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "You can request visual assistance below.",
                    style: subtitleTextStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Request Assistance Section
            Semantics(
  label: 'Request visual assistance button',
  button: true,
  hint: 'Calls a volunteer now',
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(60),
      backgroundColor: highlightColor, // الزرار الأزرق
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: inCall ? null : requestAssistance,
    child: Column(
      children: const [
        Text(
          "Request Visual Assistance",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, 
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Call a volunteer now",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70, 
          ),
        ),
      ],
    ),
  ),
),

            const SizedBox(height: 30),

            // Video Call Section
            if (inCall)
              Semantics(
                container: true,
                label:
                    'Video call in progress. Connection status: $connectionStatus',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      connectionStatus,
                      style: TextStyle(
                        color: highlightColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Placeholder for video screens
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Volunteer Video',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 100,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Your Self-View',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Semantics(
                          label:
                              isMuted ? 'Unmute microphone' : 'Mute microphone',
                          button: true,
                          child: IconButton(
                            icon: Icon(isMuted ? Icons.mic_off : Icons.mic),
                            color: highlightColor,
                            iconSize: 32,
                            onPressed: toggleMute,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Semantics(
                          label:
                              isCameraOff ? 'Turn camera on' : 'Turn camera off',
                          button: true,
                          child: IconButton(
                            icon: Icon(
                                isCameraOff ? Icons.videocam_off : Icons.videocam),
                            color: highlightColor,
                            iconSize: 32,
                            onPressed: toggleCamera,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Semantics(
                          label: 'End call',
                          button: true,
                          child: IconButton(
                            icon: const Icon(Icons.call_end),
                            color: Colors.redAccent,
                            iconSize: 32,
                            onPressed: endCall,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Semantics(
                          label: 'Switch camera',
                          button: true,
                          child: IconButton(
                            icon: const Icon(Icons.cameraswitch),
                            color: highlightColor,
                            iconSize: 32,
                            onPressed: () {
                              // TODO: Implement camera switch
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (inCall) const SizedBox(height: 30),

            // Active Requests / History Section
            Semantics(
              container: true,
              label: 'Your active and past assistance requests',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Requests",
                    style: headerTextStyle,
                  ),
                  const SizedBox(height: 12),
                  if (requests.isEmpty)
                    Text(
                      "No requests yet.",
                      style: subtitleTextStyle,
                    )
                  else
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: requests.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.grey),
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        return Semantics(
                          label:
                              'Request with volunteer ${req["volunteerName"]}, status: ${req["status"]}',
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[700],
                              backgroundImage: req["volunteerPhoto"] != null
                                  ? NetworkImage(req["volunteerPhoto"])
                                  : null,
                              child: req["volunteerPhoto"] == null
                                  ? Text(
                                      req["volunteerName"]
                                          .toString()
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.grey[300],
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            title: Text(
                              req["volunteerName"],
                              style: TextStyle(
                                color: Colors.grey[100],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "Status: ${req["status"]}",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            trailing: Text(
                              _formatTimestamp(req["timestamp"]),
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            onTap: () {
                              // TODO: Show request details or contact volunteer
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hr ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}