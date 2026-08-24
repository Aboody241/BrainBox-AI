import 'dart:typed_data';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/gemini_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final GeminiRemoteDataSource _remoteDataSource;

  const ChatRepositoryImpl(this._remoteDataSource);

  @override
  Stream<String> streamMessage(
    String prompt, {
    List<ChatMessage> history = const [],
    Uint8List? imageBytes,
    String? mimeType,
    String? model,
  }) {
    return _remoteDataSource.streamGenerateContent(
      prompt,
      history: history,
      imageBytes: imageBytes,
      mimeType: mimeType,
      model: model,
    );
  }

  @override
  Future<Result<String>> sendMessage(
    String prompt, {
    List<ChatMessage> history = const [],
    Uint8List? imageBytes,
    String? mimeType,
    String? model,
  }) async {
    try {
      final text = await _remoteDataSource.generateContent(
        prompt,
        history: history,
        imageBytes: imageBytes,
        mimeType: mimeType,
        model: model,
      );
      return Result.success(text);
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
