import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';

bool hasPnrOrId(GenericDetailsModel ticket) {
  return ticket.extras?.any((extra) {
        final title = extra.title?.toLowerCase();
        return title == 'pnr no.' || title == 'id';
      }) ??
      false;
}

String? getPnrOrId(GenericDetailsModel ticket) {
  if (ticket.extras == null) return null;

  for (final extra in ticket.extras!) {
    final title = extra.title?.toLowerCase();
    if (title == 'PNR No.' || title == 'id') {
      return extra.value; // return the value of the matched field
    }
  }
  return null; // nothing found
}
