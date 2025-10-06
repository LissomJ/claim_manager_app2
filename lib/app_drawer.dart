// lib/app_drawer.dart

import 'package:flutter/material.dart';
import 'pending_cases_screen.dart';
import 'closed_cases_screen.dart';
import 'todo_list_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 화면의 경로 이름을 가져옵니다.
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey),
            child: Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('미결 관리'),
            // 현재 화면이면 파란색으로 표시
            selected: currentRoute == '/',
            onTap: () {
              Navigator.of(context).pop(); // 메뉴를 먼저 닫습니다.
              // 현재 화면이 아닐 경우에만 이동합니다.
              if (currentRoute != '/') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const PendingCasesScreen(), settings: const RouteSettings(name: '/')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_zip),
            title: const Text('종결 관리'),
            selected: currentRoute == '/closed',
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute != '/closed') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ClosedCasesScreen(), settings: const RouteSettings(name: '/closed')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('전체 할 일'),
            selected: currentRoute == '/todos',
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute != '/todos') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ToDoListScreen(), settings: const RouteSettings(name: '/todos')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}