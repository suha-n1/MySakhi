import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SosService {
  static Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  static Future<List<Map<String, String>>> _loadContacts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .get();
    return snap.docs
        .map((d) => {
              'name': d.data()['name']?.toString() ?? 'Contact',
              'phone': d.data()['phone']?.toString() ?? '',
            })
        .toList();
  }

  static Future<void> sendSosToAll({
    double? latitude,
    double? longitude,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    String userName = 'Someone';
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      userName = doc.data()?['name'] ?? 'Someone';
    } catch (_) {}

    final pos = await _getLocation();
    final lat = latitude ?? pos?.latitude;
    final lng = longitude ?? pos?.longitude;

    final locationText = (lat != null && lng != null)
        ? 'Live location: https://maps.google.com/?q=$lat,$lng'
        : 'Location unavailable';

    final message = '🚨 EMERGENCY! $userName needs immediate help!\n'
        '$locationText\n'
        'Sent via MySakhi Safety App';

    try {
      await FirebaseDatabase.instance.ref('sos_events/$uid').set({
        'active': true,
        'latitude': lat ?? 0.0,
        'longitude': lng ?? 0.0,
        'triggerSource': 'manual',
      });
    } catch (e) {
      debugPrint('Firebase error: $e');
    }

    final contacts = await _loadContacts();
    for (final contact in contacts) {
      final phone = contact['phone']!.replaceAll(RegExp(r'[^0-9+]'), '');
      if (phone.isEmpty) continue;

      final smsUri = Uri(
        scheme: 'sms',
        path: phone,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
  }
}
