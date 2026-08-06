enum QueryType { select, insert, update, delete, rpc }

class BackendQuery {
  final String id;
  final String name; // e.g. "Fetch Products"
  final String tableName;
  final QueryType queryType;
  final List<QueryFilter> filters; // where clauses
  final String? orderBy;
  final bool ascending;
  final int? limit;
  final String selectColumns; // e.g. "id, name, price" or "*"
  final bool enableRealtime; // stream vs one-shot

  BackendQuery({
    required this.id,
    required this.name,
    required this.tableName,
    this.queryType = QueryType.select,
    List<QueryFilter>? filters,
    this.orderBy,
    this.ascending = true,
    this.limit,
    this.selectColumns = '*',
    this.enableRealtime = true,
  }) : filters = filters ?? [];

  factory BackendQuery.fromJson(Map<String, dynamic> json) {
    QueryType qType = QueryType.select;
    if (json['queryType'] != null) {
      final typeStr = json['queryType'] as String;
      qType = QueryType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => QueryType.select,
      );
    }

    return BackendQuery(
      id: json['id'] as String,
      name: json['name'] as String,
      tableName: json['tableName'] as String,
      queryType: qType,
      filters: json['filters'] != null
          ? (json['filters'] as List)
              .map((f) => QueryFilter.fromJson(f as Map<String, dynamic>))
              .toList()
          : [],
      orderBy: json['orderBy'] as String?,
      ascending: json['ascending'] as bool? ?? true,
      limit: json['limit'] as int?,
      selectColumns: json['selectColumns'] as String? ?? '*',
      enableRealtime: json['enableRealtime'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tableName': tableName,
      'queryType': queryType.name,
      'filters': filters.map((f) => f.toJson()).toList(),
      'orderBy': orderBy,
      'ascending': ascending,
      'limit': limit,
      'selectColumns': selectColumns,
      'enableRealtime': enableRealtime,
    };
  }

  BackendQuery copyWith({
    String? id,
    String? name,
    String? tableName,
    QueryType? queryType,
    List<QueryFilter>? filters,
    String? orderBy,
    bool? ascending,
    int? limit,
    String? selectColumns,
    bool? enableRealtime,
  }) {
    return BackendQuery(
      id: id ?? this.id,
      name: name ?? this.name,
      tableName: tableName ?? this.tableName,
      queryType: queryType ?? this.queryType,
      filters: filters ?? this.filters,
      orderBy: orderBy ?? this.orderBy,
      ascending: ascending ?? this.ascending,
      limit: limit ?? this.limit,
      selectColumns: selectColumns ?? this.selectColumns,
      enableRealtime: enableRealtime ?? this.enableRealtime,
    );
  }
}

class QueryFilter {
  final String column;
  final String operator; // eq, neq, gt, lt, gte, lte, like, ilike, in, is
  final dynamic value; // static value or bound variable reference

  QueryFilter({
    required this.column,
    required this.operator,
    required this.value,
  });

  factory QueryFilter.fromJson(Map<String, dynamic> json) {
    return QueryFilter(
      column: json['column'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'column': column,
      'operator': operator,
      'value': value,
    };
  }
}
