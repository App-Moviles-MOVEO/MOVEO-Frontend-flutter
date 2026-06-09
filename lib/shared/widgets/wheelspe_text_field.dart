import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';

/// Campo de texto estándar de WheelsPe con label, toggle de contraseña
/// y soporte de accesibilidad.
class WheelsPeTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final int maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;
  final TextCapitalization textCapitalization;

  const WheelsPeTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.prefix,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<WheelsPeTextField> createState() => _WheelsPeTextFieldState();
}

class _WheelsPeTextFieldState extends State<WheelsPeTextField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.subtitle),
        const SizedBox(height: 8),
        Semantics(
          label: widget.label,
          textField: true,
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscured,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            textCapitalization: widget.textCapitalization,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefix,
              counterStyle: AppTextStyles.caption,
              suffixIcon: widget.obscure
                  ? Semantics(
                      label: _obscured
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      button: true,
                      child: IconButton(
                        icon: Icon(
                          _obscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscured = !_obscured),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
