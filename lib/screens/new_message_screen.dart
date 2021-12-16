import 'package:flutter/material.dart';
import 'package:my_mess/providers/auth.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  static const routeName = 'new-message';

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  @override
  Widget build(BuildContext context) {
    //lấy username để hiển thị
    final username = Provider.of<Auth>(context).username;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tin nhắn mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Send to
              Container(
                height: 80,
                child: Row(
                  children: [
                    Text(
                      'Tới: ',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 10),
                    //Input send to
                    Container(
                      width: 300,
                      child: TextFormField(
                        decoration:
                            InputDecoration(hintText: 'Nhập tên người dùng'),
                      ),
                    ),
                  ],
                ),
              ),

              //Message Content
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    //Input Message
                    Container(
                      width: 300,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'Nhập tin nhắn',
                        ),
                        style: TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ),

                    //Submit
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        bottom: 6,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.send,
                          size: 35,
                          color: Color.fromRGBO(31, 105, 36, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
