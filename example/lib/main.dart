import 'package:flouter/flouter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  final _routerDelegate = UriRouterDelegate(
    pageNotFound: (routeInformation) => MaterialPage(
      key: ValueKey('not-found-page'),
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Page ${routeInformation.uri.path} not found'),
          ),
        ),
      ),
    ),
    routes: {
      RegExp(r'^/$'): (_) => HomePage(),
      RegExp(r'^/test/([a-z]+)/$'): (routeInformation) => TestPage(routeInformation),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Uri navigator App',
      routerDelegate: _routerDelegate,
      routeInformationParser: UriRouteInformationParser(),
    );
  }
}

class HomePage extends Page {
  HomePage() : super(key: ValueKey('home-page'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        return Home();
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          children: [
            Text('Home'),
            TextButton(
              onPressed: () {
                UriRouteManager.of(context).pushUri(Uri(path: '/test/toto/', queryParameters: {'limit': '12'}));
              },
              child: Text('Test toto'),
            ),
            TextButton(
              onPressed: () {
                UriRouteManager.of(context).pushUri(Uri(path: '/test/12345/'));
              },
              child: Text('Test 12345'),
            ),
          ],
        ),
      ),
    );
  }
}

class TestPage extends Page {
  final FlouterRouteInformation routeInformation;

  TestPage(this.routeInformation) : super(key: UniqueKey());

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        return Test(
          uri: routeInformation.uri,
          userId: routeInformation.match.group(1),
          limit: int.tryParse(routeInformation.uri.queryParameters['limit'] ?? '-1') ?? -1,
        );
      },
    );
  }
}

class Test extends StatelessWidget {
  final Uri uri;
  final String userId;
  final int limit;

  const Test({Key key, @required this.uri, @required this.userId, @required this.limit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          children: [
            Text('test $uri'),
            Text('userId = $userId'),
            Text('limit = $limit'),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
