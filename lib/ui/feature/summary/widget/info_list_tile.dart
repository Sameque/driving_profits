import 'package:flutter/material.dart';

class InfoListTile extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const InfoListTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
