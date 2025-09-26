import 'package:flutter/material.dart';
import 'package:uber_tracker/ui/feature/entry/entry_dto.dart';

class EntryViewModel extends ChangeNotifier {
  EntryDto entryDto = EntryDto();

  EntryViewModel() {
    entryDto = EntryDto();
    _bindEntryDto();
  }

  void setEntryDto(EntryDto entryDto) {
    this.entryDto.removeListener(_relayChanges);
    this.entryDto = entryDto;
    _bindEntryDto();
    notifyListeners();
  }

  void _bindEntryDto() {
    entryDto.addListener(_relayChanges);
  }

  void _relayChanges() {
    notifyListeners();
  }
}
