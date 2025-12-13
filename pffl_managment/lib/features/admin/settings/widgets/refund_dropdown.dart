import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'refund_reason_provider.dart';

class RefundDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RefundReasonProvider>(
      builder: (context, refundProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black26),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: refundProvider.selectedReason,
              items: refundProvider.refundReasons.map((String reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  refundProvider.setSelectedReason(newValue);
                }
              },
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down),
            ),
          ),
        );
      },
    );
  }
}