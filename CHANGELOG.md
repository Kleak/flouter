## [0.2.0-nullsafety.1] - Flouter + nullsafety = <3 

Flouter is now compatible with dart nullsafety feature

* **BREAKING** rename `UriRouteInformationParser` to `FlouterRouteInformationParser`
* **BREAKING** rename `UriRouterDelegate` to `FlouterRouterDelegate`
* **BREAKING** rename `UriRouteManager` to `FlouterRouteManager`
* **BUG FIX** pushing existing route will now pus the route on top of other instead of removing the stack until the existing route

## [0.1.1] - improve pub score

* add basic documentation

## [0.1.0] - Initial published version.

First published version of Flouter a Flutter Router based on the Navigator 2.0 API
