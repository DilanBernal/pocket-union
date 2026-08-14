import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'entry_command_form.g.dart';

@riverpod
class EntryCommandForm extends _$EntryCommandForm {
  @override
  AsyncValue build() => const AsyncData(null);

  Future<void> submit(FormBuilderState formState) async {
    if (formState.saveAndValidate() == false) {
      state = AsyncError('Validation failed', StackTrace.current);
      return;
    }
    final formData = formState.value;
  }
}
