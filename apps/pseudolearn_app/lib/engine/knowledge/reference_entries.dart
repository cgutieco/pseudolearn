import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';

const List<KnowledgeEntry> referenceEntries = [
  KnowledgeEntry(
    id: 'reference-classic-spanish',
    type: KnowledgeEntryType.reference,
    title: 'Referencia de sintaxis (Español)',
    summary:
        'Resumen completo de palabras reservadas, tipos y operadores del perfil español clásico.',
    profileId: SyntaxProfileId.classicSpanish,
  ),
  KnowledgeEntry(
    id: 'reference-english',
    type: KnowledgeEntryType.reference,
    title: 'Syntax Reference (English)',
    summary:
        'Comprehensive summary of reserved keywords, types, and operators for the English profile.',
    profileId: SyntaxProfileId.english,
  ),
];
