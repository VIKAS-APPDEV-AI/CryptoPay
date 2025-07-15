import 'package:crypto_pay/src/utils/Constants.dart';
import 'package:flutter/material.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  final String image;
  final Color bgColor;
  final Color textColor;

  OnboardingPageModel(
      {required this.title,
      required this.description,
      required this.image,
      this.bgColor = AppColors.kprimary,
      this.textColor = AppColors.kwhite});
}
