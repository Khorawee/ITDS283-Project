/// lib/providers/quiz_provider.dart
/// Riverpod state management for quiz functionality
///
/// Providers:
/// - quizzesProvider: Paginated quiz list
/// - quizDetailProvider: Single quiz detail with questions
/// - quizSubmissionProvider: Handle quiz submission state

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for paginated quizzes
class QuizzesState {
  final List<dynamic> quizzes;
  final int page;
  final int totalPages;
  final bool isLoading;
  final String? error;

  QuizzesState({
    this.quizzes = const [],
    this.page = 1,
    this.totalPages = 0,
    this.isLoading = false,
    this.error,
  });

  QuizzesState copyWith({
    List<dynamic>? quizzes,
    int? page,
    int? totalPages,
    bool? isLoading,
    String? error,
  }) {
    return QuizzesState(
      quizzes: quizzes ?? this.quizzes,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for quiz list with pagination
final quizzesProvider = StateNotifierProvider<
    QuizzesNotifier,
    QuizzesState>((ref) => QuizzesNotifier());

class QuizzesNotifier extends StateNotifier<QuizzesState> {
  QuizzesNotifier() : super(QuizzesState());

  /// Load quizzes for specific page
  Future<void> loadPage(int page) async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Call QuizService.getQuizzesPage(page)
      // final result = await QuizService.getQuizzesPage(page: page, limit: 20);
      // state = state.copyWith(
      //   quizzes: result['quizzes'],
      //   page: page,
      //   totalPages: result['pagination']['total_pages'],
      //   isLoading: false,
      //   error: null,
      // );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load quizzes: $e',
      );
    }
  }

  /// Load more quizzes (infinite scroll)
  Future<void> loadMore() async {
    if (state.page >= state.totalPages) return;
    await loadPage(state.page + 1);
  }

  /// Refresh quiz list
  Future<void> refresh() async {
    await loadPage(1);
  }
}

/// Provider for single quiz detail
class QuizDetailState {
  final dynamic quiz;
  final bool isLoading;
  final String? error;

  QuizDetailState({
    this.quiz,
    this.isLoading = false,
    this.error,
  });

  QuizDetailState copyWith({
    dynamic quiz,
    bool? isLoading,
    String? error,
  }) {
    return QuizDetailState(
      quiz: quiz ?? this.quiz,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Family provider for quiz detail by ID
final quizDetailProvider = StateNotifierProvider.family<
    QuizDetailNotifier,
    QuizDetailState,
    int>((ref, quizId) => QuizDetailNotifier(quizId));

class QuizDetailNotifier extends StateNotifier<QuizDetailState> {
  final int quizId;

  QuizDetailNotifier(this.quizId) : super(QuizDetailState()) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Call QuizService.getQuizDetail(quizId)
      // final quiz = await QuizService.getQuizDetail(quizId);
      // state = state.copyWith(
      //   quiz: quiz,
      //   isLoading: false,
      //   error: null,
      // );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load quiz: $e',
      );
    }
  }
}

/// State for quiz submission
class QuizSubmissionState {
  final bool isSubmitting;
  final bool success;
  final String? error;
  final Map<String, dynamic>? result;

  QuizSubmissionState({
    this.isSubmitting = false,
    this.success = false,
    this.error,
    this.result,
  });

  QuizSubmissionState copyWith({
    bool? isSubmitting,
    bool? success,
    String? error,
    Map<String, dynamic>? result,
  }) {
    return QuizSubmissionState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      success: success ?? this.success,
      error: error,
      result: result ?? this.result,
    );
  }
}

/// Provider for quiz submission
final quizSubmissionProvider = StateNotifierProvider<
    QuizSubmissionNotifier,
    QuizSubmissionState>((ref) => QuizSubmissionNotifier());

class QuizSubmissionNotifier extends StateNotifier<QuizSubmissionState> {
  QuizSubmissionNotifier() : super(QuizSubmissionState());

  /// Submit quiz answers
  Future<void> submitAnswers({
    required int quizId,
    required int timeSpent,
    required List<Map<String, dynamic>> answers,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      // TODO: Call QuizService.submitQuiz()
      // final result = await QuizService.submitQuiz(
      //   quizId: quizId,
      //   timeSpent: timeSpent,
      //   answers: answers,
      // );
      // state = state.copyWith(
      //   isSubmitting: false,
      //   success: true,
      //   result: result,
      // );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit quiz: $e',
      );
    }
  }

  /// Reset submission state
  void reset() {
    state = QuizSubmissionState();
  }
}
