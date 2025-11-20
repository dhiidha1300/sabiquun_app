import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/excuses/domain/entities/excuse_entity.dart';
import 'package:sabiquun_app/features/excuses/presentation/bloc/excuse_bloc.dart';
import 'package:sabiquun_app/features/excuses/presentation/bloc/excuse_event.dart';
import 'package:sabiquun_app/features/excuses/presentation/bloc/excuse_state.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_event.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_state.dart';

class SubmitExcusePage extends StatefulWidget {
  const SubmitExcusePage({super.key});

  @override
  State<SubmitExcusePage> createState() => _SubmitExcusePageState();
}

class _SubmitExcusePageState extends State<SubmitExcusePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  ExcuseType _selectedType = ExcuseType.sickness;
  final Set<String> _selectedDeeds = {};
  bool _allDeedsSelected = true;
  final _descriptionController = TextEditingController();
  List<String> _availableDeeds = [];

  @override
  void initState() {
    super.initState();
    // Load deed templates to show available deeds
    context.read<DeedBloc>().add(const LoadDeedTemplatesRequested());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitExcuse() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        return;
      }

      final affectedDeeds = _allDeedsSelected ? <String>[] : _selectedDeeds.toList();

      context.read<ExcuseBloc>().add(
        CreateExcuseRequested(
          userId: authState.user.id,
          excuseDate: _selectedDate!,
          excuseType: _selectedType,
          affectedDeeds: affectedDeeds,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Excuse'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ExcuseBloc, ExcuseState>(
            listener: (context, state) {
              if (state is ExcuseCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Excuse submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Navigate back and trigger excuse history reload
                context.pop();

                // Reload excuses after successful submission
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  context.read<ExcuseBloc>().add(
                    LoadMyExcusesRequested(
                      userId: authState.user.id,
                      status: null,
                    ),
                  );
                }
              } else if (state is ExcuseError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<DeedBloc, DeedState>(
            listener: (context, state) {
              if (state is DeedTemplatesLoaded) {
                setState(() {
                  _availableDeeds = state.templates
                      .map((t) => t.deedName)
                      .toList();
                });
              }
            },
          ),
        ],
        child: BlocBuilder<ExcuseBloc, ExcuseState>(
          builder: (context, state) {
            final isLoading = state is ExcuseLoading;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date Selection
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                        title: const Text('Excuse Date'),
                        subtitle: Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Tap to select date',
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: isLoading ? null : _selectDate,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Excuse Type
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Excuse Type',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<ExcuseType>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: ExcuseType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedType = value;
                                        });
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Affected Deeds
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Affected Deeds',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CheckboxListTile(
                              title: const Text(
                                'All Deeds',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              value: _allDeedsSelected,
                              activeColor: const Color(0xFF2E7D32),
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _allDeedsSelected = value ?? true;
                                        if (_allDeedsSelected) {
                                          _selectedDeeds.clear();
                                        }
                                      });
                                    },
                            ),
                            if (!_allDeedsSelected) ...[
                              const Divider(),
                              if (_availableDeeds.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              else
                                ..._availableDeeds.map((deed) {
                                  return CheckboxListTile(
                                    title: Text(deed),
                                    value: _selectedDeeds.contains(deed),
                                    activeColor: const Color(0xFF2E7D32),
                                    onChanged: isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              if (value == true) {
                                                _selectedDeeds.add(deed);
                                              } else {
                                                _selectedDeeds.remove(deed);
                                              }
                                            });
                                          },
                                  );
                                }),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description (Optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descriptionController,
                              enabled: !isLoading,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Provide additional details...',
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _submitExcuse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit Excuse',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
