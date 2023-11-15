import 'package:esxile/repository/esxile.repo.dart';

abstract class AuthenticationRepository extends EsxileRepository {
  Future<bool> authorize(String username, String password);

  Future<void> deAuthorize();
}
