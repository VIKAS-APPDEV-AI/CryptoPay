import 'package:flutter/material.dart';

class InputCustomizado extends StatefulWidget {
  const InputCustomizado({
    super.key,
    required this.hint,
    this.obscure = false,
    this.icon = const Icon(Icons.person),
    this.controller,
    this.validator,
  });

  final String hint;
  final bool obscure;
  final Icon icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  State<InputCustomizado> createState() => _InputCustomizadoState();
}

class _InputCustomizadoState extends State<InputCustomizado> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _isObscure,
        validator: widget.validator,
        decoration: InputDecoration(
          icon: widget.icon,
          border: InputBorder.none,
          hintText: widget.hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}