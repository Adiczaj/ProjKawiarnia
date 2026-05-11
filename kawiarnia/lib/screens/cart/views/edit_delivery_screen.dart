// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kawiarnia/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final TextEditingController _labelController = TextEditingController(text: 'Home');
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  GoogleMapController? _mapController;
    
  // Domyślna lokalizacja: Focus Mall Bydgoszcz
  LatLng _selectedLocation = const LatLng(53.1225, 18.0123); 
  
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId('delivery_location'),
        position: _selectedLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authState = context.read<AuthenticationBloc>().state;
    if (authState.status == AuthenticationStatus.authenticated) {
      final userId = authState.user!.userId;
      
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      
      if (doc.exists && doc.data()!.containsKey('defaultAddress')) {
        final data = doc.data()!['defaultAddress'] as Map<String, dynamic>;
        
        setState(() {
          _labelController.text = data['label'] ?? 'Home';
          _streetController.text = data['street'] ?? '';
          _apartmentController.text = data['apartment'] ?? '';
          _cityController.text = data['city'] ?? '';
          _postalCodeController.text = data['postalCode'] ?? '';

          if (data['lat'] != null && data['lng'] != null) {
            _selectedLocation = LatLng(data['lat'], data['lng']);
            _markers.clear();
            _markers.add(
              Marker(
                markerId: const MarkerId('delivery_location'),
                position: _selectedLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              ),
            );
          }
        });

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_selectedLocation, 15),
          );
        }
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    const String apiKey = "AIzaSyAEc2Yzw4n6CeJXQ9y2MmENbSd_pwHXUuU"; 
    
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final components = data['results'][0]['address_components'] as List;

          String streetName = '';
          String streetNumber = '';
          String city = '';
          String postalCode = '';

          for (var component in components) {
            final types = component['types'] as List;
            if (types.contains('route')) {
              streetName = component['long_name'];
            }
            if (types.contains('street_number')) {
              streetNumber = component['long_name'];
            }
            if (types.contains('locality')) {
              city = component['long_name'];
            }
            if (types.contains('postal_code')) {
              postalCode = component['long_name'];
            }
          }

          setState(() {
            _streetController.text = streetName.isEmpty ? '' : '$streetName $streetNumber'.trim();
            _cityController.text = city;
            _postalCodeController.text = postalCode;
            
            _apartmentController.clear();
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie można pobrać adresu z mapy: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBrown = Theme.of(context).colorScheme.primary;
    final Color bgColor = Theme.of(context).colorScheme.surface;
    const Color fieldBg = Color(0xFFF2EFEA);
    const Color textMuted = Color(0xFF8C8A88);
    const Color labelColor = Color(0xFF333333);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Delivery Address',
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              label: 'Label',
              hintText: 'e.g. Home, Office, Studio',
              icon: Icons.bookmark_outline,
              controller: _labelController,
              fieldBgColor: fieldBg,
              labelColor: labelColor,
              hintColor: textMuted,
            ),
            const SizedBox(height: 20),

            _buildInputField(
              label: 'Street & House Number',
              hintText: 'Jagiellońska 39',
              icon: Icons.location_on_outlined,
              controller: _streetController,
              fieldBgColor: fieldBg,
              labelColor: labelColor,
              hintColor: textMuted,
            ),
            const SizedBox(height: 20),

            _buildInputField(
              label: 'Apartment / Suite (Optional)',
              hintText: 'e.g. Apt 5B, Suite 200',
              icon: Icons.domain,
              controller: _apartmentController,
              fieldBgColor: fieldBg,
              labelColor: labelColor,
              hintColor: textMuted,
            ),
            const SizedBox(height: 20),

            _buildInputField(
              label: 'City',
              hintText: 'Bydgoszcz',
              icon: Icons.map_outlined,
              controller: _cityController,
              fieldBgColor: fieldBg,
              labelColor: labelColor,
              hintColor: textMuted,
            ),
            const SizedBox(height: 20),

            _buildInputField(
              label: 'Postal Code',
              hintText: '85-097',
              icon: Icons.location_on_outlined,
              controller: _postalCodeController,
              fieldBgColor: fieldBg,
              labelColor: labelColor,
              hintColor: textMuted,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 32),

            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 14.0,
                  ),
                  markers: _markers,
                  myLocationButtonEnabled: false, 
                  zoomControlsEnabled: false,     
                  mapToolbarEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(_selectedLocation, 14.0),
                    );
                  },
                  onTap: (LatLng location) {
                    setState(() {
                      _selectedLocation = location;
                      _markers.clear();
                      _markers.add(
                        Marker(
                          markerId: const MarkerId('delivery_location'),
                          position: _selectedLocation,
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                        ),
                      );
                    });
                    
                    _getAddressFromLatLng(location);
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final authState = context.read<AuthenticationBloc>().state;
                  if (authState.status != AuthenticationStatus.authenticated) return;

                  final userId = context.read<AuthenticationBloc>().state.user!.userId;
                  
                  final Map<String, dynamic> newAddress = {
                    'label': _labelController.text,
                    'street': _streetController.text,
                    'apartment': _apartmentController.text,
                    'city': _cityController.text,
                    'postalCode': _postalCodeController.text,
                    'lat': _selectedLocation.latitude,
                    'lng': _selectedLocation.longitude,
                  };

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                  );

                  try {
                    await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .set({
                        'defaultAddress': newAddress,
                      }, SetOptions(merge: true));
                    if (mounted) Navigator.pop(context);
                    if (mounted) Navigator.pop(context, newAddress);
                  } catch (e) {
                    if (mounted) Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Błąd zapisu: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrown,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.save_outlined, size: 20),
                label: const Text(
                  'SAVE ADDRESS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    required Color fieldBgColor,
    required Color labelColor,
    required Color hintColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: fieldBgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: hintColor,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, color: hintColor, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}