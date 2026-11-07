import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/library/library_cubit.dart';
import '../../domain/model/documents/document_title_policy.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/reference/reference_program.dart';

void launchReferenceProgram({
  required BuildContext context,
  required ReferenceProgram program,
  required ReferenceEdition edition,
}) {
  final library = context.read<LibraryCubit>();
  final titles = library.state.allDocuments.map((document) => document.title);
  library
      .createDocument(
        title: suggestNextDocumentTitle(program.title, titles),
        profileId: edition.profile,
        content: program.source,
      )
      .then((document) {
        if (document != null && context.mounted) {
          context.push('/biblioteca/documento/${document.id}');
        }
      });
}
