import 'package:brain_box_ai/core/result/result.dart';
import 'package:brain_box_ai/features/chat/domain/entities/chat_message.dart';
import 'package:brain_box_ai/features/chat/domain/repositories/chat_repository.dart';
import 'package:brain_box_ai/features/chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:brain_box_ai/features/chat/domain/usecases/stream_chat_response_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeChatRepository implements ChatRepository {
  @override
  Stream<String> streamMessage(
    String prompt, {
    List<ChatMessage> history = const [],
    String? model,
  }) async* {
    yield 'Streamed ';
    yield 'response';
  }

  @override
  Future<Result<String>> sendMessage(
    String prompt, {
    List<ChatMessage> history = const [],
    String? model,
  }) async {
    return const Result.success('Complete response');
  }
}

void main() {
  group('Chat UseCases Unit Tests', () {
    late FakeChatRepository repository;

    setUp(() {
      repository = FakeChatRepository();
    });

    test('StreamChatResponseUseCase streams chunks from repository', () async {
      final useCase = StreamChatResponseUseCase(repository);
      final chunks = await useCase('Hello').toList();
      expect(chunks, ['Streamed ', 'response']);
    });

    test('SendChatMessageUseCase returns Success with text', () async {
      final useCase = SendChatMessageUseCase(repository);
      final result = await useCase('Hello');
      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, 'Complete response');
    });
  });
}
