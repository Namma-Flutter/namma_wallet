import 'package:namma_wallet/src/features/home/data/model/generic_details_model.dart';

bool hasPnrOrId(GenericDetailsModel ticket) {
  return ticket.extras?.any((extra) {
        final title = extra.title?.toLowerCase();
        return title == 'pnr' || title == 'id';
      }) ??
      false;
}

String? getPnrOrId(GenericDetailsModel ticket) {
  if (ticket.extras == null) return null;

  for (final extra in ticket.extras!) {
    final title = extra.title?.toLowerCase();
    if (title == 'pnr' || title == 'id') {
      return extra.value; // return the value of the matched field
    }
  }
  return null; // nothing found
}
