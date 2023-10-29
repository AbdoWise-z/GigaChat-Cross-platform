

import 'package:string_validator/string_validator.dart';

class InputVerification
{

     static bool verifyUsername(String username)
     {
          return username.length > 10;
     }

     static bool verifyPassword(String password)
     {
     RegExp regex = RegExp("[a-zA-Z0-9@#_\$]");
     RegExp specialChars = RegExp("[@!\$#_-]");
     bool acceptedLength = password.length >= 10 && password.length <= 64;
     bool satisfyRegex = regex.hasMatch(password);
     bool hasLowerCase = false;
     bool hasUpperCase = false;
     bool hasNumber = false;
     bool hasSpecial = false;

     for (int i = 0; i < password.length; i++)
     {
          hasLowerCase |= isLowercase(password[i]);
          hasUpperCase |= isUppercase(password[i]);
          hasNumber |= isInt(password[i]);
          hasSpecial |= specialChars.hasMatch(password[i]);
     }

     return acceptedLength && satisfyRegex && hasSpecial && hasLowerCase && hasUpperCase && hasNumber;
     }

}