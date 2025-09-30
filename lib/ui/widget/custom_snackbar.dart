import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Configurações baseadas no tipo
    late Color backgroundColor;
    late Color textColor;
    late IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = isDarkMode ? Colors.green[900]! : Colors.green[100]!;
        textColor = isDarkMode ? Colors.green[100]! : Colors.green[900]!;
        icon = Icons.check_circle_outlined;
        break;
      case SnackBarType.error:
        backgroundColor = isDarkMode ? Colors.red[900]! : Colors.red[100]!;
        textColor = isDarkMode ? Colors.red[100]! : Colors.red[900]!;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor =
            isDarkMode ? Colors.orange[900]! : Colors.orange[100]!;
        textColor = isDarkMode ? Colors.orange[100]! : Colors.orange[900]!;
        icon = Icons.warning_amber_outlined;
        break;
      case SnackBarType.info:
        backgroundColor = isDarkMode ? Colors.blue[900]! : Colors.blue[100]!;
        textColor = isDarkMode ? Colors.blue[100]! : Colors.blue[900]!;
        icon = Icons.info_outline;
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: textColor))),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: behavior,
      duration: duration,
      action:
          actionLabel != null
              ? SnackBarAction(
                label: actionLabel,
                textColor: textColor,
                onPressed: onAction ?? () {},
              )
              : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin:
          behavior == SnackBarBehavior.floating
              ? const EdgeInsets.all(16)
              : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // Métodos de conveniência para cada tipo
  static void success({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.success,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void error({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.error,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void warning({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void info({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.info,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }
}
