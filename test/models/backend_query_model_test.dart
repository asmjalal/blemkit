import 'package:flutter_test/flutter_test.dart';
import 'package:designflutterkit/models/backend_query_model.dart';

void main() {
  group('BackendQuery Model Tests', () {
    test('toJson and fromJson serialization works correctly', () {
      final filter = QueryFilter(column: 'status', operator: 'eq', value: 'active');
      final query = BackendQuery(
        id: 'q1',
        name: 'Test Query',
        tableName: 'users',
        queryType: QueryType.select,
        filters: [filter],
        orderBy: 'created_at',
        ascending: false,
        limit: 10,
        selectColumns: 'id, name, email',
        enableRealtime: true,
      );

      final json = query.toJson();
      final parsedQuery = BackendQuery.fromJson(json);

      expect(parsedQuery.id, 'q1');
      expect(parsedQuery.name, 'Test Query');
      expect(parsedQuery.tableName, 'users');
      expect(parsedQuery.queryType, QueryType.select);
      expect(parsedQuery.orderBy, 'created_at');
      expect(parsedQuery.ascending, false);
      expect(parsedQuery.limit, 10);
      expect(parsedQuery.selectColumns, 'id, name, email');
      expect(parsedQuery.enableRealtime, true);

      expect(parsedQuery.filters.length, 1);
      expect(parsedQuery.filters[0].column, 'status');
      expect(parsedQuery.filters[0].operator, 'eq');
      expect(parsedQuery.filters[0].value, 'active');
    });

    test('copyWith updates fields correctly', () {
      final query = BackendQuery(
        id: 'q1',
        name: 'Test Query',
        tableName: 'users',
      );

      final updatedQuery = query.copyWith(
        name: 'Updated Query',
        limit: 5,
        enableRealtime: true,
      );

      expect(updatedQuery.id, 'q1');
      expect(updatedQuery.name, 'Updated Query');
      expect(updatedQuery.tableName, 'users');
      expect(updatedQuery.limit, 5);
      expect(updatedQuery.enableRealtime, true);
    });
  });
}
