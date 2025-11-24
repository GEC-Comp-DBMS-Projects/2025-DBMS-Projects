import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';

const steps = ['Welcome', 'Document Upload', 'Data Review', 'Tax Calculation', 'Step 5', 'Step 6', 'Step 7', 'Step 8'];

const UploadedDocumentsScreen = ({ navigation }) => {
  const uploadedDocs = [
    { name: 'Form 16', uploaded: true },
    { name: 'Form 26AS / AIS', uploaded: true },
    { name: 'Investment Proofs', uploaded: false },
    { name: 'Capital Gains Statement', uploaded: false },
  ];

  return (
    <View style={styles.container}>
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.stepsContainer}>
        {steps.map((step, index) => (
          <View key={index} style={[styles.stepCircle, index <= 2 && styles.activeStep]}>
            <Text style={[styles.stepText, index <= 2 && styles.activeStepText]}>{index + 1}</Text>
          </View>
        ))}
      </ScrollView>
      <Text style={styles.title}>Upload Your Documents</Text>
      <Text style={styles.subtitle}>Uploaded documents and extraction status</Text>

      <ScrollView style={{ marginTop: 20 }}>
        {uploadedDocs.map((doc, index) => (
          <View key={index} style={styles.docCard}>
            <Text style={styles.docName}>{doc.name}</Text>
            <View style={styles.uploadBox}>
              <Text style={{ color: doc.uploaded ? '#34C759' : '#00D4D4' }}>
                {doc.uploaded ? 'Data extracted successfully' : 'Click to upload or drag and drop'}
              </Text>
            </View>
          </View>
        ))}
      </ScrollView>

      <TouchableOpacity style={styles.button}>
        <Text style={styles.buttonText}>Continue to Data Review</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, backgroundColor: '#1A1F2E' },
  stepsContainer: { flexDirection: 'row', marginBottom: 20 },
  stepCircle: { width: 40, height: 40, borderRadius: 20, backgroundColor: '#4F5D75', justifyContent: 'center', alignItems: 'center', marginRight: 10 },
  activeStep: { backgroundColor: '#00D4D4' },
  stepText: { color: '#fff', fontWeight: 'bold' },
  activeStepText: { color: '#1A1F2E' },
  title: { color: '#fff', fontSize: 24, fontWeight: 'bold', marginVertical: 10 },
  subtitle: { color: '#ccc', fontSize: 14 },
  docCard: { marginBottom: 20 },
  docName: { color: '#fff', fontSize: 16, marginBottom: 10 },
  uploadBox: { borderWidth: 1, borderColor: '#00D4D4', borderRadius: 10, padding: 20, justifyContent: 'center', alignItems: 'center' },
  button: { backgroundColor: '#00D4D4', padding: 15, borderRadius: 10, alignItems: 'center', marginTop: 20 },
  buttonText: { color: '#1A1F2E', fontWeight: 'bold', fontSize: 16 },
});

export default UploadedDocumentsScreen;