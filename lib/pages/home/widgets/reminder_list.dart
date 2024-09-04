import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReminderList extends StatelessWidget {
  final List<Reminder> reminders;

  const ReminderList({super.key, required this.reminders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              backgroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              // Tindakan ketika tombol ditekan
              if (kDebugMode) {
                print('Reminder: ${reminders[index].title} ditekan');
              }
            },
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.notifications, color: Colors.white),
              ),
              title: reminders[index].title,
              subtitle: reminders[index].description,
              trailing: 
              Padding(
              padding: const EdgeInsets.only(right: 0.0),  // Menambahkan jarak di sisi kanan
              child: PopupMenuButton<String>(
                onSelected: (String value) {
                  switch (value) {
                    case 'periksa':
                      // Aksi untuk "Periksa"
                      if (kDebugMode) {
                        print('Periksa ${reminders[index].title}');
                      }
                      break;
                    case 'remind_later':
                      // Aksi untuk "Remind Later"
                      if (kDebugMode) {
                        print('Remind Later for ${reminders[index].title}');
                      }
                      break;
                    case 'hapus':
                      // Aksi untuk "Hapus"
                      if (kDebugMode) {
                        print('Hapus ${reminders[index].title}');
                      }
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'periksa',
                    child: Text('Periksa'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'remind_later',
                    child: Text('Remind Later'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'hapus',
                    child: Text('Hapus'),
                  ),
                ],
                icon: const Icon(Icons.more_vert), // Ikon titik tiga
              ),
            ),
          ),
          ),
        );
      },
      shrinkWrap: true,  // This allows ListView to size itself based on its contents
      physics: const NeverScrollableScrollPhysics(),  // This prevents ListView from scrolling
    );
  }
}

// Kelas Reminder
class Reminder {
  final Text title;
  final Text description;

  Reminder({required this.title, required this.description});
}