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
    pageNotFound: (uri, _) => MaterialPage(
      key: ValueKey('not-found-page'),
      child: Scaffold(
        body: Center(
          child: Text('Page ${uri.path} not found'),
        ),
      ),
    ),
    initialPage: MaterialPage(
      key: ValueKey('initial-page'),
      child: Scaffold(
        body: Center(
          child: Text('Initial page'),
        ),
      ),
    ),
    pages: {
      RegExp(r'^/$'): (_, pushNewRoute) =>
          MaterialPage(key: ValueKey('home-page'), child: Home(pushNewRoute: pushNewRoute)),
      RegExp(r'^/test/[a-z]+/$'): (uri, pushNewRoute) => TestPage(uri.path),
    },
  );

  final _routeInformationParser = UriRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Uri navigator App',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class Home extends StatelessWidget {
  final PushNewRoute pushNewRoute;

  const Home({Key key, @required this.pushNewRoute}) : super(key: key);

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
            FlatButton(
              onPressed: () {
                pushNewRoute(Uri(path: '/test/1234/'));
              },
              child: Text('Test toto'),
            ),
          ],
        ),
      ),
    );
  }
}

class TestPage extends Page {
  TestPage(String name) : super(key: ValueKey('$name-page'), name: name);

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        return Test(
          uri: Uri(path: name),
        );
      },
    );
  }
}

class Test extends StatelessWidget {
  final Uri uri;

  const Test({Key key, @required this.uri}) : super(key: key);

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
