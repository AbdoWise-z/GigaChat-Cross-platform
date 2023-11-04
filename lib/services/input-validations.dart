

import 'package:string_validator/string_validator.dart';

const MIN_USERNAME_LENGTH = 6;
const MAX_USERNAME_LENGTH = 20;

const MIN_PASSWORD_LENGTH = 6;
const MAX_PASSWORD_LENGTH = 64;



class InputValidations
{
     static String _buildShortFieldError(String fieldName, int min) => "$fieldName must be at least $min characters";
     static String _buildLongFieldError(String fieldName, int max) => "$fieldName must be at most $max characters";

     static String emptyErrorMessage = "this field cannot be empty";
     static String passwordShortInputError = _buildShortFieldError("password", MIN_PASSWORD_LENGTH);
     static String passwordLongInputError = _buildLongFieldError("password", MAX_PASSWORD_LENGTH);
     static String passwordInvalidInput = "invalid input, only characters and numbers and some special characters are allowed";
     static String passwordWeakError = "weak password";

     static String usernameShortInputError = _buildShortFieldError("password", MIN_USERNAME_LENGTH);
     static String usernameLongInputError = _buildLongFieldError("password", MAX_USERNAME_LENGTH);

     static String? verifyUsername(String? username)
     {
          if (username == null || username.isEmpty) {
            return emptyErrorMessage;
          }

          if (username.length < MIN_USERNAME_LENGTH) {
            return usernameShortInputError;
          }

          if (username.length > MAX_USERNAME_LENGTH) {
            return usernameLongInputError;
          }

          return null;
     }

     static String? verifyPassword(String? password)
     {
          if (password == null || password.isEmpty) return emptyErrorMessage;
          if (password.length < MIN_PASSWORD_LENGTH) return passwordShortInputError;
          if (password.length > MAX_PASSWORD_LENGTH) return passwordLongInputError;

          RegExp validCharacterRegex = RegExp("[a-zA-Z0-9@#_!\$]");
          if(validCharacterRegex.allMatches(password).length != password.length){
               return passwordInvalidInput;
          }


          RegExp specialChars = RegExp("[@!\$#_-]");
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

          return hasSpecial && hasLowerCase && hasUpperCase && hasNumber ? null : passwordWeakError;
     }

     static String? isValidEmail(String? email)
     {
          // TODO: implement email recognition
          if (email == null || email.isEmpty) return "email is empty.";
          return null;
     }

     static String? isValidCode(String? code)
     {
          //TODO: validate code format
          return null;
     }
}