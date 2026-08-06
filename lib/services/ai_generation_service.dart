import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/widget_node.dart';

enum AiAgentType {
  openai,
  deepseek,
  kimi,
  gemini,
}

extension AiAgentTypeExtension on AiAgentType {
  String get nameString {
    switch (this) {
      case AiAgentType.openai:
        return 'openai';
      case AiAgentType.deepseek:
        return 'deepseek';
      case AiAgentType.kimi:
        return 'kimi';
      case AiAgentType.gemini:
        return 'gemini';
    }
  }

  static AiAgentType fromString(String str) {
    switch (str.toLowerCase()) {
      case 'openai':
        return AiAgentType.openai;
      case 'kimi':
        return AiAgentType.kimi;
      case 'gemini':
        return AiAgentType.gemini;
      case 'deepseek':
      default:
        return AiAgentType.deepseek;
    }
  }
}

class AiGenerationService {
  static const String _openAiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _deepseekEndpoint = 'https://api.deepseek.com/chat/completions';
  static const String _kimiEndpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions';

  static Future<List<WidgetNode>> generateUi({
    required String prompt,
    required String apiKey,
    required AiAgentType agentType,
    String? currentJson,
    List<Map<String, String>> previousMessages = const [],
    int retryCount = 0,
    String? lastError,
  }) async {
    final String endpoint = agentType == AiAgentType.openai
        ? _openAiEndpoint
        : agentType == AiAgentType.kimi
            ? _kimiEndpoint
            : agentType == AiAgentType.gemini
                ? _geminiEndpoint
                : _deepseekEndpoint;
    final String model = agentType == AiAgentType.openai
        ? 'gpt-4o'
        : agentType == AiAgentType.kimi
            ? 'moonshotai/kimi-k2'
            : agentType == AiAgentType.gemini
                ? 'gemini-2.5-flash'
                : 'deepseek-v4-flash';

    final String systemPrompt = '''
You are an expert Flutter UI generator for the SynappKit platform. Reply with a single valid JSON object only — no markdown fences, no explanations.

[LEGEND]
<color>      = AARRGGBB integer string. "4294967295"=white "4278190080"=black "4283215696"=blue "4294198070"=red "4278222848"=green "4280391411"=grey
<number>     = numeric value (int or double)
<url>        = network image URL string
<icon>       = "Icons.home|search|person|camera_alt|send|favorite_border|notifications_none|settings|more_vert|arrow_back|chat_bubble_outline|add|edit|delete|share|thumb_up|bookmark_border" or any "Icons.<name>" or any "FontAwesomeIcons.<name>"
<fontWeight> = "bold|normal|w400|w500|w600|w700|w800"
<boxFit>     = "BoxFit.cover|contain|fill"
<mainAxis>   = "MainAxisAlignment.start|center|end|spaceBetween|spaceEvenly|spaceAround"
<crossAxis>  = "CrossAxisAlignment.start|center|end|stretch"
<edgeinsets> = number | {"left":<n>,"top":<n>,"right":<n>,"bottom":<n>}

[WIDGET LIST]
LAYOUT:      Scaffold, Row, Column, Stack, Positioned, Expanded, Flexible, Padding, Center, Align, SizedBox, Spacer, Container, FittedBox, Wrap, AspectRatio, ClipRRect, ConstrainedBox, IntrinsicHeight, IntrinsicWidth, SafeArea
SCROLL/LIST: SingleChildScrollView, ListView, GridView, CustomScrollView, ReorderableListView, Carousel
DISPLAY:     Text, RichText, SelectableText, Image, SvgImage, Icon, CircleAvatar, Chip, Badge, Divider, VerticalDivider, Tooltip
BUTTONS:     ElevatedButton, TextButton, OutlinedButton, MaterialButton, IconButton, FloatingActionButton, PopupMenuButton, GestureDetector, InkWell, SegmentedButton, ToggleButtons
INPUT:       TextField, SearchField, Checkbox, CheckboxListTile, Switch, SwitchListTile, Radio, RadioListTile, Slider, RangeSlider, DropdownButton, Form, FormField, AutoComplete, DatePicker, TimePicker
MATERIAL:    AppBar, BottomAppBar, BottomNavigationBar, NavigationRail, TabBar, TabBarView, Drawer, DrawerHeader, Card, ListTile, ExpansionTile, Expandable, AlertDialog, BottomSheet, SnackBar
NAV:         PageView, Navigator, MaterialPageRoute
ASYNC:       FutureBuilder, StreamBuilder, LayoutBuilder, AnimatedBuilder, OrientationBuilder, MediaQuery

[SCHEMA]
{"version":1,"screens":[{"name":"ScreenName","rootWidget":{"id":"unique_snake_id","type":"Scaffold","properties":{},"children":[]}}]}
Every node must have: "id" (unique snake_case), "type" (from list), "properties" {}, "children" [].

[PROPERTIES]
Scaffold:              backgroundColor:<color>  appBar:<AppBar-node>  bottomNavigationBar:<BNB-node>  floatingActionButton:<FAB-node>  [body via children[0]]
AppBar:                title:<Text-node>  backgroundColor:<color>  foregroundColor:<color>  elevation:<number>  centerTitle:bool  actions:[<node>,...]
BottomNavigationBar:   currentIndex:0  type:"fixed"  backgroundColor:<color>  selectedItemColor:<color>  unselectedItemColor:<color>  items:[{"icon":<Icon-node>,"label":"Home","navigateTo":"<id>"},...]
Text:                  text:"..."  fontSize:<number>  color:<color>  fontWeight:<fontWeight>  textAlign:"TextAlign.center|left|right"  maxLines:<number>  overflow:"TextOverflow.ellipsis"
Container:             backgroundColor:<color>  width:<number>|"double.infinity"  height:<number>  padding:<edgeinsets>  margin:<edgeinsets>  borderRadius:<number>  gradient:"linear"  shadowColor:<color>  shadowBlurRadius:<number>
Image:                 src:<url>  width:<number>  height:<number>  fit:<boxFit>  borderRadius:<number>
Icon:                  icon:<icon>  color:<color>  size:<number>
IconButton:            icon:<Icon-node>|string  color:<color>  size:<number>  navigateTo:"<screen_id>"  actions:[<action>,...]
CircleAvatar:          backgroundColor:<color>  radius:<number>  imageUrl:<url>
Card:                  elevation:<number>  color:<color>  borderRadius:<number>  margin:<edgeinsets>
ElevatedButton|TextButton|OutlinedButton: text:"..."  backgroundColor:<color>  foregroundColor:<color>  width:<number>  height:<number>  borderRadius:<number>  navigateTo:"<screen_id>"  actions:[<action>,...]
MaterialButton:        text:"..."  color:<color>  textColor:<color>  disabledColor:<color>  splashColor:<color>  highlightColor:<color>  padding:<edgeinsets>  elevation:<number>  minWidth:<number>  height:<number>  borderRadius:<number>  navigateTo:"<screen_id>"  actions:[<action>,...]
ListTile:              title:<Text-node>|string  subtitle:<Text-node>|string  leading:<node>  trailing:<node>  navigateTo:"<screen_id>"  actions:[<action>,...]  selected:bool  tileColor:<color>
TextField:             hintText:"..."  labelText:"..."  filled:bool  fillColor:<color>  prefixIcon:<icon>  suffixIcon:<icon>  obscureText:bool  border:"OutlineInputBorder|none"
ListView|SingleChildScrollView: scrollDirection:"Axis.vertical|horizontal"  padding:<edgeinsets>
GridView:              crossAxisCount:<number>  mainAxisSpacing:<number>  crossAxisSpacing:<number>  childAspectRatio:<number>
Positioned:            top:<number>  bottom:<number>  left:<number>  right:<number>  width:<number>  height:<number>
Divider:               color:<color>  thickness:<number>  height:<number>
SizedBox:              width:<number>  height:<number>
Expanded:              flex:<number>
Flexible:              flex:<number>  fit:"loose|tight"
FittedBox:             fit:<boxFit>  alignment:"Alignment.center|topLeft|topRight|..."
Padding:               padding:<edgeinsets>
Row|Column:            mainAxisAlignment:<mainAxis>  crossAxisAlignment:<crossAxis>  mainAxisSize:"MainAxisSize.min|max"

[ACTIONS]
Interactive widgets can contain actions under properties.
- "navigateTo": String (ID of the target screen, or "__back__" to pop back).
- "actions": List of Action Objects:
  1. Navigate: {"type": "navigate", "targetScreenId": "<screen_id>"}
  2. Supabase Insert: {"type": "supabase_insert", "tableName": "<table_name>", "payload": {"<column>": {"type": "widget_state|query_data|static", "value": "<input_widget_id_or_field_name>"}}}
  3. Supabase Update: {"type": "supabase_update", "tableName": "<table_name>", "payload": {"<column>": {"type": "widget_state|query_data|static", "value": "<input_widget_id_or_field_name>"}}}
  4. Supabase Delete: {"type": "supabase_delete", "tableName": "<table_name>"}

[DATA BINDING]
Widgets inside dynamic database lists can bind properties to query columns under properties:
- "dataBinding": {"title": {"field": "<column>"}, "subtitle": {"field": "<column>"}}

[CRITICAL RULES]
1. BottomNavigationBar MUST be in Scaffold "bottomNavigationBar" property — NEVER in children.
2. AppBar MUST be in Scaffold "appBar" property — NEVER in children.
3. FloatingActionButton MUST be in Scaffold "floatingActionButton" property — NEVER in children.
4. BottomNavigationBar "type" = "fixed" — NOT "BottomNavigationBarType.fixed".
5. Every node MUST have all four keys: "id", "type", "properties", "children".
6. Colors MUST be AARRGGBB integer strings — never hex, never named colors.
7. Do NOT use widget types outside [WIDGET LIST].
8. For long screens wrap Column in SingleChildScrollView as the Scaffold body.
9. AppBar "title" is a nested Text node object, not a plain string.
10. You MUST wrap your JSON output in a standard Markdown code block (```json ... ```). Do not include any other text.
11. CRITICAL: DO NOT manually minify the JSON. Use standard indentation. Forced minification causes syntax errors. 
12. CRITICAL: LIMIT your output to a MAXIMUM of 3 core screens. Do not generate overly repetitive lists or deeply nested unnecessary hierarchies.
13. CRITICAL SYNTAX RULE: Every child node MUST be placed INSIDE the "children": [...] array. NEVER place a child object directly after "properties": {...}. The only allowed keys in a node are "id", "type", "properties", and "children".
14. CRITICAL SYNTAX RULE: Ensure all string values are properly closed with double quotes, and all keys are properly quoted.
''';

    final List<Map<String, dynamic>> contextMessages = [];
    contextMessages.add({'role': 'system', 'content': systemPrompt});
    
    for (var msg in previousMessages) {
      contextMessages.add({
        'role': msg['role'] == 'user' ? 'user' : 'assistant',
        'content': msg['content'],
      });
    }

    String finalPrompt = prompt;
    if (currentJson != null) {
      finalPrompt = 'CURRENT JSON STATE:\n$currentJson\n\nUSER REQUEST: $prompt';
    }

    if (retryCount > 0 && lastError != null) {
      finalPrompt = 'REPAIR ATTEMPT $retryCount.\nERROR: $lastError\n\nUSER REQUEST: $prompt';
    }

    contextMessages.add({'role': 'user', 'content': finalPrompt});

    final Map<String, dynamic> body = {
      'model': model,
      'messages': contextMessages,
      'temperature': 0.2,
      'max_tokens': 8192,
    };

    // OpenRouter/Kimi and some OpenAI models may have issues with structured-outputs.
    // Apply it specifically for DeepSeek as requested.
    if (agentType == AiAgentType.deepseek || agentType == AiAgentType.gemini) {
      body['response_format'] = {'type': 'json_object'};
    }

    // DeepSeek V4 defaults to thinking mode (extra reasoning tokens → much slower).
    if (agentType == AiAgentType.deepseek) {
      body['thinking'] = {'type': 'disabled'};
    }

    // Validate API key before making request
    if (apiKey.isEmpty) {
      throw Exception('API key is required for ${agentType.nameString} agent.');
    }

    print('🛠️ Using agent: $agentType');
    print('🔑 API Key provided: ${apiKey.isNotEmpty ? '******' : 'EMPTY'}');

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body));

    if (response.statusCode == 401) {
      // Authentication failure – provide clear guidance
      throw Exception('401 Unauthorized: Invalid API key for ${agentType.nameString}. Please verify your key in the AI Prompt dialog.');
    }

      if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      String content = jsonResponse['choices'][0]['message']['content'];
      print('🔍 RAW AI OUTPUT:\n$content');
      
      // We must repair the JSON BEFORE attempting to parse it!
      content = repairJson(content);
      
      List<WidgetNode> generatedScreens = [];
      
      try {
        final dynamic parsedJson = jsonDecode(content);
        
        if (parsedJson is Map<String, dynamic> && parsedJson.containsKey('screens')) {
          final screensList = parsedJson['screens'] as List;
          for (var screenData in screensList) {
            final rootNodeData = screenData['rootWidget'];
            if (rootNodeData != null) {
              final node = WidgetNode.fromJson(rootNodeData);
              if (screenData['name'] != null) {
                node.properties['pageName'] = screenData['name'];
              }
              _ensureUniqueIds(node, <String>{});
              generatedScreens.add(node);
            }
          }
          if (generatedScreens.isNotEmpty) return generatedScreens;
        }
        
        // Fallback for single node returned
        if (parsedJson is Map<String, dynamic> && parsedJson.containsKey('type')) {
          final node = WidgetNode.fromJson(parsedJson);
          _ensureUniqueIds(node, <String>{});
          return [node];
        } else if (parsedJson is List && parsedJson.isNotEmpty) {
          final node = WidgetNode.fromJson(parsedJson.first);
          _ensureUniqueIds(node, <String>{});
          return [node];
        }
        throw Exception('Unexpected JSON format returned by AI. Missing "screens" array or valid root widget.');
      } catch (e) {
        if (retryCount < 1) {
          print('JSON Parse Failed. Triggering Self-Repair Loop. Error: $e');
          return generateUi(
            prompt: prompt,
            apiKey: apiKey,
            agentType: agentType,
            currentJson: currentJson,
            previousMessages: previousMessages,
            retryCount: retryCount + 1,
            lastError: e.toString(),
          );
        }
        rethrow;
      }
    } else {
      throw Exception('AI Generation failed: ${response.statusCode} - ${response.body}');
    }
  }

  static void _ensureUniqueIds(WidgetNode node, Set<String> existingIds) {
    if (existingIds.contains(node.id)) {
      node.id = '${node.id}_${DateTime.now().millisecondsSinceEpoch}_${existingIds.length}';
    }
    existingIds.add(node.id);
    for (var child in node.children) {
      _ensureUniqueIds(child, existingIds);
    }
  }

  static String repairJson(String json) {
    int firstBrace = json.indexOf('{');
    int lastBrace = json.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      json = json.substring(firstBrace, lastBrace + 1);
    } else {
      int firstBracket = json.indexOf('[');
      int lastBracket = json.lastIndexOf(']');
      if (firstBracket != -1 && lastBracket != -1 && lastBracket > firstBracket) {
        json = json.substring(firstBracket, lastBracket + 1);
      }
    }

    json = json.replaceAll('```json', '').replaceAll('```', '').trim();

    // Removed global newline escaping as it breaks formatted JSON outside of strings
    // JSON parsers natively support whitespace newlines.
    json = json.replaceAll('\r', '');
    // Fix Kimi-specific structural errors
    json = json.replaceAll('":"":"', '":"'); // fixes "type":"":"BottomNavigationBar" -> "type":"BottomNavigationBar"
    json = json.replaceAll('type":"":', 'type":');
    
    json = json.replaceAllMapped(
      RegExp(r'("icon"\s*:\s*"[^",]+),(\s*"label")'),
      (m) => '${m.group(1)}",${m.group(2)}',
    );
    json = json.replaceAllMapped(
      RegExp(r'("icon"\s*:\s*"[^",]+),(\s*"navigateTo")'),
      (m) => '${m.group(1)}",${m.group(2)}',
    );
    
    // Fix missing leading quote on properties like `,color":"` -> `,"color":"`
    json = json.replaceAllMapped(
      RegExp(r',([a-zA-Z0-9_]+)":'),
      (m) => ',"${m.group(1)}":',
    );
    // Fix double open brace like `"properties":{"{` -> `"properties":{`
    json = json.replaceAll('":{"{', '":{');

    json = json.replaceAllMapped(RegExp("'([^']*)'"), (m) => '"${m.group(1)}"');

    json = json.replaceAllMapped(RegExp(r'"\s+("[^\"]+"\s*:)'), (match) {
      return '", ${match.group(1)}';
    });
    json = json.replaceAllMapped(RegExp(r'(\d+|true|false|null)\s+("[^\"]+"\s*:)'), (match) {
      return '${match.group(1)}, ${match.group(2)}';
    });

    json = _escapeUnescapedQuotes(json);

    json = json.replaceAll(RegExp(r',\s*}'), '}');
    json = json.replaceAll(RegExp(r',\s*\]'), ']');

    // Insert missing commas between adjacent JSON objects or arrays
    json = json.replaceAll(RegExp(r'}\s*{'), '},{');
    json = json.replaceAll(RegExp(r'\]\s*\{'), '],{');
    json = json.replaceAll(RegExp(r'}\s*\['), '},{');

    json = json.replaceAllMapped(RegExp(r'\\([^"\\/bfnrtu])'), (match) {
      return '\\\\${match.group(1)}';
    });

    return json;
  }

  static String _escapeUnescapedQuotes(String json) {
    final int len = json.length;
    final StringBuffer result = StringBuffer();
    bool inString = false;
    
    for (int i = 0; i < len; i++) {
      final String c = json[i];
      
      if (!inString) {
        if (c == '"') {
          inString = true;
          result.write(c);
        } else {
          result.write(c);
        }
      } else {
        if (c == '\\') {
          result.write(c);
          if (i + 1 < len) {
            result.write(json[i + 1]);
            i++;
          }
        } else if (c == '"') {
          // Look ahead to find the next non-whitespace character
          int nextIdx = i + 1;
          while (nextIdx < len && _isWhitespace(json[nextIdx])) {
            nextIdx++;
          }
          
          if (nextIdx < len) {
            final String nextChar = json[nextIdx];
            // Valid delimiters that can follow a closing quote of a string in JSON:
            // - ':' (if it was a key)
            // - ',' (if it is followed by next property or item)
            // - '}' (end of object)
            // - ']' (end of array)
            if (nextChar == ':' || nextChar == ',' || nextChar == '}' || nextChar == ']') {
              inString = false;
              result.write(c);
            } else {
              // It's an unescaped quote inside the string! Escape it.
              result.write('\\"');
            }
          } else {
            // End of JSON reached, this quote closes the string
            inString = false;
            result.write(c);
          }
        } else {
          result.write(c);
        }
      }
    }
    
    return result.toString();
  }

  static bool _isWhitespace(String char) {
    return char == ' ' || char == '\t' || char == '\n' || char == '\r';
  }
}
