import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';

void main() {
  group('IndexSchema', () {
    test('contains expected columns including sync columns, institutional columns, and tables', () {
      expect(IndexSchema.currentVersion, 3);
      expect(IndexSchema.tableName, 'documents_index');
      expect(IndexSchema.progressTableName, 'content_progress');
      expect(IndexSchema.syncOutboxTableName, 'sync_outbox');
      expect(IndexSchema.syncStateTableName, 'sync_state');

      expect(IndexSchema.createTableSql, contains(IndexSchema.columnId));
      expect(IndexSchema.createTableSql, contains(IndexSchema.columnTitle));
      expect(IndexSchema.createTableSql, contains(IndexSchema.columnProfileId));
      expect(IndexSchema.createTableSql, contains(IndexSchema.columnUpdatedAt));
      expect(IndexSchema.createTableSql, contains(IndexSchema.columnExerciseId));
      expect(IndexSchema.createTableSql, contains(IndexSchema.columnInstitutionId));
      expect(IndexSchema.createTableSql, contains(IndexSchema.columnClassId));
      expect(IndexSchema.createTableSql, contains(IndexSchema.columnMembershipId));
      expect(IndexSchema.createTableSql, contains(IndexSchema.columnSubmissionId));
      expect(IndexSchema.createTableSql, contains(IndexSchema.columnDeletedAt));
      expect(IndexSchema.createTableSql, contains(IndexSchema.columnServerRevision));
      expect(IndexSchema.createTableSql, contains(IndexSchema.columnLastSyncedRevision));

      expect(IndexSchema.createProgressTableSql, contains(IndexSchema.columnContentId));
      expect(IndexSchema.createProgressTableSql, contains(IndexSchema.columnVisited));
      expect(IndexSchema.createProgressTableSql, contains(IndexSchema.columnCompleted));
      expect(IndexSchema.createProgressTableSql, contains(IndexSchema.columnFirstVisitedAt));
      expect(IndexSchema.createProgressTableSql, contains(IndexSchema.columnFirstCompletedAt));
      expect(IndexSchema.createProgressTableSql, contains(IndexSchema.columnDirty));

      expect(IndexSchema.createSyncOutboxTableSql, contains(IndexSchema.columnEntryId));
      expect(IndexSchema.createSyncOutboxTableSql, contains(IndexSchema.columnEntityType));
      expect(IndexSchema.createSyncOutboxTableSql, contains(IndexSchema.columnEntityId));
      expect(IndexSchema.createSyncOutboxTableSql, contains(IndexSchema.columnOperation));
      expect(IndexSchema.createSyncOutboxTableSql, contains(IndexSchema.columnEnqueuedAt));
      expect(IndexSchema.createSyncOutboxTableSql, contains(IndexSchema.columnAttempts));
      expect(IndexSchema.createSyncOutboxTableSql, contains(IndexSchema.columnLastError));

      expect(IndexSchema.createSyncStateTableSql, contains(IndexSchema.columnKey));
      expect(IndexSchema.createSyncStateTableSql, contains(IndexSchema.columnValue));
    });
  });
}
