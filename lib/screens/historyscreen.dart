import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF226f54),
        title: const Text('Saved Plots', style: TextStyle(color: Color(0xFFf4f0bb)),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('savedPlots')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading history'));
          }

          final plots = snapshot.data!.docs;

          if (plots.isEmpty) {
            return const Center(child: Text('No saved plots found.'));
          }

          return ListView.builder(
            itemCount: plots.length,
            itemBuilder: (context, index) {
              final plot = plots[index];
              final String imageUrl = plot['imageUrl'];
              final String title = plot['title'];
              final String date = plot['date'];

              return ListTile(
                leading: const Icon(Icons.show_chart),
                title: Text(title),
                subtitle: Text(date),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePlot(plot.id, imageUrl),
                ),
                onTap: () => _showImageDialog(context, imageUrl),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deletePlot(String plotId, String imageUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      await FirebaseFirestore.instance
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('savedPlots')
          .doc(plotId)
          .delete();
      print('Plot deleted successfully.');
    } catch (e) {
      print('Error deleting plot: $e');
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Image.network(imageUrl),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
