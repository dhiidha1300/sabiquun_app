import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../../../penalties/presentation/bloc/penalty_bloc.dart';
import '../../../penalties/presentation/bloc/penalty_event.dart';
import '../../../penalties/presentation/bloc/penalty_state.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class SubmitPaymentPage extends StatefulWidget {
  final String userId;

  const SubmitPaymentPage({
    super.key,
    required this.userId,
  });

  @override
  State<SubmitPaymentPage> createState() => _SubmitPaymentPageState();
}

class _SubmitPaymentPageState extends State<SubmitPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();

  String? _selectedPaymentMethodId;
  bool _isFullPayment = true;
  double? _totalBalance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<PaymentBloc>().add(const LoadPaymentMethodsRequested());
    context.read<PenaltyBloc>().add(LoadUnpaidPenaltiesRequested(widget.userId));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Payment'),
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment submitted successfully! Awaiting review.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Balance Card
                _buildBalanceCard(),
                const SizedBox(height: 24),

                // Unpaid Penalties Breakdown
                _buildUnpaidPenaltiesSection(),
                const SizedBox(height: 24),

                // Payment Form
                _buildPaymentForm(),
                const SizedBox(height: 32),

                // Submit Button
                BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: 'Submit Payment',
                      onPressed: state is PaymentLoading ? null : _submitPayment,
                      isLoading: state is PaymentLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return BlocBuilder<PenaltyBloc, PenaltyState>(
      builder: (context, state) {
        if (state is UnpaidPenaltiesLoaded) {
          // Update state after the build phase completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _totalBalance = state.totalBalance;
              });
              if (_isFullPayment && _amountController.text != state.totalBalance.toStringAsFixed(0)) {
                _amountController.text = state.totalBalance.toStringAsFixed(0);
              }
            }
          });

          return Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.blue.shade900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.totalBalance.toStringAsFixed(0)} Shillings',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (state.penalties.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${state.penalties.length} unpaid ${state.penalties.length == 1 ? 'penalty' : 'penalties'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUnpaidPenaltiesSection() {
    return BlocBuilder<PenaltyBloc, PenaltyState>(
      builder: (context, state) {
        if (state is UnpaidPenaltiesLoaded && state.penalties.isNotEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Outstanding Penalties (FIFO)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Oldest penalties will be paid first',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...state.penalties.take(5).map((penalty) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(penalty.dateIncurred),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              penalty.formattedRemainingAmount,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      )),
                  if (state.penalties.length > 5)
                    Text(
                      '+ ${state.penalties.length - 5} more...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Method Selector
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, paymentState) {
            return BlocBuilder<PenaltyBloc, PenaltyState>(
              builder: (context, penaltyState) {
                if (paymentState is PaymentMethodsLoaded) {
                  // Check if there are no payment methods available
                  if (paymentState.methods.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No Payment Methods Available',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Please contact an administrator to set up payment methods.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Check if penalties are loaded and there's a balance to determine if dropdown should be enabled
                  final bool isEnabled;
                  final String? helperText;

                  if (penaltyState is UnpaidPenaltiesLoaded) {
                    isEnabled = penaltyState.totalBalance > 0;
                    helperText = isEnabled ? null : 'No outstanding balance';
                  } else if (penaltyState is PenaltyLoading) {
                    isEnabled = false;
                    helperText = 'Loading balance...';
                  } else {
                    isEnabled = false;
                    helperText = 'Waiting for balance data...';
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedPaymentMethodId,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Select payment method',
                      helperText: helperText,
                    ),
                    items: paymentState.methods
                        .map((method) => DropdownMenuItem(
                              value: method.id,
                              child: Text(method.displayName),
                            ))
                        .toList(),
                    onChanged: isEnabled ? (value) {
                      setState(() {
                        _selectedPaymentMethodId = value;
                      });
                    } : null,
                    validator: (value) {
                      if (isEnabled && (value == null || value.isEmpty)) {
                        return 'Please select a payment method';
                      }
                      return null;
                    },
                  );
                } else if (paymentState is PaymentError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Failed to load payment methods',
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          context.read<PaymentBloc>().add(const LoadPaymentMethodsRequested());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  );
                }
                return const CircularProgressIndicator();
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Payment Type
        Text(
          'Payment Type',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  _isFullPayment ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: _isFullPayment ? Theme.of(context).primaryColor : Colors.grey,
                ),
                title: Text('Full Payment (${_totalBalance?.toStringAsFixed(0) ?? '0'} Shillings)'),
                onTap: () {
                  setState(() {
                    _isFullPayment = true;
                    if (_totalBalance != null) {
                      _amountController.text = _totalBalance!.toStringAsFixed(0);
                    }
                  });
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  !_isFullPayment ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: !_isFullPayment ? Theme.of(context).primaryColor : Colors.grey,
                ),
                title: const Text('Partial Payment'),
                onTap: () {
                  setState(() {
                    _isFullPayment = false;
                    _amountController.clear();
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Amount Field
        CustomTextField(
          controller: _amountController,
          labelText: 'Amount (Shillings)',
          keyboardType: TextInputType.number,
          enabled: !_isFullPayment,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (_totalBalance != null && amount > _totalBalance!) {
              return 'Amount cannot exceed balance';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Reference Number (Optional)
        CustomTextField(
          controller: _referenceController,
          labelText: 'Reference Number (Optional)',
          hintText: 'Transaction reference from mobile money',
        ),
      ],
    );
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Payment'),
          content: Text(
            'Submit payment of ${amount.toStringAsFixed(0)} Shillings?\n\n'
            'Your payment will be reviewed by an admin or cashier.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<PaymentBloc>().add(
                      SubmitPaymentRequested(
                        userId: widget.userId,
                        amount: amount,
                        paymentMethodId: _selectedPaymentMethodId!,
                        paymentType: _isFullPayment ? 'full' : 'partial',
                        referenceNumber: _referenceController.text.isEmpty
                            ? null
                            : _referenceController.text,
                      ),
                    );
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }
}
