

import 'package:email_validator/email_validator.dart';
import 'package:string_validator/string_validator.dart';

const MIN_USERNAME_LENGTH = 5;
const MAX_USERNAME_LENGTH = 15;

const MIN_PASSWORD_LENGTH = 8;
const MAX_PASSWORD_LENGTH = 64;

class InputValidations
{
     static String emptyErrorMessage = "this field cannot be empty";

     static String usernameLongInputError = "Your username must be 15 characters or less and contain only letters, numbers, and underscores and no spaces";
     static String usernameShortInputError = "Username should be more than 4 characters.";

     static String passwordLongInputError = "password is too long";
     static String passwordShortInputError = "password is too short";
     static String passwordWeakError = "weak password!";
     static String emailInvalidInput = "Please enter a valid email";
     static String invalidInput = "invalid input";

     static String? isUniqueUsername(String? username)
     {
          // TODO: call the api to check if it's a unique username
          // should return a meaningful string of already used username
          // if it's new return null
          return null;
     }

     /// Takes a username string as an input and checks whether it is a proper username
     /// or not according to the valid username rules
     static String? isValidUsername(String? username)
     {
          final RegExp validCharacters = RegExp("[a-zA-Z0-9_]");

          if (username == null || username.isEmpty) {
            return null;
          }

          if (username.length < MIN_USERNAME_LENGTH) {
            return usernameShortInputError;
          }

          if (username.length > MAX_USERNAME_LENGTH) {
            return usernameLongInputError;
          }

          if (validCharacters.allMatches(username).length != username.length){
               return invalidInput;
          }

          return isUniqueUsername(username);
     }

     /// Takes a password string as an input and checks whether it is a proper password
     /// or not according to the given rules
     /// 1- isn't empty or null
     /// 2- has at lease [lowercase latin - uppercase latin - number - special char]
     /// 3- it's length is bounded by some min and max
     static String? isValidPassword(String? password)
     {

          if (password == null || password.isEmpty) {
            return null;
          }
          if (password.length < MIN_PASSWORD_LENGTH){
               return passwordShortInputError;
          }
          if (password.length > MAX_PASSWORD_LENGTH){
               return passwordLongInputError;
          }

          RegExp letters = RegExp("[a-zA-Z]");

          bool hasLetters = letters.hasMatch(password);

          return hasLetters ? null : passwordWeakError;

     }

     /// Checks if the given string is in email format
     static String? isValidEmail(String? email)
     {
          if (email == null || email.isEmpty) {
            return null;
          }
          
          if(!EmailValidator.validate(email)){
              return emailInvalidInput;
          }
          return null;
     }

     static String nameLongErrorMessage = "Must be 50 characters or fewer";

     static String? isValidName(String? name){
          if(name == null || name.isEmpty){
               return null;
          }
          if(name.length > 50){
               return nameLongErrorMessage;
          }
          return null;
     }

     static String? isValidCode(String? code)
     {
          //TODO: validate code format
          return null;
     }
}