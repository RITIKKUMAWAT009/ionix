part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const PROFILE = _Paths.PROFILE;
  static const SETTINGS = _Paths.SETTINGS;
  static const SCHEDULE = _Paths.SCHEDULE;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const PROFILE = '/profile';
  static const SETTINGS = '/settings';
  static const SCHEDULE = '/schedule';
}