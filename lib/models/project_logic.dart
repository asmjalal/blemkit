// Project-level logic definitions: state, data types, API calls, custom code,
// environment values, dependencies and app settings that are not widgets.
//
// Values and conditions used by actions and bindings are plain JSON maps
// (see `lib/logic/logic_values.dart`) so they round-trip through
// `WidgetNode.properties` unchanged.

/// Primitive types a variable, parameter or field can hold. Custom data types
/// and enums are referenced as `DataType:<Name>` and `Enum:<Name>`.
class VarTypes {
  static const String string = 'String';
  static const String integer = 'int';
  static const String decimal = 'double';
  static const String boolean = 'bool';
  static const String color = 'Color';
  static const String dateTime = 'DateTime';
  static const String json = 'JSON';

  /// Component parameters only: a callback the instance supplies as actions.
  static const String action = 'Action';

  static const List<String> primitives = [string, integer, decimal, boolean, color, dateTime, json];

  static bool isDataType(String type) => type.startsWith('DataType:');
  static bool isEnum(String type) => type.startsWith('Enum:');
  static String refName(String type) => type.contains(':') ? type.split(':').last : type;

  /// Human label used in pickers.
  static String label(String type, {bool isList = false}) {
    final base = type.contains(':') ? refName(type) : type;
    return isList ? 'List<$base>' : base;
  }
}

/// A typed, named slot: app/page state variable, page parameter,
/// API/custom-code argument, or data-type field.
class FieldDef {
  String name;
  String type;
  bool isList;
  dynamic defaultValue;
  bool persisted;
  bool required;

  FieldDef({
    required this.name,
    this.type = VarTypes.string,
    this.isList = false,
    this.defaultValue,
    this.persisted = false,
    this.required = false,
  });

  factory FieldDef.fromJson(Map<String, dynamic> json) => FieldDef(
        name: json['name'] as String? ?? 'field',
        type: json['type'] as String? ?? VarTypes.string,
        isList: json['isList'] as bool? ?? false,
        defaultValue: json['defaultValue'],
        persisted: json['persisted'] as bool? ?? false,
        required: json['required'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'isList': isList,
        if (defaultValue != null) 'defaultValue': defaultValue,
        if (persisted) 'persisted': true,
        if (required) 'required': true,
      };

  FieldDef copy() => FieldDef.fromJson(toJson());
}

class CustomDataType {
  String name;
  List<FieldDef> fields;

  CustomDataType({required this.name, List<FieldDef>? fields}) : fields = fields ?? [];

  factory CustomDataType.fromJson(Map<String, dynamic> json) => CustomDataType(
        name: json['name'] as String? ?? 'DataType',
        fields: _list(json['fields']).map(FieldDef.fromJson).toList(),
      );

  Map<String, dynamic> toJson() => {'name': name, 'fields': fields.map((f) => f.toJson()).toList()};
}

class CustomEnum {
  String name;
  List<String> values;

  CustomEnum({required this.name, List<String>? values}) : values = values ?? [];

  factory CustomEnum.fromJson(Map<String, dynamic> json) => CustomEnum(
        name: json['name'] as String? ?? 'Status',
        values: (json['values'] as List? ?? []).map((v) => v.toString()).toList(),
      );

  Map<String, dynamic> toJson() => {'name': name, 'values': values};
}

/// A field extracted from an API response with a simple JSON path such as
/// `$.data.items` or `$.user.name`.
class ApiResponseField {
  String name;
  String jsonPath;
  String type;
  bool isList;

  ApiResponseField({required this.name, required this.jsonPath, this.type = VarTypes.string, this.isList = false});

