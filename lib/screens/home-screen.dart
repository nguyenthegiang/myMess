import 'package:flutter/material.dart';
import 'package:my_mess/models/user.dart';
import 'package:my_mess/widgets/message_item.dart';

import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../widgets/app_drawer.dart';
import '../screens/new_message_screen.dart';
import '../providers/message_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //function để refresh lại list friends
  Future<void> _refreshFriendList(BuildContext context) async {
    await Provider.of<MessageProvider>(
      context,
      listen: false,
    ).getFriends();
  }

  @override
  Widget build(BuildContext context) {
    //lấy username để hiển thị
    final username = Provider.of<Auth>(context).username;

    return Scaffold(
      appBar: AppBar(
        title: Text('MyMess - $username'),
        actions: [
          //Nhấn nút này để chuyển sang NewMessageScreen
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(NewMessageScreen.routeName);
            },
            icon: const Icon(Icons.edit_sharp),
            tooltip: 'Tạo tin nhắn mới',
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        //tính năng pull to refresh
        future: _refreshFriendList(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshFriendList(context),
                child: Consumer<MessageProvider>(
                  builder: (ctx, messageData, _) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        //Searchbox - Not implemented yet
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                              hintText: 'Tìm kiếm (Tính năng này chưa hỗ trợ)',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),

                        /*Message List*/
                        Container(
                          height: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              150,
                          child: ListView.builder(
                            itemCount: messageData.friends.length,
                            itemBuilder: (_, i) => MessageItem(
                              user: messageData.friends[i],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
