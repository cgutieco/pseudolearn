import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/settings/settings_cubit.dart';
import '../../domain/model/profiles/syntax_profile_for_language.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/settings/effective_ui_language.dart';

ReferenceEdition currentReferenceEdition(BuildContext context) {
  final settings = context.read<SettingsCubit>().state;
  final language = resolveEffectiveLanguage(
    setting: settings.language,
    systemLanguageCode:
        WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );
  return ReferenceEdition(
    language: language,
    profile: syntaxProfileForLanguage(language),
  );
}
