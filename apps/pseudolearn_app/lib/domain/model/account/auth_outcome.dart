import 'package:equatable/equatable.dart';
import 'account_session.dart';

sealed class AuthOutcome extends Equatable {
  const AuthOutcome();
}

final class Authenticated extends AuthOutcome {
  final AccountSession session;

  const Authenticated(this.session);

  @override
  List<Object?> get props => [session];
}

final class Cancelled extends AuthOutcome {
  const Cancelled();

  @override
  List<Object?> get props => [];
}

final class NoConnection extends AuthOutcome {
  const NoConnection();

  @override
  List<Object?> get props => [];
}

final class Rejected extends AuthOutcome {
  final String reason;

  const Rejected(this.reason);

  @override
  List<Object?> get props => [reason];
}

final class MagicLinkSent extends AuthOutcome {
  final String email;

  const MagicLinkSent(this.email);

  @override
  List<Object?> get props => [email];
}
