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
    pageNotFound: (flouterInformation) => MaterialPage(
      key: ValueKey('not-found-page'),
      child: Scaffold(
        body: Center(
          child: Text('Page ${flouterInformation.uri.path} not found'),
        ),
      ),
    ),
    pages: {
      RegExp(r'^/$'): (flouterInformation) => HomePage(flouterInformation.pushNewUri),
      RegExp(r'^/test/([a-z]+)/$'): (flouterInformation) => TestPage(flouterInformation),
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
  final PushNewUri pushNewUri;

  HomePage(this.pushNewUri) : super(key: ValueKey('home-page'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        return Home(
          pushNewUri: pushNewUri,
        );
      },
    );
  }
}

class Home extends StatelessWidget {
  final PushNewUri pushNewUri;

  const Home({Key key, @required this.pushNewUri}) : super(key: key);

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
                pushNewUri(Uri(path: '/test/toto/', queryParameters: {'limit': '12'}));
              },
              child: Text('Test toto'),
            ),
            TextButton(
              onPressed: () {
                pushNewUri(Uri(path: '/test/12345/'));
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
  final FlouterInformation flouterInformations;
  TestPage(this.flouterInformations)
      : super(key: ValueKey('${flouterInformations.uri.path}-page'), name: flouterInformations.uri.path);

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) {
        return Test(
          uri: Uri(path: name),
          userId: flouterInformations.match.group(1),
          limit: int.tryParse(flouterInformations.uri.queryParameters['limit'] ?? '-1') ?? -1,
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
