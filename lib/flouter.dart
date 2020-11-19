import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

typedef PushUri = Future<void> Function(Uri);
typedef PushMultipleUri = Future<void> Function(List<Uri>);
typedef ClearAndPushUri = Future<void> Function(Uri);
typedef ClearAndPushMultipleUri = Future<void> Function(List<Uri>);
typedef RemoveLastUri = void Function();
typedef RemoveUri = void Function(Uri);

class FlouterInformation {
  final Uri uri;
  final RegExpMatch match;
  final PushUri pushUri;
  final PushMultipleUri pushMultipleUri;
  final ClearAndPushUri clearAndPushUri;
  final ClearAndPushMultipleUri clearAndPushMultipleUri;
  final RemoveLastUri removeLastUri;
  final RemoveUri removeUri;

  const FlouterInformation({
    @required this.uri,
    this.match,
    @required this.pushUri,
    @required this.pushMultipleUri,
    @required this.clearAndPushUri,
    @required this.clearAndPushMultipleUri,
    @required this.removeLastUri,
    @required this.removeUri,
  });
}

typedef PageBuilder = Page Function(FlouterInformation);

class UriRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async => Uri.parse(routeInformation.location);

  @override
  RouteInformation restoreRouteInformation(Uri uri) => RouteInformation(location: Uri.decodeComponent(uri.toString()));
}

class UriRouterDelegate extends RouterDelegate<Uri> with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final _pages = <Page>[];
  final _uris = <Uri>[];
  final List<Uri> initialUris;
  final Map<RegExp, PageBuilder> pages;
  final PageBuilder pageNotFound;

  bool _skipNext = false;
  bool _shouldUpdate = true;

  UriRouterDelegate({this.initialUris, @required this.pages, this.pageNotFound}) {
    for (final uri in initialUris ?? [Uri(path: '/')]) {
      setNewRoutePath(uri);
    }
    _skipNext = true;
  }

  Uri get currentConfiguration => _uris.isNotEmpty ? _uris.last : null;

  @visibleForTesting
  List<Page> get internalPages => UnmodifiableListView(_pages);

  @visibleForTesting
  List<Uri> get internalUris => UnmodifiableListView(_uris);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        for (final page in _pages) page,
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (_pages.isNotEmpty) {
          removeLastUri();
          return true;
        }

        return false;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(Uri uri) {
    if (_skipNext) {
      _skipNext = false;
      return SynchronousFuture(null);
    }

    bool _findRoute = false;
    for (var i = 0; i < pages.keys.length; i++) {
      final key = pages.keys.elementAt(i);
      if (key.hasMatch(uri.path)) {
        if (_uris.contains(uri)) {
          final position = _uris.indexOf(uri);
          final _urisLengh = _uris.length;
          for (var start = position; start < _urisLengh - 1; start++) {
            _pages.removeLast();
            _uris.removeLast();
          }
          _findRoute = true;
          break;
        }
        final informations = FlouterInformation(
          uri: uri,
          match: key.firstMatch(uri.path),
          pushUri: pushUri,
          pushMultipleUri: pushMultipleUri,
          clearAndPushUri: clearAndPushUri,
          clearAndPushMultipleUri: clearAndPushMultipleUri,
          removeLastUri: removeLastUri,
          removeUri: removeUri,
        );
        _pages.add(pages[key](informations));
        _uris.add(uri);
        _findRoute = true;
        break;
      }
    }
    if (!_findRoute) {
      final informations = FlouterInformation(
        uri: uri,
        match: null,
        pushUri: pushUri,
        pushMultipleUri: pushMultipleUri,
        clearAndPushUri: clearAndPushUri,
        clearAndPushMultipleUri: clearAndPushMultipleUri,
        removeLastUri: removeLastUri,
        removeUri: removeUri,
      );
      _pages.add(
        pageNotFound?.call(informations) ??
            MaterialPage(child: Scaffold(body: Container(child: Center(child: Text('Page not found'))))),
      );
      _uris.add(uri);
    }
    if (_shouldUpdate) {
      notifyListeners();
    }
    return SynchronousFuture(null);
  }

  @experimental
  Future<void> pushMultipleUri(List<Uri> uris) async {
    _shouldUpdate = false;
    for (final uri in uris) {
      await setNewRoutePath(uri);
    }
    _shouldUpdate = true;
  }

  Future<void> pushUri(Uri uri) => setNewRoutePath(uri);

  Future<void> clearAndPushUri(Uri uri) {
    _pages.clear();
    _uris.clear();
    return pushUri(uri);
  }

  Future<void> clearAndPushMultipleUri(List<Uri> uris) {
    _pages.clear();
    _uris.clear();
    return pushMultipleUri(uris);
  }

  void removeUri(Uri uri) {
    final index = _uris.indexOf(uri);
    _pages.removeAt(index);
    _uris.removeAt(index);
    notifyListeners();
  }

  void removeLastUri() {
    _pages.removeLast();
    _uris.removeLast();
    notifyListeners();
  }
}
