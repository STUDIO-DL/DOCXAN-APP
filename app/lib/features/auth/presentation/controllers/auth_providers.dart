import 'package:docxan/app/flavor.dart';
import 'package:docxan/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:docxan/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final flavor = ref.watch(flavorConfigProvider);
  return AuthRepositoryImpl(googleWebClientId: flavor.googleWebClientId);
});
