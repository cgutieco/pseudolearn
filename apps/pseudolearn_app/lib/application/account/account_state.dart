import 'package:equatable/equatable.dart';
import '../../domain/model/account/account_session.dart';

sealed class AccountState extends Equatable {
  const AccountState();
}

final class AccountUnauthenticated extends AccountState {
  final String? magicLinkSentToEmail;

  const AccountUnauthenticated({this.magicLinkSentToEmail});

  @override
  List<Object?> get props => [magicLinkSentToEmail];
}

final class AccountAuthenticating extends AccountState {
  const AccountAuthenticating();

  @override
  List<Object?> get props => [];
}

final class AccountAuthenticated extends AccountState {
  final AccountSession session;

  const AccountAuthenticated(this.session);

  @override
  List<Object?> get props => [session];
}

final class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}
