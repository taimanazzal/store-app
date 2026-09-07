import 'package:equatable/equatable.dart';

class FavoritesState extends Equatable {
  final Set<int> favoriteIds;
  final bool isLoaded;

  const FavoritesState({this.favoriteIds = const {}, this.isLoaded = false});

  bool isFavorite(int productId) => favoriteIds.contains(productId);

  FavoritesState copyWith({Set<int>? favoriteIds, bool? isLoaded}) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [favoriteIds, isLoaded];
}
