import 'package:flutter/material.dart';

class FontScaleProvider extends ChangeNotifier {
  double _scale = 1.0;
  double get scale => _scale;

  void setScale(double Newscale){
    _scale = Newscale;
    notifyListeners();
  }
} 