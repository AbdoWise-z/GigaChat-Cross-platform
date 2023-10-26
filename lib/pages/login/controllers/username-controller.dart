


Future<bool> verifyUsername(String? username) async
{
      if (username == null || username.isEmpty)
      {
        return false;
      }
      else
      {
        // TODO: we should call the api here
        // wait for server response
        return true;
      }
}