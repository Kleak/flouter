import 'package:flouter/src/route_information.dart';
import 'package:flutter/widgets.dart';

/// allow you to push one [Uri]
typedef PushUri = Future<void> Function(Uri);

/// allow you to push multiple [Uri] in one batch and remove the animation
/// of all except the last one
typedef PushMultipleUri = Future<void> Function(List<Uri>);

/// clear the stack of pages and push one [Uri]
typedef ClearAndPushUri = Future<void> Function(Uri);

/// clear the stack of pages and push a batch of pages
typedef ClearAndPushMultipleUri = Future<void> Function(List<Uri>);

/// remove the last [Uri]
typedef RemoveLastUri = void Function();

/// allow you to remove a specific [Uri] in the [List] of [Uri]
typedef RemoveUri = void Function(Uri);

/// a [PageBuilder] take the route information and return a [Page]
typedef PageBuilder = Page Function(FlouterRouteInformation);
