import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/widget_node.dart';

enum AiAgentType {
  openai,
  deepseek,
}

class AiGenerationService {
  static const String _openAiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _deepseekEndpoint = 'https://api.deepseek.com/chat/completions';

  static Future<List<WidgetNode>> generateUi({
    required String prompt,
    required String apiKey,
    required AiAgentType agentType,
    String? currentJson,
    List<Map<String, String>> previousMessages = const [],
    int retryCount = 0,
    String? lastError,
  }) async {
    final String endpoint = agentType == AiAgentType.openai ? _openAiEndpoint : _deepseekEndpoint;
    final String model =
        agentType == AiAgentType.openai ? 'gpt-4o' : 'deepseek-v4-flash';

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
Icon / IconButton:     icon:<icon>  color:<color>  size:<number>
CircleAvatar:          backgroundColor:<color>  radius:<number>  imageUrl:<url>
Card:                  elevation:<number>  color:<color>  borderRadius:<number>  margin:<edgeinsets>
ElevatedButton|TextButton|OutlinedButton|MaterialButton: text:"..."  backgroundColor:<color>  foregroundColor:<color>  width:<number>  height:<number>  borderRadius:<number>
TextField:             hintText:"..."  labelText:"..."  filled:bool  fillColor:<color>  prefixIcon:<icon>  suffixIcon:<icon>  obscureText:bool  border:"OutlineInputBorder|none"
ListView|SingleChildScrollView: scrollDirection:"Axis.vertical|horizontal"  padding:<edgeinsets>
GridView:              crossAxisCount:<number>  mainAxisSpacing:<number>  crossAxisSpacing:<number>  childAspectRatio:<number>
Positioned:            top:<number>  bottom:<number>  left:<number>  right:<number>  width:<number>  height:<number>
Divider:               color:<color>  thickness:<number>  height:<number>
SizedBox:              width:<number>  height:<number>
Expanded|Flexible:     flex:<number>
Padding:               padding:<edgeinsets>
Row|Column:            mainAxisAlignment:<mainAxis>  crossAxisAlignment:<crossAxis>  mainAxisSize:"MainAxisSize.min|max"

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
10. OUTPUT RAW JSON ONLY — no markdown, no code fences, no text before or after.
11. CRITICAL: Your JSON MUST BE COMPLETELY MINIFIED. Do NOT use newlines, indentation, or spaces for formatting. Every token counts.
12. CRITICAL: LIMIT your output to a MAXIMUM of 3 core screens. Do not generate overly repetitive lists or deeply nested unnecessary hierarchies.
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
      // OpenAI + DeepSeek V4 — valid JSON object, fewer markdown / repair retries.
      'response_format': {'type': 'json_object'},
    };

    // DeepSeek V4 defaults to thinking mode (extra reasoning tokens → much slower).
    if (agentType == AiAgentType.deepseek) {
      body['thinking'] = {'type': 'disabled'};
    }

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body));


    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      String content = jsonResponse['choices'][0]['message']['content'];
      
      // Clean up markdown markers if the AI ignored the instruction
      content = content.replaceAll('```json', '').replaceAll('```', '').trim();
      
      // Fix invalid JSON escape sequences generated by LLMs.
      // JSON only allows escaping: ", \, /, b, f, n, r, t, u
      // Any backslash followed by a character NOT in this list is an invalid escape.
      content = content.replaceAllMapped(RegExp(r'\\([^"\\/bfnrtu])'), (match) {
        return match.group(1)!;
      });
      
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
}
