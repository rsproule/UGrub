import 'dart:io' as IO;
import 'dart:io';
import 'package:image/image.dart';
import 'dart:convert';

convertToSize(File imageFile, int size){

  Image im = decodeImage(imageFile.readAsBytesSync());

  Image resized = copyResize(im, size);

//  File m = encodeJpg(im, quality: 100);
//

  // pretty sure this overwrites the old one, but its fine because the bigger file is converted first
  File file = new File(imageFile.path) ..writeAsBytesSync(encodeJpg(resized, quality: 100));


  return file;
}