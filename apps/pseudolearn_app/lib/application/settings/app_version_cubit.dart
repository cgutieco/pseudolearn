import 'package:bloc/bloc.dart';
import '../../domain/ports/app_version_source.dart';

final class AppVersionCubit extends Cubit<String> {
  final AppVersionSource source;

  AppVersionCubit({required this.source}) : super('');

  Future<void> init() async {
    emit(await source.read());
  }
}
