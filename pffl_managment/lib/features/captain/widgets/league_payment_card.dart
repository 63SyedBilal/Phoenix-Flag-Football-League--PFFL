import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/captain_provider/home_screen_provider/captain_dashboard_provider.dart';

class LeaguePaymentCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final String format;
  final String leagueFee;
  final String startDate;
  final String endDate;
  final VoidCallback onPayNow;
  final String? leagueLogo;

  const LeaguePaymentCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.format,
    required this.leagueFee,
    required this.startDate,
    required this.endDate,
    required this.onPayNow,
    this.leagueLogo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dashboardProvider = Provider.of<CaptainDashboardProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Payment Reminder',
                        style: TextStyle(
                          fontFamily: "Lato",
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.03),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            amount,
                            style: const TextStyle(
                              fontFamily: "Lato",
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Lato",
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8), // Gap of 10px
                    Container(
                      width: 60,
                      height: 26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF0F172A),
                      ),
                      child: TextButton(
                        onPressed: onPayNow,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, endIndent: 12, indent: 12),
          GestureDetector(
            onTap: () {
              dashboardProvider.togglePaymentCardExpansion();
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'View League Details',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Lato",
                      ),
                    ),
                  ),
                  Icon(
                    dashboardProvider.isPaymentCardExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
          if (dashboardProvider.isPaymentCardExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: const Icon(Icons.sports_soccer, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Format:', format, colorScheme),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Start Date:',
                          startDate,
                          colorScheme,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 16,
                        color: colorScheme.outlineVariant,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'End Date:',
                          endDate,
                          colorScheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(height: 0.5, endIndent: 2, indent: 2,color: Colors.black12,),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Show more',
                          style: TextStyle(color: Colors.black38, fontSize: 12, fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
            //  color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lato',
              color: Color(0xFF111827
              ),
            ),
          ),
        ),

        Expanded(
          flex: 5,
          child: Text(
            value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF111827),),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF111827),

            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF111827),fontFamily: 'Lato',),
          ),
        ),
      ],
    );
  }
}
