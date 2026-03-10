import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple boolean provider to simulate authentication state
final authProvider = StateProvider<bool>((ref) => false);
