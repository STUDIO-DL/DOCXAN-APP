abstract interface class PermissionService {
  Future<bool> ensureCamera();
}

class UnimplementedPermissionService implements PermissionService {
  const UnimplementedPermissionService();

  @override
  Future<bool> ensureCamera() async => false;
}
