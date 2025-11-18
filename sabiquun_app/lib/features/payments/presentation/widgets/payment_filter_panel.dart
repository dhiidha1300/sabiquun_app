import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Filter options for payment lists
class PaymentFilterOptions {
  final String? paymentMethod;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? status;

  const PaymentFilterOptions({
    this.paymentMethod,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.status,
  });

  bool get hasActiveFilters =>
      paymentMethod != null ||
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null ||
      status != null;

  int get activeFilterCount {
    int count = 0;
    if (paymentMethod != null) count++;
    if (startDate != null || endDate != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    if (status != null) count++;
    return count;
  }

  PaymentFilterOptions copyWith({
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? status,
    bool clearPaymentMethod = false,
    bool clearDates = false,
    bool clearAmounts = false,
    bool clearStatus = false,
  }) {
    return PaymentFilterOptions(
      paymentMethod: clearPaymentMethod ? null : (paymentMethod ?? this.paymentMethod),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      minAmount: clearAmounts ? null : (minAmount ?? this.minAmount),
      maxAmount: clearAmounts ? null : (maxAmount ?? this.maxAmount),
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  PaymentFilterOptions clear() {
    return const PaymentFilterOptions();
  }
}

/// Comprehensive payment filter panel
class PaymentFilterPanel extends StatefulWidget {
  final PaymentFilterOptions initialFilters;
  final Function(PaymentFilterOptions) onApply;
  final VoidCallback? onClear;

  const PaymentFilterPanel({
    super.key,
    required this.initialFilters,
    required this.onApply,
    this.onClear,
  });

  @override
  State<PaymentFilterPanel> createState() => _PaymentFilterPanelState();
}

class _PaymentFilterPanelState extends State<PaymentFilterPanel> {
  late PaymentFilterOptions _filters;
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    if (_filters.minAmount != null) {
      _minAmountController.text = _filters.minAmount!.toStringAsFixed(0);
    }
    if (_filters.maxAmount != null) {
      _maxAmountController.text = _filters.maxAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Method Filter
                    _buildSectionTitle('Payment Method'),
                    const SizedBox(height: 12),
                    _buildPaymentMethodDropdown(),
                    const SizedBox(height: 24),

                    // Date Range Filter
                    _buildSectionTitle('Date Range'),
                    const SizedBox(height: 12),
                    _buildDateRangeSelector(context),
                    const SizedBox(height: 24),

                    // Amount Range Filter
                    _buildSectionTitle('Amount Range'),
                    const SizedBox(height: 12),
                    _buildAmountRangeInputs(),
                    const SizedBox(height: 24),

                    // Status Filter
                    _buildSectionTitle('Payment Status'),
                    const SizedBox(height: 12),
                    _buildStatusDropdown(),
                  ],
                ),
              ),
            ),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Filter Payments',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_filters.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_filters.activeFilterCount}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<String>(
      value: _filters.paymentMethod,
      decoration: InputDecoration(
        hintText: 'All Methods',
        prefixIcon: const Icon(Icons.payment),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('All Methods')),
        DropdownMenuItem(value: 'ZAAD', child: Text('ZAAD')),
        DropdownMenuItem(value: 'eDahab', child: Text('eDahab')),
        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
        DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) {
        setState(() {
          _filters = _filters.copyWith(
            paymentMethod: value,
            clearPaymentMethod: value == null,
          );
        });
      },
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => _selectDate(context, true),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Start Date',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _filters.startDate != null
                  ? DateFormat('MMM dd, yyyy').format(_filters.startDate!)
                  : 'Select start date',
              style: TextStyle(
                color: _filters.startDate != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectDate(context, false),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'End Date',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _filters.endDate != null
                  ? DateFormat('MMM dd, yyyy').format(_filters.endDate!)
                  : 'Select end date',
              style: TextStyle(
                color: _filters.endDate != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        if (_filters.startDate != null || _filters.endDate != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _filters = _filters.copyWith(clearDates: true);
              });
            },
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear Dates'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[700],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_filters.startDate ?? DateTime.now())
          : (_filters.endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _filters = _filters.copyWith(startDate: picked);
        } else {
          _filters = _filters.copyWith(endDate: picked);
        }
      });
    }
  }

  Widget _buildAmountRangeInputs() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Min Amount',
              prefixText: '\$',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value);
              setState(() {
                _filters = _filters.copyWith(
                  minAmount: amount,
                  clearAmounts: amount == null,
                );
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _maxAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Max Amount',
              prefixText: '\$',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value);
              setState(() {
                _filters = _filters.copyWith(
                  maxAmount: amount,
                  clearAmounts: amount == null,
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _filters.status,
      decoration: InputDecoration(
        hintText: 'All Statuses',
        prefixIcon: const Icon(Icons.info_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('All Statuses')),
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'approved', child: Text('Approved')),
        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
      ],
      onChanged: (value) {
        setState(() {
          _filters = _filters.copyWith(
            status: value,
            clearStatus: value == null,
          );
        });
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _filters = _filters.clear();
                  _minAmountController.clear();
                  _maxAmountController.clear();
                });
                widget.onClear?.call();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onApply(_filters);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check),
              label: const Text('Apply Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
