import 'dart:convert';
import 'dart:typed_data';

import 'package:brain_box_ai/core/config/gemini_config.dart';
import 'package:brain_box_ai/features/chat/data/datasources/gemini_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GeminiRemoteDataSource Unit Tests', () {
    test('generateContent returns text on successful 200 response', () async {
      final mockClient = MockClient((request) async {
        final responseJson = jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Hello! How can I assist you with BrainBox AI today?'}
                ]
              }
            }
          ]
        });
        return http.Response(responseJson, 200,
            headers: {'content-type': 'application/json'});
      });

      final dataSource = GeminiRemoteDataSourceImpl(
        client: mockClient,
        apiKey: GeminiConfig.defaultApiKey,
      );

      final result = await dataSource.generateContent('Hi');
      expect(result, 'Hello! How can I assist you with BrainBox AI today?');
    });

    test('generateContent correctly formats inlineData for imageBytes payload',
        () async {
      final fakeBytes = Uint8List.fromList([10, 20, 30, 40]);
      late String capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = request.body;
        final responseJson = jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'I see an image with 4 bytes.'}
                ]
              }
            }
          ]
        });
        return http.Response(responseJson, 200,
            headers: {'content-type': 'application/json'});
      });

      final dataSource = GeminiRemoteDataSourceImpl(
        client: mockClient,
        apiKey: GeminiConfig.defaultApiKey,
      );

      final result = await dataSource.generateContent(
        'What is this?',
        imageBytes: fakeBytes,
        mimeType: 'image/jpeg',
      );

      expect(result, 'I see an image with 4 bytes.');
      expect(capturedBody, contains('inlineData'));
      expect(capturedBody, contains(base64Encode(fakeBytes)));
    });

    test('streamGenerateContent yields parsed text chunks from SSE data stream',
        () async {
      final mockClient = MockClient.streaming((request, bodyStream) async {
        final sseData = [
          'data: {"candidates":[{"content":{"parts":[{"text":"Quantum "}]}}]}\n\n',
          'data: {"candidates":[{"content":{"parts":[{"text":"computing "}]}}]}\n\n',
          'data: [DONE]\n\n',
        ];

        final stream = Stream.fromIterable(sseData.map(utf8.encode));
        return http.StreamedResponse(stream, 200);
      });

      final dataSource = GeminiRemoteDataSourceImpl(
        client: mockClient,
        apiKey: GeminiConfig.defaultApiKey,
      );

      final chunks =
          await dataSource.streamGenerateContent('Explain quantum').toList();
      expect(chunks, ['Quantum ', 'computing ']);
    });
  });
}
