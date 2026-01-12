import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/domain/entry/entry_dto.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';
import 'package:result_dart/src/types.dart';

class EntryExpenseListViewmodel {
  final EntryRepository _repository;

  EntryExpenseListViewmodel(this._repository);

  late final updateEntryExpenseCommand = Command1(_updateEntryExpense);

  AsyncResult _updateEntryExpense(EntryDto entryDto) async {
    final entryEntity = DailyEntry.fromMap(entryDto.toMap());
    await _repository.updateEntry(entryDto.id, entryEntity);
    return Success(unit);
  }
}
