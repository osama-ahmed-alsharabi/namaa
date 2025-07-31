import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaa/cores/assets.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/features/chat/view_model/cubit/chat_cubit.dart';
import 'package:namaa/main.dart';

class ChatScreen extends StatelessWidget {
  final TextEditingController _messageController = TextEditingController();

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFEF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 70,
        title: const Text("درهم..."),
        leading: Image.asset(imagesApp[1]),
        actions: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: IconButton(onPressed: () {
              Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back_ios_new_rounded))),
        ],
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ChatInitial || state is ChatLoading) {
            return const Center(child: CircularProgressIndicator(
              color: AppColors.brownColor,
            ));
          }

          if (state is ChatError) {
            return Center(child: Text(state.message));
          }

          if (state is ChatLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages.reversed.toList()[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: AppColors.brownColor,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3 ,vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration:  InputDecoration(
                            hintText: "أرسل الرسالة ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25)
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.brownColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send ,),
                          onPressed: () {
                            final message = _messageController.text.trim();
                            if (message.isNotEmpty) {
                              context.read<ChatCubit>().sendMessage(message);
                              _messageController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color.fromARGB(255, 219, 218, 218)
              : const Color.fromRGBO(217, 208, 154, 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }
}
