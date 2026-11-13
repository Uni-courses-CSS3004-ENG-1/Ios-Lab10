# Lab 10: Cloud Product Explorer & Detail Carousel

Flutter app that loads products from the live REST API
`https://fakestoreapi.com/products` and shows them in a feed and a detail screen.

## Run

```bash
flutter pub get
flutter run
flutter test   # 15 tests: model, service, widget flows
```

## Project structure

```
lib/
├── main.dart                      # MaterialApp + theme
├── models/product.dart            # Product + type-safe fromJson, deepLink
├── services/product_service.dart  # http.get, 10 s timeout, status codes
├── screens/
│   ├── product_list_screen.dart   # Loading / Success / Error + pull-to-refresh
│   └── product_detail_screen.dart # Hero, carousel, badge, sticky Add to Cart
└── widgets/
    ├── photo_carousel.dart        # PageView.builder, "1 / 3", animated dots
    ├── share_link_sheet.dart      # narxoz://store/product/{id} + copy
    ├── error_view.dart            # Offline screen + Retry Connection
    ├── product_tile.dart, rating_stars.dart, network_image_box.dart
```

## Rubric mapping

| Points | Requirement | Implementation |
|---|---|---|
| 2.5 | Model & JSON | `Product.fromJson` reads every number as `num` first (`(json['price'] as num?)?.toDouble()`), so `22` and `22.5` both work. A missing or `null` field gets a default value instead of crashing the app. |
| 2.5 | HTTP & 3 states | `ProductService.fetchProducts()` calls `.timeout(10 s)` inside `try/catch`. It handles **200 / 404 / 5xx** and turns `SocketException`, `TimeoutException`, `ClientException` and `FormatException` into readable messages. The screen moves between `loading → success → error`. `RefreshIndicator` reloads the list. |
| 3.0 | Detail & carousel | `Hero(tag: 'product_image_${product.id}')` on the thumbnail and on carousel page 1. `PageView.builder` shows the photos with a `1 / 3` counter and `AnimatedContainer` dots. The detail screen also has a category badge and the full description. The **Add to Cart** button sits in `bottomNavigationBar`, so it stays visible while you scroll. |
| 2.0 | Share deep link | The share icon opens a `showModalBottomSheet` with `narxoz://store/product/{id}`. The copy button uses `Clipboard.setData`. |

## Live defense: Airplane mode test

1. Turn on **Airplane mode** and launch the app. You see a spinner, then the error screen *"No internet connection…"*.
2. Turn off Airplane mode and tap **Retry Connection**. The feed loads and the app does not restart.
3. With the feed open, turn Airplane mode on again and pull to refresh. The list stays on screen and a SnackBar shows the error.

## Possible defense questions

- **Why `as num` and not `as double`?** JSON has only one number type. `jsonDecode` returns `22` as an `int`, so `as double` throws a cast error. `num` is the parent type of both `int` and `double`.
- **Why does `ProductService` accept an `http.Client`?** It lets the tests pass in a `MockClient` (`package:http/testing.dart`). That simulates 404, 500, offline and timeout without a network connection.
- **Why check `mounted` after `await`?** The user can leave the screen before the request finishes. Calling `setState` on a disposed State throws an exception.
- **Why does Hero need the same tag on both screens?** Flutter matches the two widgets by tag and animates the image between their positions during the route transition.

## Note

The Fake Store API gives one image per product. The carousel shows that image three
times with a different background and zoom on each page. This demonstrates the
gallery UI; it does not mean the API has three photos.
