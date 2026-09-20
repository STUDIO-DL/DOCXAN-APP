abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const lock = '/lock';
  static const pinSetup = '/lock/setup';
  static const home = '/home';
  static const folders = '/folders';
  static const folderDetail = '/folders/:folderId';
  static const scan = '/scan';
  static const scanCapture = '/scan/capture';
  static const scanEdit = '/scan/edit';
  static const settings = '/settings';
  static const search = '/search';
  static const backup = '/backup';
  static const document = '/document/:id';
  static const legal = '/settings/legal/:kind';

  static String documentPath(String id) => '/document/$id';
  static String folderPath(String folderId) => '/folders/$folderId';
  static String legalPath(String kind) => '/settings/legal/$kind';
}
