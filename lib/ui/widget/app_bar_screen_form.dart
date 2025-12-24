import 'package:flutter/material.dart';

class AppBarScreenForm extends StatelessWidget implements PreferredSizeWidget {
  final String screenTitle;
  final List<Widget>? actions;
  final Widget? leading;

  const AppBarScreenForm({
    super.key,
    required this.screenTitle,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(screenTitle),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 4,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      shape: Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      actions: actions,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
