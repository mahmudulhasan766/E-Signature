import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_signature/core/errors/exceptions.dart';
import 'package:e_signature/features/document/data/models/document_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

abstract class DocumentRemoteDataSource {
  Future<DocumentModel> uploadDocument(File file, String userId);
  Future<List<DocumentModel>> getDocuments(String userId);
  Future<DocumentModel> getDocument(String documentId);
  Future<void> updateDocument(DocumentModel document);
  Future<void> deleteDocument(String documentId);
  Future<String> uploadFileToStorage(File file, String userId);
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  DocumentRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<DocumentModel> uploadDocument(File file, String userId) async {
    try {
      final fileUrl = await uploadFileToStorage(file, userId);
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();

      final docRef = firestore.collection('documents').doc();

      final document = DocumentModel(
        id: docRef.id,
        name: fileName,
        filePath: fileUrl,
        userId: userId,
        fields: [],
        isPublished: false,
        createdAt: DateTime.now(),
        fileType: fileExtension,
      );

      await docRef.set(document.toFirestore());

      return document;
    } catch (e) {
      throw ServerException('Failed to upload document: $e');
    }
  }

  @override
  Future<String> uploadFileToStorage(File file, String userId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = storage.ref().child('documents/$userId/$fileName');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw ServerException('Failed to upload file to storage: $e');
    }
  }

  @override
  Future<List<DocumentModel>> getDocuments(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('documents')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get documents: $e');
    }
  }

  @override
  Future<DocumentModel> getDocument(String documentId) async {
    try {
      final docSnapshot = await firestore
          .collection('documents')
          .doc(documentId)
          .get();

      if (!docSnapshot.exists) {
        throw ServerException('Document not found');
      }

      return DocumentModel.fromFirestore(docSnapshot.data()!, docSnapshot.id);
    } catch (e) {
      throw ServerException('Failed to get document: $e');
    }
  }

  @override
  Future<void> updateDocument(DocumentModel document) async {
    try {
      await firestore
          .collection('documents')
          .doc(document.id)
          .update(document.toFirestore());
    } catch (e) {
      throw ServerException('Failed to update document: $e');
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await firestore.collection('documents').doc(documentId).delete();
    } catch (e) {
      throw ServerException('Failed to delete document: $e');
    }
  }
}