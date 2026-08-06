import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_connection_model.dart';
import '../models/backend_query_model.dart';

class SupabaseDataService {
  static final SupabaseDataService _instance = SupabaseDataService._internal();
  factory SupabaseDataService() => _instance;
  SupabaseDataService._internal();

  /// Validates a user's Supabase connection details.
  Future<bool> testConnection(String projectUrl, String anonKey) async {
    try {
      final sanitizedUrl = projectUrl.endsWith('/')
          ? projectUrl.substring(0, projectUrl.length - 1)
          : projectUrl;
      // Debug print the sanitized URL
      debugPrint('Supabase testConnection: sanitizedUrl=$sanitizedUrl');

      final url = Uri.parse('$sanitizedUrl/rest/v1/');
      debugPrint('Supabase testConnection: request URL=$url');
      final response = await http.get(
        url,
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
      );

      debugPrint('Supabase testConnection: status=${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('Supabase testConnection: response body=${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Supabase testConnection error: $e');
      return false;
    }
  }

  /// Fetches the database schema (tables and columns) from the OpenAPI spec of the PostgREST server.
  Future<List<SupabaseTable>> fetchSchema(SupabaseConnection connection) async {
    try {
      final sanitizedUrl = connection.projectUrl.endsWith('/') 
          ? connection.projectUrl.substring(0, connection.projectUrl.length - 1) 
          : connection.projectUrl;
      
      final url = Uri.parse('$sanitizedUrl/rest/v1/');
      final response = await http.get(
        url,
        headers: {
          'apikey': connection.anonKey,
          'Authorization': 'Bearer ${connection.anonKey}',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch schema: HTTP ${response.statusCode}');
      }

      final schemaData = jsonDecode(response.body) as Map<String, dynamic>;
      final definitions = schemaData['definitions'] as Map<String, dynamic>?;
      if (definitions == null) {
        return [];
      }

      final List<SupabaseTable> tables = [];
      definitions.forEach((tableName, tableDef) {
        // Skip tables with internal or common system names if necessary, 
        // but generally return all defined models.
        final properties = tableDef['properties'] as Map<String, dynamic>?;
        if (properties == null) return;

        final List<SupabaseColumn> columns = [];
        final requiredFields = tableDef['required'] as List<dynamic>? ?? [];

        properties.forEach((colName, colDef) {
          final type = colDef['type'] as String? ?? 'string';
          final format = colDef['format'] as String? ?? '';
          final description = colDef['description'] as String? ?? '';
          
          final isPrimaryKey = description.toLowerCase().contains('primary key');
          final isNullable = !requiredFields.contains(colName);

          columns.add(
            SupabaseColumn(
              name: colName,
              dataType: format.isNotEmpty ? format : type,
              isNullable: isNullable,
              isPrimaryKey: isPrimaryKey,
            ),
          );
        });

        tables.add(SupabaseTable(name: tableName, columns: columns));
      });

      // Sort tables by name
      tables.sort((a, b) => a.name.compareTo(b.name));
      return tables;
    } catch (e) {
      rethrow;
    }
  }

  /// Helper to create a Supabase client for a specific connection.
  SupabaseClient _getClient(SupabaseConnection connection) {
    return SupabaseClient(connection.projectUrl, connection.anonKey);
  }

  Future<List<Map<String, dynamic>>> executeQuery(
    SupabaseConnection connection,
    BackendQuery query, {
    Map<String, dynamic>? activeRowData,
  }) async {
    try {
      final client = _getClient(connection);
      
      if (query.queryType == QueryType.select) {
        dynamic builder = client.from(query.tableName).select(query.selectColumns);

        // Apply filters
        builder = _applyFilters(builder, query.filters, activeRowData);

        // Apply ordering
        if (query.orderBy != null && query.orderBy!.isNotEmpty) {
          builder = builder.order(query.orderBy!, ascending: query.ascending);
        }

        // Apply limit
        if (query.limit != null) {
          builder = builder.limit(query.limit!);
        }

        final response = await builder;
        if (response is List) {
          return List<Map<String, dynamic>>.from(
            response.map((e) => e as Map<String, dynamic>),
          );
        }
        return [];
      } else {
        // In v1 we focus on reading data (Select queries). 
        // We can add simple insert/update/delete support later if needed.
        throw UnimplementedError('Query type ${query.queryType} is not supported in the live editor canvas.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Returns a Stream for real-time streaming queries.
  Stream<List<Map<String, dynamic>>> streamQuery(
    SupabaseConnection connection,
    BackendQuery query,
  ) {
    try {
      final client = _getClient(connection);
      
      // Realtime stream requires primary key column(s) to be set properly in Supabase.
      // Typically, we call client.from(table).stream(primaryKey: ['id'])
      // Let's determine the primary key from connection schema if available, otherwise default to ['id'].
      List<String> primaryKeys = ['id'];
      final tableSchema = connection.tables.firstWhere(
        (t) => t.name == query.tableName,
        orElse: () => SupabaseTable(name: query.tableName, columns: []),
      );
      final pkColumns = tableSchema.columns.where((c) => c.isPrimaryKey).map((c) => c.name).toList();
      if (pkColumns.isNotEmpty) {
        primaryKeys = pkColumns;
      }

      dynamic streamBuilder = client.from(query.tableName).stream(primaryKey: primaryKeys);

      // Apply stream filters if any (Note: stream filters are applied with .eq(), etc.)
      for (final filter in query.filters) {
        if (filter.operator == 'eq') {
          streamBuilder = streamBuilder.eq(filter.column, filter.value);
        }
      }

      // Order stream results
      if (query.orderBy != null && query.orderBy!.isNotEmpty) {
        // Stream order is set via order parameter, or standard Stream options
        streamBuilder = streamBuilder.order(query.orderBy!, ascending: query.ascending);
      }

      // Limit stream results
      if (query.limit != null) {
        streamBuilder = streamBuilder.limit(query.limit!);
      }

      return streamBuilder.map((event) {
        return List<Map<String, dynamic>>.from(event);
      });
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// Applies filters to Postgrest builder.
  dynamic _applyFilters(
    dynamic builder,
    List<QueryFilter> filters,
    Map<String, dynamic>? activeRowData,
  ) {
    var currentBuilder = builder;
    for (final filter in filters) {
      var val = filter.value;
      // Skip empty string values as they are typically placeholders in the UI builder 
      // and cause casting errors (e.g., empty string on a bigint column)
      if (val == null || (val is String && val.isEmpty)) continue;

      // Resolve dynamic parameter if it matches a template variable
      if (val is String && activeRowData != null) {
        final cleanVal = val.replaceAll('{', '').replaceAll('}', '').trim();
        if (activeRowData.containsKey(cleanVal)) {
          val = activeRowData[cleanVal];
        } else if (cleanVal == 'active_id' || cleanVal == 'selected_id') {
          val = activeRowData['id'];
        }
      }

      switch (filter.operator) {
        case 'eq':
          currentBuilder = currentBuilder.eq(filter.column, val);
          break;
        case 'neq':
          currentBuilder = currentBuilder.neq(filter.column, val);
          break;
        case 'gt':
          currentBuilder = currentBuilder.gt(filter.column, val);
          break;
        case 'lt':
          currentBuilder = currentBuilder.lt(filter.column, val);
          break;
        case 'gte':
          currentBuilder = currentBuilder.gte(filter.column, val);
          break;
        case 'lte':
          currentBuilder = currentBuilder.lte(filter.column, val);
          break;
        case 'like':
          currentBuilder = currentBuilder.like(filter.column, val.toString());
          break;
        case 'ilike':
          currentBuilder = currentBuilder.ilike(filter.column, val.toString());
          break;
        case 'is':
          currentBuilder = currentBuilder.is_(filter.column, val);
          break;
        case 'in':
          if (val is List) {
            currentBuilder = currentBuilder.in_(filter.column, val);
          }
          break;
      }
    }
    return currentBuilder;
  }
}
