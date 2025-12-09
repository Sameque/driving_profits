import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:driving_profits/data/services/supabase_service.dart';
import 'package:driving_profits/data/services/database_service.dart';
import 'package:driving_profits/data/services/entry_service.dart';
import 'package:driving_profits/data/services/expense_service.dart';

import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/data/repositories/expense_repository.dart';

import 'package:driving_profits/ui/feature/summary/summary_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/start/start_entry_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/edit/edit_entry_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/expenses/expenses_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/close/close_entry_viewmodel.dart';
import 'package:driving_profits/ui/feature/list/daily_list_viewmodel.dart';
import 'package:driving_profits/ui/feature/expenses/expense_viewmodel.dart';

class AppProviders {
  static Widget build({required Widget child}) {
    return MultiProvider(
      providers: [
        //TODO: remover DatabaseService se não for mais necessário
        // Shared DatabaseService
        Provider<DatabaseService>(create: (_) => DatabaseService.instance),

        // Supabase Service
        Provider<SupabaseService>(create: (_) => SupabaseService()),

        // Shared DatabaseService (mantendo conforme original - pode remover duplicado se quiser)
        Provider<DatabaseService>(create: (_) => DatabaseService.instance),

        // Entry
        ProxyProvider<SupabaseService, EntryService>(
          update: (_, supabaseService, __) => EntryService(supabaseService),
        ),
        ProxyProvider<EntryService, EntryRepository>(
          update: (_, service, __) => EntryRepository(service),
        ),

        ChangeNotifierProvider(
          create: (ctx) => SummaryViewmodel(ctx.read<EntryRepository>()),
        ),

        // Start Entry
        ChangeNotifierProvider(
          create: (ctx) => StartEntryViewmodel(ctx.read<EntryRepository>()),
        ),

        // Edit Entry
        ChangeNotifierProvider(
          create: (ctx) => EditEntryViewModel(ctx.read<EntryRepository>()),
        ),

        // Expenses Entry
        ChangeNotifierProvider(
          create: (ctx) => ExpensesViewmodel(ctx.read<EntryRepository>()),
        ),

        // Close Entry
        ChangeNotifierProvider(
          create: (ctx) => CloseEntryViewModel(ctx.read<EntryRepository>()),
        ),

        // Entry List
        ChangeNotifierProvider(
          create: (ctx) => DailyListViewmodel(ctx.read<EntryRepository>()),
        ),

        // Expense
        ProxyProvider<DatabaseService, ExpenseService>(
          update: (_, db, __) => ExpenseService(db),
        ),
        ProxyProvider<ExpenseService, ExpenseRepository>(
          update: (_, service, __) => ExpenseRepository(service),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ExpenseViewModel(ctx.read<ExpenseRepository>()),
        ),
      ],
      child: child,
    );
  }
}
