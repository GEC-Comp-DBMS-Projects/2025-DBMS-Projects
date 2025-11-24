import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> updateRoomAvailabilityForEditedHotel(String hotelDocId) async {
  final DateFormat dateFormatDocId = DateFormat('yyyyMMdd');
  final DateFormat dateFormatReadable = DateFormat('yyyy-MM-dd');
  final DateTime today = DateTime.now();

  final hotelRef = firestore.collection('Hotels').doc(hotelDocId);

  // Get all room types for this hotel
  final QuerySnapshot roomTypesSnapshot = await hotelRef.collection('Roomtype').get();
  if (roomTypesSnapshot.docs.isEmpty) {
    print('No room types found for hotel $hotelDocId, skipping...');
    return;
  }

  final List<Map<String, dynamic>> roomTypes = roomTypesSnapshot.docs.map((doc) {
    final roomData = doc.data() as Map<String, dynamic>;
    final int totalRooms = (roomData['Rooms'] is int) ? roomData['Rooms'] : 0;
    return {
      'roomType': doc.id,
      'totalCount': totalRooms,
    };
  }).toList();

  final CollectionReference roomAvailabilityCol = hotelRef.collection('roomavailability');

  // Get all existing room availability documents from today onwards
  final QuerySnapshot availabilitySnapshot = await roomAvailabilityCol
      .where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(today))
      .get();

  WriteBatch batch = firestore.batch();
  int batchCount = 0;

  for (var doc in availabilitySnapshot.docs) {
    final Map<String, dynamic> availabilityData = doc.data() as Map<String, dynamic>;
    List<dynamic> availabilityList = List.from(availabilityData['availability'] ?? []);

    // Update existing rooms or add new ones
    for (var room in roomTypes) {
      final index = availabilityList.indexWhere((r) => r['roomType'] == room['roomType']);
      if (index >= 0) {
        // Existing room type: update totalCount and adjust availableCount
        int oldAvailable = availabilityList[index]['availableCount'] ?? 0;
        int oldTotal = availabilityList[index]['totalCount'] ?? 0;
        int bookedRooms = oldTotal - oldAvailable;
        int newTotal = room['totalCount'];
        int newAvailable = newTotal - bookedRooms;
        if (newAvailable < 0) newAvailable = 0;

        availabilityList[index]['totalCount'] = newTotal;
        availabilityList[index]['availableCount'] = newAvailable;
      } else {
        // New room type: add it
        availabilityList.add({
          'roomType': room['roomType'],
          'totalCount': room['totalCount'],
          'availableCount': room['totalCount'],
        });
      }
    }

    batch.update(doc.reference, {'availability': availabilityList});
    batchCount++;

    if (batchCount >= 400) {
      await batch.commit();
      batch = firestore.batch();
      batchCount = 0;
      print('Committed 400 availability docs for hotel $hotelDocId...');
    }
  }

  if (batchCount > 0) {
    await batch.commit();
    print('Committed remaining availability docs for hotel $hotelDocId');
  }

  print('✅ Updated room availability for hotel $hotelDocId from today to last date');
}
