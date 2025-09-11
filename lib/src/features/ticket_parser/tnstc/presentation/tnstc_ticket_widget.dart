import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/ticket_parser/tnstc/domain/tnstc_model.dart';

class TNSTCTicketWidget extends StatelessWidget {
  const TNSTCTicketWidget({
    required this.ticket,
    super.key,
  });
  final TNSTCTicketModel ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.corporation ?? 'TNSTC',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PNR: ${ticket.displayPnr}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Journey Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Route
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FROM',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.displayFrom,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.blue,
                      size: 24,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'TO',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.displayTo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Journey Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Date',
                        ticket.displayDate,
                        Icons.calendar_today,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Time',
                        ticket.serviceStartTime ?? 'Unknown',
                        Icons.access_time,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Class',
                        ticket.displayClass,
                        Icons.airline_seat_recline_normal,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Fare',
                        ticket.displayFare,
                        Icons.currency_rupee,
                      ),
                    ),
                  ],
                ),

                if (ticket.seatNumbers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    'Seat Number(s)',
                    ticket.seatNumbers,
                    Icons.event_seat,
                  ),
                ],

                if (ticket.tripCode != null && ticket.tripCode!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    'Trip Code',
                    ticket.tripCode!,
                    Icons.qr_code,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