  factory ApiResponseField.fromJson(Map<String, dynamic> json) => ApiResponseField(
        name: json['name'] as String? ?? 'field',
        jsonPath: json['jsonPath'] as String? ?? r'$',
        type: json['type'] as String? ?? VarTypes.string,
        isList: json['isList'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {'name': name, 'jsonPath': jsonPath, 'type': type, 'isList': isList};
}

/// A REST call. `url`, header values and `body` may contain `[variable]`
/// placeholders that are filled from [variables] when the call runs.
class ApiCallDef {
  String id;
  String name;
  String method;
  String url;
  Map<String, String> headers;
  String bodyType; // none | json | form
  String body;
  List<FieldDef> variables;
  List<ApiResponseField> responseFields;

  ApiCallDef({
    required this.id,
    required this.name,
    this.method = 'GET',
    this.url = '',
    Map<String, String>? headers,
    this.bodyType = 'none',
    this.body = '',
    List<FieldDef>? variables,
    List<ApiResponseField>? responseFields,
  })  : headers = headers ?? {},
        variables = variables ?? [],
        responseFields = responseFields ?? [];

  factory ApiCallDef.fromJson(Map<String, dynamic> json) => ApiCallDef(
        id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: json['name'] as String? ?? 'API Call',
        method: json['method'] as String? ?? 'GET',
        url: json['url'] as String? ?? '',
        headers: (json['headers'] as Map? ?? {}).map((k, v) => MapEntry(k.toString(), v.toString())),
        bodyType: json['bodyType'] as String? ?? 'none',
        body: json['body'] as String? ?? '',
        variables: _list(json['variables']).map(FieldDef.fromJson).toList(),
        responseFields: _list(json['responseFields']).map(ApiResponseField.fromJson).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'method': method,
        'url': url,
        'headers': headers,
        'bodyType': bodyType,
        'body': body,
        'variables': variables.map((v) => v.toJson()).toList(),
        'responseFields': responseFields.map((f) => f.toJson()).toList(),
      };
}

/// User-written Dart: a pure function, an async action, or a widget.
class CustomCodeDef {
  String id;
  String kind; // function | action | widget
  String name;
  List<FieldDef> args;
  String returnType;
  bool returnsList;
  String code;

  CustomCodeDef({
    required this.id,
    required this.kind,
    required this.name,
    List<FieldDef>? args,
    this.returnType = 'void',
    this.returnsList = false,
    this.code = '',
  }) : args = args ?? [];

  factory CustomCodeDef.fromJson(Map<String, dynamic> json) => CustomCodeDef(
        id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
        kind: json['kind'] as String? ?? 'function',
        name: json['name'] as String? ?? 'customCode',
        args: _list(json['args']).map(FieldDef.fromJson).toList(),
        returnType: json['returnType'] as String? ?? 'void',
        returnsList: json['returnsList'] as bool? ?? false,
        code: json['code'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'name': name,
        'args': args.map((a) => a.toJson()).toList(),
        'returnType': returnType,
        'returnsList': returnsList,
        'code': code,
      };
}

class EnvValue {
  String name;
  String type;
  Map<String, String> values; // environment name -> value

  EnvValue({required this.name, this.type = VarTypes.string, Map<String, String>? values}) : values = values ?? {};

  factory EnvValue.fromJson(Map<String, dynamic> json) => EnvValue(
        name: json['name'] as String? ?? 'value',
        type: json['type'] as String? ?? VarTypes.string,
        values: (json['values'] as Map? ?? {}).map((k, v) => MapEntry(k.toString(), v.toString())),
      );

  Map<String, dynamic> toJson() => {'name': name, 'type': type, 'values': values};
}

class PackageDep {
  String name;
  String version;

  PackageDep({required this.name, this.version = 'any'});

  factory PackageDep.fromJson(Map<String, dynamic> json) =>
      PackageDep(name: json['name'] as String? ?? '', version: json['version'] as String? ?? 'any');

  Map<String, dynamic> toJson() => {'name': name, 'version': version};
}

/// Everything about a project that is not a widget tree or the theme.
class ProjectLogic {
  static const int schemaVersion = 2;

  List<FieldDef> appState;
  List<CustomDataType> dataTypes;
  List<CustomEnum> enums;
  List<ApiCallDef> apiCalls;
  List<CustomCodeDef> customCode;
  List<EnvValue> envValues;
  List<String> environments;
  String activeEnvironment;
  List<PackageDep> dependencies;

  /// `none` or `supabase`.
  String authProvider;
  String? loginPageId;
  String? homePageId;

  /// Language codes such as `en`, `es`. The first one is the default.
  List<String> languages;

  /// Translations keyed by text id, then language code.
  Map<String, Map<String, String>> translations;
  bool rtl;

  /// `light`, `dark` or `system`.
  String themeMode;
  String? appIconUrl;
  String? splashColor;

  ProjectLogic({
    List<FieldDef>? appState,
    List<CustomDataType>? dataTypes,
    List<CustomEnum>? enums,
    List<ApiCallDef>? apiCalls,
    List<CustomCodeDef>? customCode,
    List<EnvValue>? envValues,
    List<String>? environments,
    this.activeEnvironment = 'dev',
    List<PackageDep>? dependencies,
    this.authProvider = 'none',
    this.loginPageId,
    this.homePageId,
    List<String>? languages,
    Map<String, Map<String, String>>? translations,
    this.rtl = false,
    this.themeMode = 'light',
    this.appIconUrl,
    this.splashColor,
  })  : appState = appState ?? [],
        dataTypes = dataTypes ?? [],
        enums = enums ?? [],
        apiCalls = apiCalls ?? [],
        customCode = customCode ?? [],
        envValues = envValues ?? [],
        environments = environments ?? ['dev', 'prod'],
        dependencies = dependencies ?? [],
        languages = languages ?? ['en'],
        translations = translations ?? {};

  bool get usesAuth => authProvider != 'none';
  bool get isLocalized => languages.length > 1;

  factory ProjectLogic.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProjectLogic();
    return ProjectLogic(
      appState: _list(json['appState']).map(FieldDef.fromJson).toList(),
      dataTypes: _list(json['dataTypes']).map(CustomDataType.fromJson).toList(),
      enums: _list(json['enums']).map(CustomEnum.fromJson).toList(),
      apiCalls: _list(json['apiCalls']).map(ApiCallDef.fromJson).toList(),
      customCode: _list(json['customCode']).map(CustomCodeDef.fromJson).toList(),
      envValues: _list(json['envValues']).map(EnvValue.fromJson).toList(),
      environments: (json['environments'] as List?)?.map((e) => e.toString()).toList(),
      activeEnvironment: json['activeEnvironment'] as String? ?? 'dev',
      dependencies: _list(json['dependencies']).map(PackageDep.fromJson).toList(),
      authProvider: json['authProvider'] as String? ?? 'none',
      loginPageId: json['loginPageId'] as String?,
      homePageId: json['homePageId'] as String?,
      languages: (json['languages'] as List?)?.map((e) => e.toString()).toList(),
      translations: (json['translations'] as Map? ?? {}).map((k, v) => MapEntry(
            k.toString(),
            (v as Map).map((lk, lv) => MapEntry(lk.toString(), lv.toString())),
          )),
      rtl: json['rtl'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'light',
      appIconUrl: json['appIconUrl'] as String?,
      splashColor: json['splashColor'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'appState': appState.map((v) => v.toJson()).toList(),
        'dataTypes': dataTypes.map((t) => t.toJson()).toList(),
        'enums': enums.map((e) => e.toJson()).toList(),
        'apiCalls': apiCalls.map((a) => a.toJson()).toList(),
        'customCode': customCode.map((c) => c.toJson()).toList(),
        'envValues': envValues.map((e) => e.toJson()).toList(),
        'environments': environments,
        'activeEnvironment': activeEnvironment,
        'dependencies': dependencies.map((d) => d.toJson()).toList(),
        'authProvider': authProvider,
        if (loginPageId != null) 'loginPageId': loginPageId,
        if (homePageId != null) 'homePageId': homePageId,
        'languages': languages,
        'translations': translations,
        'rtl': rtl,
        'themeMode': themeMode,
        if (appIconUrl != null) 'appIconUrl': appIconUrl,
        if (splashColor != null) 'splashColor': splashColor,
      };

  ProjectLogic copy() => ProjectLogic.fromJson(toJson());

  ApiCallDef? apiCallById(String? id) => apiCalls.where((a) => a.id == id).firstOrNull;
  CustomCodeDef? customCodeByName(String? name) => customCode.where((c) => c.name == name).firstOrNull;
  FieldDef? appStateVar(String? name) => appState.where((v) => v.name == name).firstOrNull;
}

List<Map<String, dynamic>> _list(dynamic raw) =>
    (raw as List? ?? []).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();

/// Page-level logic stored on a screen's root node properties.
class PageLogic {
  static List<FieldDef> pageState(Map<String, dynamic> props) =>
      _list(props['pageState']).map(FieldDef.fromJson).toList();

  static List<FieldDef> pageParams(Map<String, dynamic> props) =>
      _list(props['pageParams']).map(FieldDef.fromJson).toList();

  static List<dynamic> onPageLoad(Map<String, dynamic> props) => props['onPageLoad'] as List? ?? const [];

  /// A component root carries its name here; its parameters use `pageParams`.
  static String? componentName(Map<String, dynamic> props) => props['componentName'] as String?;
}
