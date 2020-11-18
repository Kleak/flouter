import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flouter/flouter.dart';

class TestBed extends StatelessWidget {
  final RouterDelegate routerDelegate;

  const TestBed({Key key, this.routerDelegate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: routerDelegate,
      routeInformationParser: UriRouteInformationParser(),
    );
  }
}

void main() {
  group('UriRouterDelegate', () {
    testWidgets('default', (tester) async {
      final pageKey = ValueKey('home-page');

      final flouter = UriRouterDelegate(
        pages: {
          RegExp(r'^/$'): (flouterInformations) => MaterialPage(
                child: Scaffold(
                  key: pageKey,
                  body: Center(
                    child: Text('Home'),
                  ),
                ),
              ),
        },
      );

      await tester.pumpWidget(TestBed(routerDelegate: flouter));

      expect(find.byKey(pageKey), findsOneWidget);
    });

    testWidgets('with initial route', (tester) async {
      final pageKey = ValueKey('only-one-page');

      final flouter = UriRouterDelegate(
        initialUris: [
          Uri.parse('/should_be_the_only_one'),
        ],
        pages: {
          RegExp(r'^/should_be_the_only_one$'): (flouterInformations) => MaterialPage(
                child: Scaffold(
                  key: pageKey,
                  body: Center(
                    child: Text('Home'),
                  ),
                ),
              ),
        },
      );

      await tester.pumpWidget(TestBed(routerDelegate: flouter));

      expect(find.byKey(pageKey), findsOneWidget);
    });

    testWidgets('initial route not found', (tester) async {
      final pageKey = ValueKey('not-found');

      final flouter = UriRouterDelegate(
        initialUris: [
          Uri.parse('/not_found'),
        ],
        pages: {
          RegExp(r'^/should_be_the_only_one$'): (flouterInformations) => MaterialPage(
                child: Scaffold(
                  body: Center(
                    child: Text('Home'),
                  ),
                ),
              ),
        },
        pageNotFound: (flouterInformations) => MaterialPage(
          child: Scaffold(
            key: pageKey,
            body: Text('Not found'),
          ),
        ),
      );

      await tester.pumpWidget(TestBed(routerDelegate: flouter));

      expect(find.byKey(pageKey), findsOneWidget);
    });

    testWidgets('push/pop route', (tester) async {
      final page1Key = ValueKey('page-1');
      final page2Key = ValueKey('page-2');

      final flouter = UriRouterDelegate(
        initialUris: [
          Uri.parse('/'),
        ],
        pages: {
          RegExp(r'^/$'): (flouterInformations) => MaterialPage(
                child: Scaffold(
                  body: Center(
                    child: Text('Home'),
                  ),
                ),
              ),
          RegExp(r'^/page/(1)$'): (flouterInformations) => MaterialPage(
                child: Scaffold(
                  key: page1Key,
                  body: Center(
                    child: Text('Page ${flouterInformations.match.group(1)}'),
                  ),
                ),
              ),
          RegExp(r'^/page/(2)$'): (flouterInformations) => MaterialPage(
                child: Scaffold(
                  key: page2Key,
                  body: Center(
                    child: Text('Page ${flouterInformations.match.group(1)}'),
                  ),
                ),
              ),
        },
      );

      await tester.pumpWidget(TestBed(routerDelegate: flouter));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Page 2'), findsNothing);

      await flouter.setNewRoutePath(Uri.parse('/page/1'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsNothing);
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsNothing);

      await flouter.setNewRoutePath(Uri.parse('/page/2'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsNothing);
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Page 2'), findsOneWidget);

      await flouter.setNewRoutePath(Uri.parse('/'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Page 2'), findsNothing);
    });
  });
}
