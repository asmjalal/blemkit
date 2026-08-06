import 'package:flutter_test/flutter_test.dart';
import 'package:designflutterkit/models/supabase_connection_model.dart';

void main() {
  group('SupabaseConnection Model Tests', () {
    test('toJson and fromJson serialization works correctly', () {
      final column = SupabaseColumn(
        name: 'id',
        dataType: 'int8',
        isNullable: false,
        isPrimaryKey: true,
      );

      final table = SupabaseTable(
        name: 'users',
        columns: [column],
      );

      final connection = SupabaseConnection(
        id: 'conn1',
        projectUrl: 'https://xyz.supabase.co',
        anonKey: 'anon-key-123',
        serviceRoleKey: 'service-key-456',
        name: 'My Project',
        createdAt: DateTime(2023, 1, 1),
        isConnected: true,
        tables: [table],
      );

      final json = connection.toJson();
      final parsedConnection = SupabaseConnection.fromJson(json);

      expect(parsedConnection.id, 'conn1');
      expect(parsedConnection.projectUrl, 'https://xyz.supabase.co');
      expect(parsedConnection.anonKey, 'anon-key-123');
      expect(parsedConnection.serviceRoleKey, 'service-key-456');
      expect(parsedConnection.name, 'My Project');
      expect(parsedConnection.createdAt, DateTime(2023, 1, 1));
      expect(parsedConnection.isConnected, true);

      expect(parsedConnection.tables.length, 1);
      expect(parsedConnection.tables[0].name, 'users');
      expect(parsedConnection.tables[0].columns.length, 1);
      expect(parsedConnection.tables[0].columns[0].name, 'id');
      expect(parsedConnection.tables[0].columns[0].dataType, 'int8');
      expect(parsedConnection.tables[0].columns[0].isNullable, false);
      expect(parsedConnection.tables[0].columns[0].isPrimaryKey, true);
    });

    test('copyWith updates fields correctly', () {
      final connection = SupabaseConnection(
        id: 'conn1',
        projectUrl: 'https://xyz.supabase.co',
        anonKey: 'anon-key-123',
        name: 'My Project',
        createdAt: DateTime(2023, 1, 1),
      );

      final updatedConnection = connection.copyWith(
        name: 'Updated Project',
        isConnected: true,
      );

      expect(updatedConnection.id, 'conn1');
      expect(updatedConnection.name, 'Updated Project');
      expect(updatedConnection.isConnected, true);
      expect(updatedConnection.projectUrl, 'https://xyz.supabase.co');
    });
  });
}
