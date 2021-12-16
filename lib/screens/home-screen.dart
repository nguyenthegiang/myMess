import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../widgets/app_drawer.dart';
import '../screens/new_message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Biến để cho didChangeDependencies() chỉ chạy 1 lần thôi
  var _isInit = true;
  //biến để làm loading spinner
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        //chuyển màn hình sang loading
        _isLoading = true;
      });

      /* Khi mới vào home screen thì load list message*/
      // Provider.of<Products>(context).fetchAndSetProducts().then((_) {
      //   setState(() {
      //     //chuyển màn hình lại bình thường sau khi lấy data xong
      //     _isLoading = false;
      //   });
      // });

      _isLoading = false;
    }
    _isInit = false;
    super.didChangeDependencies();
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
        body: Padding(
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
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    hintText: 'Tìm kiếm',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              /*Message List - sau này chuyển thành ListView.builder và 
              ListTile tách ra Widget riêng*/
              Container(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    150,
                child: ListView(
                  children: [
                    Card(
                      elevation: 5,
                      child: ListTile(
                        title: Text('Nguyen The Giang'),
                        subtitle: Text('Message sent'),
                        leading: CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/default-avatar.png'),
                        ),
                        trailing: Icon(Icons.check_circle),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      child: ListTile(
                        title: Text('Nguyen The Giang'),
                        subtitle: Text('Message sent'),
                        leading: CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/default-avatar.png'),
                        ),
                        trailing: Icon(Icons.check_circle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
