import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:finasstech/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

/// Displays a snackbar with the specified title, content, and type.
///
/// This function:
/// - Hides any currently displayed snackbar
/// - Shows a new snackbar with the provided content
/// - Uses the custom snackbar styling defined in [customSnack]
///
/// Parameters:
/// - [context]: The build context for showing the snackbar
/// - [title]: The title text to display
/// - [content]: The main content message
/// - [contentType]: The type of snackbar (success, warning, help, etc.)
void showSnackBar(
  BuildContext context,
  String title,
  String content,
  ContentType contentType,
) {
  // Hide any existing snackbar before showing the new one
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    // Show the new snackbar with custom styling
    ..showSnackBar(
      customSnack(title: title, content: content, contentType: contentType),
    );
}

/// Creates a custom snackbar with the specified title, content, and type.
///
/// This function:
/// - Creates a floating snackbar with no elevation
/// - Uses transparent background for seamless integration
/// - Applies custom styling based on content type
/// - Uses AwesomeSnackbarContent for enhanced visual appeal
///
/// Parameters:
/// - [title]: The title text to display
/// - [content]: The main content message
/// - [contentType]: The type of snackbar (success, warning, help, etc.)
///
/// Returns a [SnackBar] widget with custom styling.
customSnack({
  required String title,
  required String content,
  required ContentType contentType,
}) => SnackBar(
  // Remove shadow for a flat design
  elevation: 0,
  // Make snackbar float above content
  behavior: SnackBarBehavior.floating,
  // Use transparent background for custom styling
  backgroundColor: Colors.transparent,
  content: AwesomeSnackbarContent(
    // Apply primary color for success messages
    color: contentType == ContentType.success ? AppPallete.primaryColor : null,
    title: title,
    message: content,
    // Use material banner style for better visibility
    inMaterialBanner: true,
    // Set the type of snackbar (success, warning, help, etc.)
    contentType: contentType,
  ),
);
