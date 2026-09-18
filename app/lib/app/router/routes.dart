abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const lock = '/lock';
  static const home = '/home';
  static const folders = '/folders';
  static const scan = '/scan';
  static const settings = '/settings';
  static const search = '/search';
  static const backup = '/backup';
  static const document = '/document/:id';

  static String documentPath(String id) => '/document/$id';
}
