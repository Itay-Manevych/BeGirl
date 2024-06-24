import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'onboarding.dart'; // Import the OnBoarding page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OnBoarding(), // Set the onboarding page as the initial page
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _goToUserLocation() async {
    Position position = await _determinePosition();
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue accessing the position
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle accordingly
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When permissions are granted, get the position
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate button sizes based on screen dimensions
    double buttonWidth = MediaQuery.of(context).size.width * 0.18;
    double buttonHeight = MediaQuery.of(context).size.height * 0.065;
    double centerButtonWidth = MediaQuery.of(context).size.width * 0.25; // Shorter width
    double centerButtonHeight = MediaQuery.of(context).size.height * 0.1;

    double verticalSpacing = 20;
    double bottomOffset = 40;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 11.0,
            ),
          ),
          // Right-side buttons
          Positioned(
            right: 0,
            bottom: bottomOffset,
            child: Column(
              children: [
                CustomButton(
                  icon: Icons.chat,
                  width: buttonWidth,
                  height: buttonHeight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                SizedBox(height: verticalSpacing),
                CustomButton(
                  icon: Icons.my_location,
                  width: buttonWidth,
                  height: buttonHeight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  onTap: _goToUserLocation, // Navigate to user's location
                ),
                SizedBox(height: verticalSpacing),
                CustomButton(
                  icon: Icons.search,
                  width: buttonWidth,
                  height: buttonHeight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
              ],
            ),
          ),
          // Left-side buttons (lower position)
          Positioned(
            left: 0,
            bottom: bottomOffset,
            child: Column(
              children: [
                CustomButton(
                  icon: Icons.menu,
                  width: buttonWidth,
                  height: buttonHeight,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                SizedBox(height: verticalSpacing * 2 + buttonHeight), // To align with the middle right button
                CustomButton(
                  icon: Icons.info,
                  width: buttonWidth,
                  height: buttonHeight,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
              ],
            ),
          ),
          // Center button (Explore button like a flipped "U")
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2 - centerButtonWidth / 2,
            child: GestureDetector(
              onTap: () {
                // Add your explore button action here
              },
              child: Container(
                width: centerButtonWidth, // Adjust width as needed
                height: centerButtonHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4C00C9), Color(0xFF7200EE)], // Adjusted colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: centerButtonHeight * 0.4,
                    ),
                    Text(
                      'Explore',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: centerButtonHeight * 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatefulWidget {
  final IconData icon;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  CustomButton({
    required this.icon,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.onTap,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  void _handleTap() {
    setState(() {
      _isPressed = true;
    });
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _isPressed = false;
      });
    });
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _isPressed ? Color(0xFF4C00C9) : Colors.white, // Change color on click
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            widget.icon,
            color: _isPressed ? Colors.white : Colors.black,
            size: widget.height * 0.5,
          ),
        ),
      ),
    );
  }
}
