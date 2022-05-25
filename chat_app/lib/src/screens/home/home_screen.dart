import 'package:chat_app/src/controllers/chat_controller.dart';
import 'package:chat_app/src/models/chat_user_model.dart';
import 'package:chat_app/widget/input_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_moment/simple_moment.dart';

import '../../../service_locators.dart';
import '../../controllers/auth_controller.dart';
import '../../models/chat_message_model.dart';

class HomeScreen extends StatefulWidget {
  static const String route = 'home-screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _auth = locator<AuthController>();
  final ChatController _chatController = ChatController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFN = FocusNode();
  final ScrollController _scrollController = ScrollController();

  ChatUser? user;

  @override
  void initState() {
    ChatUser.fromUid(uid: FirebaseAuth.instance.currentUser!.uid).then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });
    _chatController.addListener(scrollToBottom);
    super.initState();
  }

  scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 250));
    print('scrolling to bottom');
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        curve: Curves.easeIn, duration: const Duration(milliseconds: 250));
  }

  @override
  void dispose() {
    _chatController.removeListener(scrollToBottom);
    _messageFN.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user != null ? user!.username : '. . .'),
        backgroundColor: Color.fromARGB(255, 148, 37, 199),
        actions: [
          IconButton(
              onPressed: () async {
                _auth.logout();
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromARGB(255, 148, 37, 199),
                Color.fromARGB(255, 251, 45, 114)
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: AnimatedBuilder(
                    animation: _chatController,
                    builder: (context, Widget? w) {
                      return SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            for (ChatMessage chat in _chatController.chats)
                              GestureDetector(
                                  onLongPress: () {
                                    if (chat.sentBy ==
                                        FirebaseAuth
                                            .instance.currentUser?.uid) {
                                      showEditDialog(context, chat);
                                    } else {
                                      NoAccessdialog(context);
                                    }
                                  },
                                  onDoubleTap: () {
                                    if (chat.sentBy ==
                                        FirebaseAuth
                                            .instance.currentUser?.uid) {
                                      DeleteDialog(context, chat);
                                    } else {
                                      NoAccessdialog(context);
                                    }
                                  },
                                  child: ChatCard(chat: chat))
                          ],
                        ),
                      );
                    }),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onFieldSubmitted: (String text) {
                          send();
                        },
                        focusNode: _messageFN,
                        controller: _messageController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Color.fromARGB(255, 251, 250, 251),
                      ),
                      onPressed: send,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  send() {
    _messageFN.unfocus();
    if (_messageController.text.isNotEmpty) {
      _chatController.sendMessage(message: _messageController.text.trim());
      _messageController.text = '';
    }
  }

  showEditDialog(BuildContext context, ChatMessage editMessage) async {
    ChatMessage? newMessage = await showDialog<ChatMessage>(
        context: context,
        builder: (dContext) {
          return Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: InputWidget(message: editMessage.message, chat: editMessage),
          );
        });
  }

  NoAccessdialog(BuildContext context) async {
    ChatMessage? newMessage = await showDialog<ChatMessage>(
        context: context,
        builder: (dContext) {
          return const Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Text('You are not allowed to Access this Text'),
          );
        });
  }

  void DeleteDialog(BuildContext context, ChatMessage message) {
    showDialog(
        context: context,
        builder: (dContext) {
          return AlertDialog(
            title: const Text('Are you sure you want to remove this message?'),
            // content: const Text('Delete this message?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No')),
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    message.DeleteMessage('You deleted a Message');
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes')),
            ],
          );
        });
  }
}

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.chat,
  }) : super(key: key);

  final ChatMessage chat;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Moment.fromDateTime(chat.ts.toDate())
              .format('MMMM dd, yyyy hh:mm aa'),
          style: const TextStyle(
            color: Color.fromARGB(255, 218, 221, 223),
          ),
        ),
        Container(
          margin: chat.sentBy == FirebaseAuth.instance.currentUser?.uid
              ? const EdgeInsets.only(top: 10, bottom: 5, right: 10, left: 100)
              : const EdgeInsets.only(top: 10, bottom: 5, right: 100, left: 10),
          padding: const EdgeInsets.all(15),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: chat.sentBy == FirebaseAuth.instance.currentUser?.uid
                ? const Color.fromARGB(255, 230, 224, 132)
                : const Color.fromARGB(255, 130, 226, 207),
            borderRadius: chat.sentBy == FirebaseAuth.instance.currentUser?.uid
                ? const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.elliptical(90, 30),
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.elliptical(90, 30))
                : const BorderRadius.only(
                    topLeft: Radius.elliptical(90, 30),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.elliptical(90, 30),
                    bottomLeft: Radius.circular(10),
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  color: chat.sentBy == FirebaseAuth.instance.currentUser?.uid
                      ? Color.fromARGB(255, 230, 224, 132)
                      : const Color.fromARGB(255, 130, 226, 207),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FutureBuilder<ChatUser>(
                          future: ChatUser.fromUid(uid: chat.sentBy),
                          builder: (context, AsyncSnapshot<ChatUser> snap) {
                            if (snap.hasData) {
                              return Text(
                                chat.sentBy ==
                                        FirebaseAuth.instance.currentUser?.uid
                                    ? 'You sent:'
                                    : '${snap.data?.username} sent',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 120, 121, 122),
                                ),
                              );
                            }
                            return const Text('Getting user...');
                          }),
                      Container(
                          margin: const EdgeInsets.only(
                              top: 10, bottom: 10, left: 20),
                          child: Text(chat.message)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
