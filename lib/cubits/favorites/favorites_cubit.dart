import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'favorites_state.dart';

/// Persists favorite product IDs locally with Hive so they survive
/// app restarts. Loads saved data as soon as the cubit is created,
/// before the UI depends on it (see [_loadFromHive] called in the
/// constructor).
class FavoritesCubit extends Cubit<FavoritesState> {
  static const String boxName = 'favoritesBox';
  static const String idsKey = 'favoriteIds';

  final Box _box;

  FavoritesCubit(this._box) : super(const FavoritesState()) {
    _loadFromHive();
  }

  void _loadFromHive() {
    final stored = _box.get(idsKey, defaultValue: <dynamic>[]) as List<dynamic>;
    final ids = stored.map((e) => e as int).toSet();
    emit(state.copyWith(favoriteIds: ids, isLoaded: true));
  }

  Future<void> toggleFavorite(int productId) async {
    final updated = Set<int>.from(state.favoriteIds);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    emit(state.copyWith(favoriteIds: updated));
    await _box.put(idsKey, updated.toList());
  }

  bool isFavorite(int productId) => state.favoriteIds.contains(productId);
}
