
class SupabaseConnection {
  final String id;
  final String projectUrl;
  final String anonKey;
  final String? serviceRoleKey;
  final String name;
  final DateTime createdAt;
  
  bool isConnected;
  List<SupabaseTable> tables;

  SupabaseConnection({
    required this.id,
    required this.projectUrl,
    required this.anonKey,
    this.serviceRoleKey,
    required this.name,
    required this.createdAt,
    this.isConnected = false,
    List<SupabaseTable>? tables,
  }) : tables = tables ?? [];

  factory SupabaseConnection.fromJson(Map<String, dynamic> json) {
    return SupabaseConnection(
      id: json['id'] as String,
      projectUrl: json['projectUrl'] as String,
      anonKey: json['anonKey'] as String,
      serviceRoleKey: json['serviceRoleKey'] as String?,
      name: json['name'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      isConnected: json['isConnected'] as bool? ?? false,
      tables: json['tables'] != null
          ? (json['tables'] as List)
              .map((t) => SupabaseTable.fromJson(t as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectUrl': projectUrl,
      'anonKey': anonKey,
      'serviceRoleKey': serviceRoleKey,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'isConnected': isConnected,
      'tables': tables.map((t) => t.toJson()).toList(),
    };
  }

  /// JSON safe to store in localStorage or the project row: never includes
  /// the service-role key, which grants full access to the user's database.
  Map<String, dynamic> toPersistedJson() => toJson()..remove('serviceRoleKey');

  SupabaseConnection copyWith({
    String? id,
    String? projectUrl,
    String? anonKey,
    String? serviceRoleKey,
    String? name,
    DateTime? createdAt,
    bool? isConnected,
    List<SupabaseTable>? tables,
  }) {
    return SupabaseConnection(
      id: id ?? this.id,
      projectUrl: projectUrl ?? this.projectUrl,
      anonKey: anonKey ?? this.anonKey,
      serviceRoleKey: serviceRoleKey ?? this.serviceRoleKey,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isConnected: isConnected ?? this.isConnected,
      tables: tables ?? this.tables,
    );
  }
}

class SupabaseTable {
  final String name;
  final List<SupabaseColumn> columns;

  SupabaseTable({
    required this.name,
    required this.columns,
  });

  factory SupabaseTable.fromJson(Map<String, dynamic> json) {
    return SupabaseTable(
      name: json['name'] as String,
      columns: json['columns'] != null
          ? (json['columns'] as List)
              .map((c) => SupabaseColumn.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'columns': columns.map((c) => c.toJson()).toList(),
    };
  }
}

class SupabaseColumn {
  final String name;
  final String dataType; // text, int4, bool, jsonb, etc.
  final bool isNullable;
  final bool isPrimaryKey;

  SupabaseColumn({
    required this.name,
    required this.dataType,
    required this.isNullable,
    required this.isPrimaryKey,
  });

  factory SupabaseColumn.fromJson(Map<String, dynamic> json) {
    return SupabaseColumn(
      name: json['name'] as String,
      dataType: json['dataType'] as String,
      isNullable: json['isNullable'] as bool? ?? true,
      isPrimaryKey: json['isPrimaryKey'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dataType': dataType,
      'isNullable': isNullable,
      'isPrimaryKey': isPrimaryKey,
    };
  }
}
