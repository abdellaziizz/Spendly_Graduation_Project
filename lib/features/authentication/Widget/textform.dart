import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Textform extends ConsumerWidget {
  const Textform({
    super.key,
    required this.controller,
    required this.ispassword,
    required this.label,
    required this.hint,
    required this.obscureTextProvider,
  });
  final TextEditingController controller;
  final bool ispassword;
  final String label;
  final String hint;
  final StateProvider<bool> obscureTextProvider;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObscured = ref.watch(obscureTextProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return ispassword ? 'Password is required' : 'Email is required';
          }

          if (value.length < 6) {
            return ispassword
                ? 'Password must be at least 6 characters'
                : 'Enter a valid email';
          }

          return null;
        },
        decoration: InputDecoration(
          suffixIcon: ispassword
              ? IconButton(
                  onPressed: () {
                    ref.read(obscureTextProvider.notifier).state = !isObscured;
                  },
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                  ),
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
          ),
          label: Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          hintText: hint,
        ),
        obscureText: ispassword ? isObscured : false,
      ),
    );
  }
}
