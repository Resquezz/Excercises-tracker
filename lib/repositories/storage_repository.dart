import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print('Failed to pick image: $e');
      return null;
    }
  }

  Future<String> uploadTrainingImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = 'trainings/${user.uid}/$fileName';

      final ref = _storage.ref(filePath);
      final uploadTask = ref.putFile(imageFile);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Failed to upload image: $e');
      rethrow;
    }
  }
  Future<void> deleteImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }
}