import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/gemini_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/chat_message.dart';

abstract interface class GeminiRemoteDataSource {
  /// Streams text token chunks from Gemini API via SSE
  Stream<String> streamGenerateContent(
    String prompt, {
    List<ChatMessage> history = const [],
    String? model,
  });

  /// Non-streaming complete content generation
  Future<String> generateContent(
    String prompt, {
    List<ChatMessage> history = const [],
    String? model,
  });
}

class GeminiRemoteDataSourceImpl implements GeminiRemoteDataSource {
  final http.Client _client;
  final String _apiKey;

  GeminiRemoteDataSourceImpl({
    http.Client? client,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? GeminiConfig.defaultApiKey;

  Map<String, dynamic> _buildRequestBody(
    String prompt,
    List<ChatMessage> history,
  ) {
    final contents = <Map<String, dynamic>>[];

    for (final msg in history) {
      if (msg.content.trim().isNotEmpty) {
        contents.add({
          'role': msg.isUser ? 'user' : 'model',
          'parts': [
            {'text': msg.content},
          ],
        });
      }
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': prompt},
      ],
    });

    return {
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {'text': GeminiConfig.systemInstruction},
        ],
      },
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
    };
  }

  @override
  Stream<String> streamGenerateContent(
    String prompt, {
    List<ChatMessage> history = const [],
    String? model,
  }) async* {
    final targetModel = model ?? GeminiConfig.primaryModel;
    final url = Uri.parse(GeminiConfig.streamUrl(targetModel, _apiKey));
    final body = jsonEncode(_buildRequestBody(prompt, history));

    http.StreamedResponse response;
    try {
      final request = http.Request('POST', url)
        ..headers.addAll({
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'text/event-stream',
        })
        ..body = body;

      response = await _client.send(request);
    } catch (e) {
      throw NetworkException(message: 'Network connection failed: $e');
    }

    if (response.statusCode != 200) {
      final errBody = await response.stream.bytesToString();
      // If 404 or model not found, try fallback models
      if (response.statusCode == 404 || errBody.contains('not found')) {
        for (final fallback in GeminiConfig.fallbackModels) {
          if (fallback != targetModel) {
            yield* streamGenerateContent(
              prompt,
              history: history,
              model: fallback,
            );
            return;
          }
        }
      }
      throw ServerException(
        message: 'Gemini API error [${response.statusCode}]: $errBody',
        statusCode: response.statusCode,
      );
    }

    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('data: ')) {
        final dataStr = trimmed.substring(6).trim();
        if (dataStr == '[DONE]') break;

        try {
          final jsonMap = jsonDecode(dataStr) as Map<String, dynamic>;
          final text = _extractTextFromChunk(jsonMap);
          if (text != null && text.isNotEmpty) {
            yield text;
          }
        } catch (_) {
          // Continue parsing remaining stream lines
        }
      }
    }
  }

  @override
  Future<String> generateContent(
    String prompt, {
    List<ChatMessage> history = const [],
    String? model,
  }) async {
    final targetModel = model ?? GeminiConfig.primaryModel;
    final url = Uri.parse(GeminiConfig.generateUrl(targetModel, _apiKey));
    final body = jsonEncode(_buildRequestBody(prompt, history));

    http.Response response;
    try {
      response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: body,
      );
    } catch (e) {
      throw NetworkException(message: 'Network connection failed: $e');
    }

    if (response.statusCode != 200) {
      if (response.statusCode == 404 || response.body.contains('not found')) {
        for (final fallback in GeminiConfig.fallbackModels) {
          if (fallback != targetModel) {
            return generateContent(prompt, history: history, model: fallback);
          }
        }
      }
      throw ServerException(
        message: 'Gemini API error [${response.statusCode}]: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    final text = _extractTextFromChunk(jsonMap);
    if (text == null || text.isEmpty) {
      throw const ServerException(message: 'No response text returned by Gemini');
    }
    return text;
  }

  String? _extractTextFromChunk(Map<String, dynamic> json) {
    try {
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return null;

      final firstCandidate = candidates.first as Map<String, dynamic>;
      final content = firstCandidate['content'] as Map<String, dynamic>?;
      if (content == null) return null;

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) return null;

      final buffer = StringBuffer();
      for (final part in parts) {
        if (part is Map<String, dynamic> && part.containsKey('text')) {
          buffer.write(part['text'] as String);
        }
      }
      return buffer.toString();
    } catch (_) {
      return null;
    }
  }
}
