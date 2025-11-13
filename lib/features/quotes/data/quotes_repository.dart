import 'package:limitless_flutter/features/quotes/domain/quote.dart';

abstract class QuotesRepository {
  Future<List<Quote>> getAll();
}
