A Navigator 2.0 router for Flutter


Easy to use router library that do all the work for you !

#   Easy

First create a MaterialApp.router :

```dart
return MaterialApp.router(
    title: 'Uri navigator App',
    routerDelegate: _routerDelegate,
    routeInformationParser: UriRouteInformationParser(),
);
```

Second initialize your _routerDelegate like this :
```dart
final _routerDelegate = UriRouterDelegate(
    pageNotFound: (routeInformation) => MaterialPage(
        key: ValueKey('not-found-page'),
        child: Scaffold(
        body: Center(
            child: Text('Page ${routeInformation.uri.path} not found'),
        ),
        ),
    ),
    initialUris: [
        Uri.parse('/'),
        Uri.parse('/test/titi/'),
    ],
    pages: {
        RegExp(r'^/$'): (_) => HomePage(),
        RegExp(r'^/test/([a-z]+)/$'): (routeInformation) => TestPage(routeInformation),
    },
);
```

That's all you have to do ;)