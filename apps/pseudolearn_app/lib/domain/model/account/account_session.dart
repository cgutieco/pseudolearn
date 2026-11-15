import 'package:equatable/equatable.dart';
import 'auth_method.dart';

final class AccountSession extends Equatable {
  final String userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final AuthMethod provider;

  const AccountSession({
    required this.userId,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
  });

  @override
  List<Object?> get props => [
        userId,
        email,
        displayName,
        photoUrl,
        provider,
      ];
}
