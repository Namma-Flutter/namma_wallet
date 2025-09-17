// import 'package:flutter/material.dart';
// import 'package:namma_wallet/src/features/home/data/model/event_model.dart';
// import 'package:namma_wallet/styles/styles.dart';

// class EventTicketCardWidget extends StatelessWidget {
//   const EventTicketCardWidget({
//     required this.event,
//     super.key,
//   });

//   final EventModel event;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: AppColor.secondaryColor,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           spacing: 12,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     //* Event title
//                     Text(
//                       event.eventName ?? 'xxx xxx',
//                       style: const TextStyle(color: AppColor.whiteColor),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),

//                     //* Date & Time
//                     Text(
//                       event.dateTime?.toString() ?? 'xxx xxx',
//                       style: const TextStyle(color: AppColor.whiteColor),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                   ],
//                 ),
//                 //* Event icon
//                 Icon(
//                   event.eventIcon,
//                   color: AppColor.whiteColor,
//                 )
//               ],
//             ),
//             //* Address
//             Text(
//               event.venue ?? 'xxx xxx',
//               style: const TextStyle(color: AppColor.whiteColor),
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
