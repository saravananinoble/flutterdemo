import 'package:flutter/material.dart';
import 'dart:async';

class NextScreen extends StatefulWidget {
  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<String> images = [
    'assets/m_power.png',
    'assets/yuvo.png',
    'assets/arjun.png',
    // 'assets/compact.png',
    // 'assets/arjun_novo.png',
    'assets/yuvraj.png',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-flip every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          // Top half (ViewFlipper style)
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                // Background layer (dark gray + rotated red rectangle)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFB71C1C), // mrv_red equivalent
                ),
                // Rotated red overlay
                Positioned(
                  left: 200, // move right
                  bottom: 70,
                  right: 0,
                  top: 0,
                  child: Transform.rotate(
                    angle: -0.00, // ~ -10 degrees
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 50 ),
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFF2E2E2E), // mrv_dgray equivalent
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Transform.rotate(
                    angle: -0.18, // ~ -10 degrees
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFF2E2E2E), // mrv_dgray equivalent
                    ),
                  ),
                ),
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(80.0), // adjust value as needed
                        child: Image.asset(
                          images[index],
                          fit: BoxFit.contain,
                        ),
                      ),

                    );
                  },
                ),
                // Overlay row (Build and Validation + Logout)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/bv.png',   // replace with your actual image file
                          width: 42,             // set size similar to Icon
                          height: 42,
                             // optional: tint the image white
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Build and Validation",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.logout, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom half (sliding view with icons)
          Expanded(
            flex: 1,
            child: PageView(
              children: [
                _buildIconPage(context, [
                  _buildNavIcon(
                    context,
                    Image.asset('assets/expense_approval.png', fit: BoxFit.contain),
                    "Expense Approval", ORCScreen(),
                  ),
                  // _buildNavIcon(context, Icons.agriculture, "TDC Daily Update", TDCScreen()),
                  // _buildNavIcon(context, Icons.assignment_late, "CAR", CARScreen()),
                  // _buildNavIcon(context, Icons.warning, "FIR", FIRScreen()),
                ]),
                // _buildIconPage(context, [
                //   _buildNavIcon(context, Icons.settings, "Settings", SettingsScreen()),
                //   _buildNavIcon(context, Icons.info, "Info", InfoScreen()),
                // ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildIconPage(BuildContext context, List<Widget> icons) {
  //   return GridView.count(
  //     crossAxisCount: 2,
  //     padding: EdgeInsets.all(20),
  //     children: icons,
  //   );
  // }

  // Widget _buildIconPage(BuildContext context, List<Widget> icons) {
  //   int crossAxisCount = (MediaQuery.of(context).size.width ~/ 200).clamp(2, 6);
  //   return GridView.count(
  //     crossAxisCount: crossAxisCount,
  //     padding: EdgeInsets.all(20),
  //     children: icons,
  //   );
  // }
  Widget _buildIconPage(BuildContext context, List<Widget> icons) {
    double width = MediaQuery.of(context).size.width;
    int crossAxisCount;

    if (width < 600) {
      crossAxisCount = 2; // phones
    } else if (width < 1200) {
      crossAxisCount = 3; // tablets
    } else {
      crossAxisCount = 4; // desktop
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      padding: EdgeInsets.all(20),
      children: icons,
    );
  }



  // Widget _buildNavIcon(BuildContext context, IconData icon, String label, Widget screen) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  //     },
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(icon, size: 50, color: Colors.red),
  //         SizedBox(height: 8),
  //         Text(label, style: TextStyle(color: Colors.white)),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildNavIcon(BuildContext context, Widget graphic, String label, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: graphic, // now can be Icon or Image
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }


}

// Example placeholder screens
class ORCScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("ORC Screen")));
}

class TDCScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("TDC Daily Update")));
}

