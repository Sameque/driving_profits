import 'package:auto_injector/auto_injector.dart';
import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/data/services/entry_service.dart';
import 'package:driving_profits/data/services/supabase_service.dart';
import 'package:driving_profits/ui/feature/entry/edit/edit_entry_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/expenses/expenses_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/start/start_entry_viewmodel.dart';
import 'package:driving_profits/ui/feature/list/daily_list_viewmodel.dart';

final injector = AutoInjector();

void setupDependencies() {
  //viemodels
  injector.addSingleton(DailyListViewmodel.new);
  injector.addSingleton(StartEntryViewmodel.new);
  injector.addSingleton(ExpensesViewmodel.new);
  injector.addSingleton(EditEntryViewModel.new);

  //repositories
  injector.addSingleton(EntryRepository.new);

  //services
  injector.addSingleton(EntryService.new);

  //librares
  injector.addSingleton(SupabaseService.new);
}
