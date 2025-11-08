import 'package:flutter/material.dart';
import 'package:limitless_flutter/components/buttons/adaptive.dart';
import 'package:limitless_flutter/components/error_snackbar.dart';
import 'package:limitless_flutter/supabase/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddCookieButton extends StatelessWidget {
  const AddCookieButton({super.key});

  Future<void> _openAddCookieDialog(BuildContext context) async {
    final client = getSupabaseClient();
    final user = getCurrentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(
          message: 'You must be logged in to add a cookie.',
        ).build(),
      );
      return;
    }

    final controller = TextEditingController();
    bool submitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> submit() async {
              final text = controller.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Type something first 🙂')),
                );
                return;
              }
              setState(() => submitting = true);
              try {
                await client.from('accomplishments').insert({
                  'user_id': user.id,
                  'content': text,
                });
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cookie added! 🎉')),
                  );
                }
              } on PostgrestException catch (e) {
                setState(() => submitting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add cookie: ${e.message}')),
                );
              } catch (_) {
                setState(() => submitting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Something went wrong.')),
                );
              }
            }

            return AlertDialog(
              title: const Text('Add Cookie'),
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLength: 200,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "What did you accomplish?",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) {
                  if (!submitting) submit();
                },
              ),
              actions: [
                TextButton(
                  onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: submitting ? null : submit,
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveButton(
      buttonText: 'Add Cookie',
      onPressed: () => _openAddCookieDialog(context),
    );
  }
}
