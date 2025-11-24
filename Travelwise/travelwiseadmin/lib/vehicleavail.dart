import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> syncVehicleAvailabilityForVehicle(
    {required String vehicleDocId, int days = 10}) async {
  final DateFormat dateFormatDocId = DateFormat('yyyyMMdd');
  final DateFormat dateFormatReadable = DateFormat('yyyy-MM-dd');
  final DateTime today = DateTime.now();

  // Get the vehicle document
  final DocumentSnapshot vehicleDoc =
      await firestore.collection('vehicles').doc(vehicleDocId).get();

  if (!vehicleDoc.exists) {
    print('Vehicle $vehicleDocId does not exist.');
    return;
  }

  final data = vehicleDoc.data() as Map<String, dynamic>?;

  if (data == null || !data.containsKey('vehicleid')) {
    print('Vehicle document $vehicleDocId has no vehicleId field, skipping...');
    return;
  }

  final String vehicleId = data['vehicleid'].toString();
  final int totalCount = data['number'] ?? 0;

  final CollectionReference availabilityCol =
      firestore.collection('vehicles').doc(vehicleDocId).collection('availability');

  // Check if the vehicle has any availability documents
  final QuerySnapshot availabilitySnapshot = await availabilityCol.limit(1).get();
  final bool isNewVehicle = availabilitySnapshot.docs.isEmpty;

  DateTime startDate;
  int totalDays;

  if (isNewVehicle) {
    startDate = today;
    totalDays = 60;
    print('New vehicle $vehicleId: creating 60 days of availability');
  } else {
    startDate = today;
    totalDays = days;
    print('Existing vehicle $vehicleId: updating $days days from today');
  }

  // Batch write to Firestore
  WriteBatch batch = firestore.batch();
  int batchCount = 0;

  for (int i = 0; i < totalDays; i++) {
    final DateTime date = startDate.add(Duration(days: i));
    final String dateDocId = dateFormatDocId.format(date);
    final String dateReadable = dateFormatReadable.format(date);

    final DocumentReference dateDocRef = availabilityCol.doc(dateDocId);
    final DocumentSnapshot dateSnapshot = await dateDocRef.get();

    if (dateSnapshot.exists) {
      // Adjust availableCount proportionally based on totalCount change
      final existingData = dateSnapshot.data() as Map<String, dynamic>;
      final int oldTotalCount = existingData['totalCount'] ?? totalCount;
      final int currentAvailable = existingData['availableCount'] ?? totalCount;

      final int newAvailableCount =
          (currentAvailable + (totalCount - oldTotalCount)).clamp(0, totalCount);

      batch.update(dateDocRef, {
        'totalCount': totalCount,
        'availableCount': newAvailableCount,
      });
    } else {
      batch.set(dateDocRef, {
        'date': dateReadable,
        'totalCount': totalCount,
        'availableCount': totalCount,
      });
    }

    batchCount++;
    if (batchCount >= 400) {
      await batch.commit();
      batch = firestore.batch();
      batchCount = 0;
      print('Committed 400 availability docs for vehicle $vehicleId...');
    }
  }

  if (batchCount > 0) {
    await batch.commit();
    print('Committed remaining availability docs for vehicle $vehicleId');
  }

  print('✅ Synced availability for vehicle $vehicleId');
}
