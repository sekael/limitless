import 'package:limitless_flutter/features/quotes/data/repository.dart';
import 'package:limitless_flutter/features/quotes/domain/quote.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuotesRepositoryAdapter implements QuotesRepository {
  final SupabaseClient _client;
  QuotesRepositoryAdapter(this._client);

  @override
  Future<List<Quote>> getAll() async {
    final rows = await _client
        .from('motivational_quotes')
        .select('*')
        .order('id');

    print("Repository adapter retrieved quotes from Supabase");
    return rows.map(Quote.fromMap).toList();
  }
}
