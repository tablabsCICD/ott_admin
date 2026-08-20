import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType textInputType;
  final int maxLine;
  final bool isPhoneNumber;
  final bool isValidator;
  final dynamic validator;
  final bool isEmail;
  final bool isName;
  final bool isDigits;
  final TextCapitalization capitalization;
  final IconData? iconData;
  final bool isPassword;
  final bool? readOnly;
  final String? validatorMsg;
  final String? label;
  final Function? onTap;
  final Function(String)? onValueChange;
  final IconData? suffixIcon;
  final Widget? prefixIcon;

  const CustomTextField({
    required this.controller,
    required this.hintText,
    required this.textInputType,
    this.maxLine = 1,
    this.isPhoneNumber = false,
    this.isValidator = true,
    this.isEmail = false,
    this.isName = false,
    this.isDigits = false,
    this.capitalization = TextCapitalization.none,
    this.iconData,
    this.isPassword = false,
    this.readOnly,
    this.onTap,
    this.label,
    this.onValueChange,
    this.suffixIcon,
    this.prefixIcon,
    super.key,
    this.validatorMsg,
    this.validator,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.label!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _isObscure : false,
            keyboardType: widget.textInputType,
            textCapitalization: widget.capitalization,
            readOnly: widget.readOnly ?? false,
            maxLines: widget.maxLine,
            cursorColor: const Color(0xFFE50914),
            inputFormatters: widget.isPhoneNumber
                ? [FilteringTextInputFormatter.digitsOnly]
                : [FilteringTextInputFormatter.singleLineFormatter],
            validator: _buildValidator(),
            onChanged: widget.onValueChange,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardColor,
              hintText: widget.hintText,
              hintStyle: const TextStyle(fontSize: 14),
              // Border properties
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color: Colors.grey[400]!), // Default border color
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color: Colors.grey[400]!), // Border color when enabled
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2), // Border color when focused
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context).canvasColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    )
                  : widget.suffixIcon != null
                      ? Icon(
                          widget.suffixIcon,
                          color: Theme.of(context).canvasColor,
                        )
                      : null,
              prefixIcon: widget.prefixIcon,
            ),
          ),
        ],
      ),
    );
  }

  String? Function(String?)? _buildValidator() {
    if (!widget.isValidator) return null;
    if (widget.isPhoneNumber) {
      return Validators.compose([
        Validators.required('Phone number is required'),
        Validators.minLength(10, 'Mobile number cannot be less than 10 digits'),
        Validators.maxLength(
            10, 'Mobile number cannot be greater than 10 digits'),
      ]);
    } else if (widget.isEmail) {
      return Validators.compose([
        Validators.required('Email is required'),
        Validators.email('Invalid email address'),
      ]);
    } else if (widget.isName) {
      return Validators.compose([
        Validators.patternString(r"^[A-Za-z]+$", 'Only alphabets are allowed'),
        Validators.required('${widget.hintText} is required'),
      ]);
    } else if (widget.isDigits) {
      return Validators.compose([
        Validators.patternRegExp(
            RegExp(r"^[0-9]*$"), 'Only digits are allowed'),
        Validators.required('${widget.hintText} is required'),
      ]);
    } else {
      return Validators.required('This field is required');
    }
  }
}
