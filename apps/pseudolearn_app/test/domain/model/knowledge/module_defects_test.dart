import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_defect.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_defects.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_part.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_section.dart';

ModuleSection _section(ModulePart part) => ModuleSection(
      part: part,
      blocks: [ParagraphBlock(text: part.slug)],
    );

LearningModule _module({
  String id = 'CON-B1',
  String title = 'Datos',
  List<ModuleSection>? sections,
}) {
  return LearningModule(
    id: id,
    track: LearningTrack.imperative,
    order: 1,
    title: title,
    sections: sections ?? ModulePart.values.map(_section).toList(),
  );
}

void main() {
  group('findModuleDefects', () {
    test('a module with its seven parts in order has no defects', () {
      expect(findModuleDefects(_module()), isEmpty);
    });

    test('a module without sections is reported and stops further checks', () {
      expect(
        findModuleDefects(_module(sections: const [])),
        [ContentDefect.moduleWithoutSections],
      );
    });

    test('a module missing one part is reported', () {
      final sections = ModulePart.values
          .where((part) => part != ModulePart.exercises)
          .map(_section)
          .toList();

      expect(
        findModuleDefects(_module(sections: sections)),
        contains(ContentDefect.moduleMissingPart),
      );
    });

    test('missingModuleParts names exactly which parts are absent', () {
      final sections = [
        _section(ModulePart.question),
        _section(ModulePart.development),
      ];

      expect(missingModuleParts(_module(sections: sections)), [
        ModulePart.machineModel,
        ModulePart.prediction,
        ModulePart.commonErrors,
        ModulePart.specificationAnchors,
        ModulePart.exercises,
      ]);
    });

    test('parts declared out of the fixed order are reported', () {
      final sections = [
        _section(ModulePart.development),
        _section(ModulePart.question),
        _section(ModulePart.machineModel),
        _section(ModulePart.prediction),
        _section(ModulePart.commonErrors),
        _section(ModulePart.specificationAnchors),
        _section(ModulePart.exercises),
      ];

      expect(
        findModuleDefects(_module(sections: sections)),
        contains(ContentDefect.modulePartsOutOfOrder),
      );
    });

    test('a part with no blocks is reported', () {
      final sections = ModulePart.values
          .map((part) => part == ModulePart.commonErrors
              ? ModuleSection(part: part, blocks: const [])
              : _section(part))
          .toList();

      expect(
        findModuleDefects(_module(sections: sections)),
        contains(ContentDefect.sectionWithoutBlocks),
      );
    });

    test('an empty identifier and an empty title are reported', () {
      final defects = findModuleDefects(_module(id: ' ', title: ''));

      expect(defects, containsAll([
        ContentDefect.emptyIdentifier,
        ContentDefect.emptyTitle,
      ]));
    });

    test('a one character identifier and a one character title are valid', () {
      expect(findModuleDefects(_module(id: 'A', title: 'D')), isEmpty);
    });
  });
}
