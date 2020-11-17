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
    initialPage: (_, pushNewRoute) => HomePage(pushNewRoute),
    pages: {
      RegExp(r'^/$'): (_, pushNewRoute) => HomePage(pushNewRoute),
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

class HomePage extends Page {
  final PushNewRoute pushNewRoute;

  HomePage(this.pushNewRoute) : super(key: ValueKey('home-page'));

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, _, __) {
        return Home(
          pushNewRoute: pushNewRoute,
        );
      },
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
            TextButton(
              onPressed: () {
                pushNewRoute(Uri(path: '/test/toto/'));
              },
              child: Text('Test toto'),
            ),
            TextButton(
              onPressed: () {
                pushNewRoute(Uri(path: '/test/12345/'));
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
