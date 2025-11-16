import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Filter bottom sheet for user reports
class FilterBottomSheet extends StatefulWidget {
  final String? membershipFilter;
  final String? complianceFilter;
  final String? reportStatusFilter;
  final String sortBy;
  final Function(String?, String?, String?, String) onApply;
  final VoidCallback onClear;

  const FilterBottomSheet({
    super.key,
    this.membershipFilter,
    this.complianceFilter,
    this.reportStatusFilter,
    required this.sortBy,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _membership;
  String? _compliance;
  String? _reportStatus;
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    _membership = widget.membershipFilter;
    _compliance = widget.complianceFilter;
    _reportStatus = widget.reportStatusFilter;
    _sortBy = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // Filters
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Membership Status
                  const Text(
                    'Membership Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('New', _membership, (value) {
                        setState(() => _membership = value);
                      }),
                      _buildFilterChip('Exclusive', _membership, (value) {
                        setState(() => _membership = value);
                      }),
                      _buildFilterChip('Legacy', _membership, (value) {
                        setState(() => _membership = value);
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Compliance Rate
                  const Text(
                    'Compliance Rate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('High (90%+)', _compliance, (value) {
                        setState(() => _compliance = value);
                      }),
                      _buildFilterChip('Medium (70-89%)', _compliance, (value) {
                        setState(() => _compliance = value);
                      }),
                      _buildFilterChip('Low (<70%)', _compliance, (value) {
                        setState(() => _compliance = value);
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Report Status
                  const Text(
                    'Today\'s Report Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('Submitted', _reportStatus, (value) {
                        setState(() => _reportStatus = value);
                      }),
                      _buildFilterChip('Not Submitted', _reportStatus, (value) {
                        setState(() => _reportStatus = value);
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sort By
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSortChip('Name (A-Z)', 'name'),
                      _buildSortChip('Compliance (High)', 'compliance'),
                      _buildSortChip('Last Report (Recent)', 'recent'),
                      _buildSortChip('Balance (High)', 'balance'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _membership = null;
                        _compliance = null;
                        _reportStatus = null;
                        _sortBy = 'name';
                      });
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_membership, _compliance, _reportStatus, _sortBy);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? currentValue, Function(String?) onTap) {
    final isSelected = currentValue == label;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onTap(selected ? label : null);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _sortBy = value);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
