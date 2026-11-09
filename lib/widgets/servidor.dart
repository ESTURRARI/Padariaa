import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Diálogo para trocar o endereço do servidor (útil em celular real).
Future<bool> editarServidor(BuildContext context) async {
  final c = TextEditingController(text: await ApiService.baseUrl());
  if (!context.mounted) return false;
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Endereço do servidor'),
      content: TextField(controller: c, decoration: const InputDecoration(helperText: 'Ex.: http://192.168.0.10:8000')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
      ],
    ),
  );
  if (ok == true) {
    await ApiService.salvarUrl(c.text.trim());
    return true;
  }
  return false;
}
