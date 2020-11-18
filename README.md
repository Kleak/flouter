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
    pageNotFound: (flouterInformations) => MaterialPage(
        key: ValueKey('not-found-page'),
        child: Scaffold(
        body: Center(
            child: Text('Page ${flouterInformations.uri.path} not found'),
        ),
        ),
    ),
    initialPage: (flouterInformations) => HomePage(flouterInformations.push),
    pages: {
        RegExp(r'^/$'): (flouterInformations) => HomePage(flouterInformations.push),
        RegExp(r'^/test/([a-z]+)/$'): (flouterInformations) => TestPage(flouterInformations),
    },
);
```

That's all you have to do ;)