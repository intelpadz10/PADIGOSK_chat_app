import 'package:chat_app/src/models/chat_message_model.dart';
import 'package:flutter/material.dart';

class InputWidget extends StatefulWidget {
  final String? message;
  final ChatMessage chat;

  const InputWidget({this.message, required this.chat, Key? key})
      : super(key: key);

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  final TextEditingController _messageController = TextEditingController();

  String? get message => widget.message;
  ChatMessage get chat => widget.chat;

  @override
  void initState() {
    if (message != null) _messageController.text = message as String;
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState?.validate();
          setState(() {});
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message != null ? 'Edit Message' : 'Type a Message'),
            TextFormField(
              controller: _messageController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: (_formKey.currentState?.validate() ?? false)
                  ? () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.of(context).pop();
                        chat.EditMessage(_messageController.text);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  primary: (_formKey.currentState?.validate() ?? false)
                      ? const Color.fromARGB(255, 117, 37, 216)
                      : Colors.grey),
              child: Text(message != null ? 'Edit' : 'Edit'),
            )
          ],
        ),
      ),
    );
  }
}
