import 'package:auto_injector/auto_injector.dart';
import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/data/repositories/expense_repository.dart';
import 'package:driving_profits/data/services/database_service.dart';
import 'package:driving_profits/data/services/entry_service.dart';
import 'package:driving_profits/data/services/expense_service.dart';
import 'package:driving_profits/data/services/entry_expense_service.dart';
import 'package:driving_profits/data/services/supabase_service.dart';
import 'package:driving_profits/ui/feature/entry/close/close_entry_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/edit/edit_entry_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/expenses/entry_expense_list_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/start/start_entry_viewmodel.dart';
import 'package:driving_profits/ui/feature/expenses/expense_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/list/entry_list_viewmodel.dart';
import 'package:driving_profits/ui/feature/summary/summary_viewmodel.dart';

final injector = AutoInjector();

void setupDependencies() {
  //viemodels
  injector.addSingleton(EntryListViewmodel.new);
  injector.addSingleton(StartEntryViewmodel.new);
  injector.addSingleton(EditEntryViewModel.new);
  injector.addSingleton(CloseEntryViewModel.new);
  injector.addSingleton(SummaryViewmodel.new);
  injector.addSingleton(ExpenseViewModel.new);
  injector.addSingleton(EntryExpenseListViewmodel.new);

  //repositories
  injector.addSingleton(EntryRepository.new);
  injector.addSingleton(ExpenseRepository.new);

  //services
  final supabarEntryService = SupabaseService('daily_entries');
  final supabarExpenseService = SupabaseService('expenses');
  final supabaseEntryExpenseService = SupabaseService('entry_expenses');

  injector.addSingleton<EntryService>(() => EntryService(supabarEntryService));
  injector.addSingleton<ExpenseService>(
    () => ExpenseService(supabarExpenseService),
  );
  injector.addSingleton<EntryExpenseService>(
    () => EntryExpenseService(supabaseEntryExpenseService),
  );

  //librares
  injector.addSingleton<DatabaseService>(() => DatabaseService.instance);
}
