import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/auth.dart';

//Drawer để chuyển giữa product overview và order
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('MyMess'),
            automaticallyImplyLeading: false,
            /*Dòng này để nó ko bao h thêm cái nút quay lại (vì nó là AppBar) vì
            nút quay lại sẽ ko hoạt động đc ở đây*/
          ),

          const Divider(), //1 cái dòng như <hr>
          ListTile(
            //Ấn vào cái này để quay về Home Page
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),

          const Divider(),
          ListTile(
            //Ấn vào cái này để đến Logout
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              /*trg khi logout thì phải tắt drawer đi ko nó sẽ lỗi
              (video thì lỗi thôi chứ code của mình cx chả lỗi)*/
              Navigator.of(context).pop();
              //chuyển về home route trc khi logout, để tránh bị mấy lỗi linh tinh
              Navigator.of(context).pushReplacementNamed('/');
              //gọi đến logout của auth.dart
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
