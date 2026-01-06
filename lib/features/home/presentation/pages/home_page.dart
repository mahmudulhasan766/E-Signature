import 'package:e_signature/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:e_signature/features/document/presentation/cubit/document_cubit.dart';
import 'package:e_signature/features/document/presentation/pages/upload_document_page.dart';
import 'package:e_signature/features/home/presentation/widgets/document_list_view.dart';
import 'package:e_signature/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../authentication/presentation/cubit/auth_state.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key, required user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Signature'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (_) => sl<DocumentCubit>()
          ..getDocuments(
            (context.read<AuthCubit>().state as AuthAuthenticated).user.id,
          ),
        child: const DocumentListView(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToUpload(context),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Document'),
      ),
    );
  }

  void _navigateToUpload(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthCubit>(),
          child: const UploadDocumentPage(),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}