import 'package:flouter/src/route_information.dart';
import 'package:flutter/widgets.dart';

typedef PushUri = Future<void> Function(Uri);
typedef PushMultipleUri = Future<void> Function(List<Uri>);
typedef ClearAndPushUri = Future<void> Function(Uri);
typedef ClearAndPushMultipleUri = Future<void> Function(List<Uri>);
typedef RemoveLastUri = void Function();
typedef RemoveUri = void Function(Uri);

typedef PageBuilder = Page Function(FlouterRouteInformation);
