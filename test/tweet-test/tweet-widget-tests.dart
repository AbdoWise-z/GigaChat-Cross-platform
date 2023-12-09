

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/widgets/tweet-widget/tweet.dart';

const TextStyle hitStyle = const TextStyle(color: Colors.blue);

void main()
{
  test("testing the hashtag creator function", () {
    List<String> testingVector = [
      "this string doesn't contain hashes",
      "#whole_string_is_hashed",
      "#hash then normal string",
      "",
      "#hashed normal then #hashed"
    ];

    List<List<TextSpan>> output = const [
      [TextSpan(text: "this string doesn't contain hashes")],
      [TextSpan(text: "#whole_string_is_hashed",style: hitStyle)],
      [
        TextSpan(text: "#hash",style: hitStyle),
        TextSpan(text: " then normal string"),
      ],
      [
      ],
      [
        TextSpan(text: "#hashed",style: hitStyle),
        TextSpan(text: " normal then "),
        TextSpan(text: "#hashed",style: hitStyle),
      ],
    ];
    int i = 0;
    for(String testString in testingVector){
      List<TextSpan> result = textToRichText(testString, false);
      expect(result.toString(), output[i++].toString());
    }
  });
}