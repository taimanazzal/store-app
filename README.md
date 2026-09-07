# 🛍️ Store App — BLoC/Cubit State Management

A Flutter e-commerce app (product list, details, cart) built with the BLoC/Cubit
pattern, as part of a Flutter training program. Consumes the free
[Fake Store API](https://fakestoreapi.com) (no API key required), with automatic
fallback to local mock data when offline.

## Features

- **Product List** — search bar + grid of product cards (image, title, price)
- **Product Details** — large image, name, price, description, quantity counter
- **Cart** — item list with quantity controls, delete, and computed total
- **Confirmation screen** after checkout
- **Offline-first products**: tries the live API first, silently falls back to
  `assets/products_data.json` if the request fails

## Optional Challenge Parts Implemented

All three optional challenge parts from the task were implemented:

| Part | What it does |
|---|---|
| **Stock limit** | Quantity can never exceed a product's `stock`. The check lives centrally inside `CartCubit` (not just in the UI), so no screen or button can bypass it. Out-of-stock products are dimmed and non-tappable. |
| **Favorites (Hive)** | `FavoritesCubit` stores favorited product IDs in a local Hive box. Saved favorites are loaded as soon as the cubit is created (before the UI depends on it), so they persist across app restarts. |
| **Coupon (multi-cubit interaction)** | `CouponCubit` is fully independent — it only validates a code against the mock coupon list, with no knowledge of the cart. The Cart screen combines `CartCubit`'s and `CouponCubit`'s states to compute subtotal, discount, and final total, without merging the two cubits. |

## Tech Stack

- **Flutter & Dart**
- **[flutter_bloc](https://pub.dev/packages/flutter_bloc)** — Cubit-based state management
- **[equatable](https://pub.dev/packages/equatable)** — value equality for states/models
- **[hive](https://pub.dev/packages/hive) / [hive_flutter](https://pub.dev/packages/hive_flutter)** — local persistence for Favorites
- **[http](https://pub.dev/packages/http)** — Fake Store API client
- **[bloc_test](https://pub.dev/packages/bloc_test) / [mocktail](https://pub.dev/packages/mocktail)** — unit testing Cubits

## Architecture
lib/
├── models/ # Product, Coupon, CartItem
├── services/ # ProductService (API call + local mock fallback)
├── cubits/
│ ├── products/ # ProductsCubit — Initial/Loading/Loaded/Error
│ ├── cart/ # CartCubit — local cart state + centralized stock checks
│ ├── favorites/ # FavoritesCubit — persisted via Hive
│ └── coupon/ # CouponCubit — independent coupon validation
├── screens/ # ProductListScreen, ProductDetailsScreen, CartScreen, ConfirmationScreen
└── widgets/ # ProductCard


## Cubit Responsibilities

- **`ProductsCubit`** — fetches products, exposes `Initial / Loading / Loaded / Error`
  states, and filters the loaded list locally via `search()` (no extra API calls).
- **`CartCubit`** — pure local state (`List<CartItem>`). All stock-limit validation
  happens here (`addItem` / `updateQuantity` clamp to `product.stock`), so quantity
  can never be pushed past what's available no matter which screen calls in.
- **`FavoritesCubit`** — wraps a `Set<int>` of favorite product IDs, persisted to a
  Hive box on every toggle, and reloaded from Hive in the constructor.
- **`CouponCubit`** — validates a code against `ProductService.fetchCoupons()` and
  emits `Initial / Validating / Applied / Error`. The Cart screen reads both
  `CartCubit` and `CouponCubit` via `BlocBuilder`s to compute the final total.

## Screens Flow 
Product List --(tap card)--> Product Details --(add to cart)--> back to Product List
Product List --(cart icon)--> Cart Screen --(checkout)--> Confirmation

## Testing

Unit tests cover the core business logic with `bloc_test` + `mocktail`:

- `test/cubits/products_cubit_test.dart` — Loading/Loaded/Error transitions and
  search filtering, with `ProductService` mocked (no real network calls).
- `test/cubits/cart_cubit_test.dart` — add/remove/update/clear operations, and
  specifically the **stock-limit clamping logic** (adding more than available
  stock, combining quantities, out-of-stock products).

```bash
flutter test
```

## Getting Started

```bash
flutter pub get
flutter emulators --launch Pixel_7_Pro                 
flutter devices
flutter run
```

## Notes

- The Fake Store API's write operations (`POST`/`PUT`/`DELETE`) are not real and
  don't persist — the cart is intentionally 100% local state in `CartCubit`.
- The real API has no `stock` field, so live-API products default to `stock: 999`
  (effectively unlimited). To test the stock-limit challenge with real limited
  stock, force the local mock data via `loadProducts(forceMock: true)`.
  
