import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:finasstech/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context,
  String title,
  String content,
  ContentType contentType,
) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      customSnack(title: title, content: content, contentType: contentType),
    );
}

customSnack({
  required String title,
  required String content,
  required ContentType contentType,
}) => SnackBar(
  elevation: 0,
  behavior: SnackBarBehavior.floating,
  backgroundColor: Colors.transparent,
  content: AwesomeSnackbarContent(
    color: contentType == ContentType.success ? AppPallete.primaryColor : null,
    title: title,
    message: content,
    inMaterialBanner: true,

    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
    contentType: contentType,
  ),
);
