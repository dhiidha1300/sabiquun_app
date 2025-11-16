import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_event.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_state.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_bloc.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_state.dart';

/// Balance Adjustment Dialog
/// Allows cashiers to manually adjust user balances
class BalanceAdjustmentDialog extends StatefulWidget {
  final String userId;
  final String currentUserId;
  final VoidCallback? onAdjustmentComplete;

  const BalanceAdjustmentDialog({
    super.key,
    required this.userId,
    required this.currentUserId,
    this.onAdjustmentComplete,
  });

  @override
  State<BalanceAdjustmentDialog> createState() => _BalanceAdjustmentDialogState();
}

class _BalanceAdjustmentDialogState extends State<BalanceAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  String _adjustmentType = 'clear'; // 'clear', 'add', 'adjust'
  String _paymentMethod = 'cash';
  double _currentBalance = 0;

  @override
  void initState() {
    super.initState();
    // Get current balance from the bloc if available
    final penaltyState = context.read<PenaltyBloc>().state;
    if (penaltyState is PenaltyBalanceLoaded) {
      _currentBalance = penaltyState.balance;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  double get _newBalance {
    final amount = double.tryParse(_amountController.text) ?? 0;
    switch (_adjustmentType) {
      case 'clear':
        return _currentBalance - amount;
      case 'add':
        return _currentBalance + amount;
      case 'adjust':
        return amount;
      default:
        return _currentBalance;
    }
  }

  void _submitAdjustment() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final reason = _reasonController.text.trim();

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Adjustment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Action: ${_getAdjustmentTypeLabel(_adjustmentType)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text('Amount: ${NumberFormat('#,###').format(amount)} Shillings'),
              if (_adjustmentType != 'adjust') ...[
                const SizedBox(height: 8),
                Text('Current Balance: ${NumberFormat('#,###').format(_currentBalance)}'),
                Text(
                  'New Balance: ${NumberFormat('#,###').format(_newBalance)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _newBalance < 0 ? AppColors.error : Colors.green,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'New Balance: ${NumberFormat('#,###').format(_newBalance)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
              const SizedBox(height: 8),
              Text('Method: ${_paymentMethod.toUpperCase()}'),
              const SizedBox(height: 8),
              const Text(
                'Reason:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(reason),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This action will:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_adjustmentType == 'clear') ...[
                      _buildActionItem('Apply ${NumberFormat('#,###').format(amount)} to oldest penalties'),
                      _buildActionItem('Update user balance immediately'),
                      _buildActionItem('Send notification to user'),
                      _buildActionItem('Create audit log entry'),
                    ] else if (_adjustmentType == 'add') ...[
                      _buildActionItem('Add ${NumberFormat('#,###').format(amount)} penalty'),
                      _buildActionItem('Update user balance immediately'),
                      _buildActionItem('Send notification to user'),
                      _buildActionItem('Create audit log entry'),
                    ] else ...[
                      _buildActionItem('Set balance to ${NumberFormat('#,###').format(amount)}'),
                      _buildActionItem('Update user balance immediately'),
                      _buildActionItem('Send notification to user'),
                      _buildActionItem('Create audit log entry'),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation
              _executeAdjustment(amount, reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _executeAdjustment(double amount, String reason) {
    // Use the manual balance clear event from PaymentBloc
    context.read<PaymentBloc>().add(
          ManualBalanceClearRequested(
            userId: widget.userId,
            amount: amount,
            paymentMethod: _paymentMethod,
            reason: reason,
            clearedBy: widget.currentUserId,
          ),
        );
  }

  Widget _buildActionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.orange.shade700)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }

  String _getAdjustmentTypeLabel(String type) {
    switch (type) {
      case 'clear':
        return 'Clear Penalty (Payment Received)';
      case 'add':
        return 'Add Penalty (Manual Charge)';
      case 'adjust':
        return 'Adjust Balance (Direct Modification)';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is BalanceCleared) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Balance adjusted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Call completion callback
          widget.onAdjustmentComplete?.call();

          // Close dialog
          Navigator.pop(context);
        } else if (state is PaymentError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Manual Balance Adjustment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Current Balance Display
                  BlocBuilder<PenaltyBloc, PenaltyState>(
                    builder: (context, state) {
                      if (state is PenaltyBalanceLoaded) {
                        _currentBalance = state.balance;
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Balance',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${NumberFormat('#,###').format(_currentBalance)} Sh',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Adjustment Type
                  Text(
                    'Action Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: const Text('Clear Penalty'),
                    subtitle: const Text('Reduce balance (payment received)'),
                    value: 'clear',
                    groupValue: _adjustmentType,
                    onChanged: (value) => setState(() => _adjustmentType = value!),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: const Text('Add Penalty'),
                    subtitle: const Text('Increase balance (manual penalty)'),
                    value: 'add',
                    groupValue: _adjustmentType,
                    onChanged: (value) => setState(() => _adjustmentType = value!),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: const Text('Adjust Balance'),
                    subtitle: const Text('Direct modification (correction)'),
                    value: 'adjust',
                    groupValue: _adjustmentType,
                    onChanged: (value) => setState(() => _adjustmentType = value!),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  // Amount Input
                  Text(
                    _adjustmentType == 'adjust' ? 'New Balance (Shillings)' : 'Amount (Shillings)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefixIcon: const Icon(Icons.money),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      if (_adjustmentType == 'clear' && amount > _currentBalance) {
                        return 'Amount cannot exceed current balance';
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() {}), // Update preview
                  ),
                  const SizedBox(height: 16),

                  // Payment Method (only for clear penalty)
                  if (_adjustmentType == 'clear') ...[
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'zaad', child: Text('ZAAD')),
                        DropdownMenuItem(value: 'edahab', child: Text('eDahab')),
                        DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (value) => setState(() => _paymentMethod = value!),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Reason/Notes
                  Text(
                    'Reason/Notes (required)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Explain why this adjustment is needed',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Reason is required';
                      }
                      if (value.trim().length < 10) {
                        return 'Reason must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Preview
                  if (_amountController.text.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade50,
                            Colors.blue.shade100,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_adjustmentType != 'adjust')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current',
                                  style: TextStyle(color: Colors.blue.shade700),
                                ),
                                Text(
                                  '${NumberFormat('#,###').format(_currentBalance)} Sh',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                          if (_adjustmentType != 'adjust') const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Adjustment',
                                style: TextStyle(color: Colors.blue.shade700),
                              ),
                              Text(
                                '${_adjustmentType == 'add' ? '+' : _adjustmentType == 'clear' ? '-' : ''}${NumberFormat('#,###').format(double.tryParse(_amountController.text) ?? 0)} Sh',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'New Balance',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              Text(
                                '${NumberFormat('#,###').format(_newBalance)} Sh',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _newBalance < 0 ? AppColors.error : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      BlocBuilder<PaymentBloc, PaymentState>(
                        builder: (context, state) {
                          final isLoading = state is PaymentLoading;

                          return ElevatedButton(
                            onPressed: isLoading ? null : _submitAdjustment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Confirm Adjustment'),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
