import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, TextInput } from 'react-native';

const steps = [
  { id: 1, title: 'Welcome', isCompleted: true },
  { id: 2, title: 'Document Upload', isCompleted: true },
  { id: 3, title: 'Data Review', isCompleted: true },
  { id: 4, title: 'Tax Calculation', isCompleted: true },
  { id: 5, title: 'ITR Generation', isCompleted: true },
  { id: 6, title: 'Filing Assistant', isCompleted: true },
  { id: 7, title: 'Acknowledgment', isActive: true },
  { id: 8, title: 'Dashboard', isActive: false }
];

const AcknowledgmentScreen = ({ navigation }) => {
  const [ackNumber, setAckNumber] = useState('');
  const [savedAck, setSavedAck] = useState('');
  const [statusUpdated, setStatusUpdated] = useState(false);

  const handleUpdate = () => {
    if (ackNumber.length >= 12) {
      setSavedAck(ackNumber);
      setStatusUpdated(true);
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {}
      <View style={styles.stepsContainer}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.stepsScrollContent}>
          <View style={styles.stepsBackground}>
            {steps.map((step) => (
              <View key={step.id} style={styles.stepItem}>
                <View style={[styles.stepCircle, (step.isActive || step.isCompleted) && styles.activeStep]}>
                  <Text style={[styles.stepNumber, (step.isActive || step.isCompleted) && styles.activeStepText]}>{step.id}</Text>
                </View>
                <Text style={[styles.stepLabel, (step.isActive || step.isCompleted) && styles.activeStepLabel]}>{step.title}</Text>
              </View>
            ))}
          </View>
        </ScrollView>
      </View>
      {}
      <View style={styles.statusBox}>
        <Text style={styles.statusTitle}>Track Your Filing Status</Text>
        <Text style={styles.statusSubtitle}>Keep track of your ITR filing progress and store important documents</Text>
        {statusUpdated ? (
          <View style={styles.statusCard}>
            <Text style={styles.statusIcon}>✔️</Text>
            <Text style={styles.statusText}>Current Status: Filed Successfully</Text>
            <View style={styles.statusBadge}><Text style={styles.statusBadgeText}>Successfully Submitted</Text></View>
          </View>
        ) : (
          <View style={styles.statusCard}>
            <Text style={styles.statusIcon}>🕒</Text>
            <Text style={styles.statusText}>Current Status: Not Started</Text>
            <View style={styles.statusBadge}><Text style={styles.statusBadgeText}>Ready to File</Text></View>
          </View>
        )}
      </View>
      {}
      <View style={styles.ackBox}>
        <Text style={styles.ackTitle}>Acknowledgment Details</Text>
        <Text style={styles.ackSubtitle}>Enter the acknowledgment number received after filing your ITR</Text>
        <Text style={styles.ackLabel}>Acknowledgment Number *</Text>
        <View style={styles.ackInputRow}>
          {statusUpdated ? (
            <>
              <Text style={styles.ackInput}>{savedAck}</Text>
              <View style={{backgroundColor: '#00D4D4', borderRadius: 8, paddingHorizontal: 12, paddingVertical: 6, marginLeft: 8}}>
                <Text style={{color: '#1A1F2E', fontWeight: 'bold'}}>Updated</Text>
              </View>
            </>
          ) : (
            <>
              <TextInput
                style={styles.ackInput}
                placeholder="Enter 15-digit acknowledgment number"
                value={ackNumber}
                onChangeText={setAckNumber}
                maxLength={15}
                keyboardType="numeric"
              />
              <TouchableOpacity style={styles.ackSaveButton} onPress={handleUpdate}>
                <Text style={styles.ackSaveButtonText}>Update</Text>
              </TouchableOpacity>
            </>
          )}
        </View>
        <Text style={styles.ackExample}>Example: 123456789012345 (15 digits received after successful filing)</Text>
        {statusUpdated && (
          <View style={{marginTop: 8, backgroundColor: '#19272F', borderRadius: 8, padding: 10, borderColor: '#00D4D4', borderWidth: 1}}>
            <View style={{flexDirection: 'row', alignItems: 'center', marginBottom: 4}}>
              <Text style={{color: '#00D4D4', fontWeight: 'bold', marginRight: 6}}>✔️</Text>
              <Text style={{color: '#00D4D4', fontWeight: 'bold'}}>Filing Status Updated</Text>
            </View>
            <Text style={{color: '#9CA3AF'}}>Your ITR has been successfully filed. Keep this acknowledgment number safe for future reference.</Text>
          </View>
        )}
      </View>
      {}
      <View style={styles.timelineBox}>
        <Text style={styles.timelineTitle}>Processing Timeline</Text>
        <Text style={styles.timelineSubtitle}>Expected timeline for your ITR processing</Text>
        <View style={styles.timelineRow}><View style={styles.timelineDot} /><Text style={styles.timelineLabel}>ITR Filed</Text><Text style={styles.timelineStatus}>Pending</Text></View>
        <View style={styles.timelineRow}><View style={styles.timelineDot} /><Text style={styles.timelineLabel}>Under Processing</Text><Text style={styles.timelineStatus}>15-30 days</Text></View>
        <View style={styles.timelineRow}><View style={styles.timelineDot} /><Text style={styles.timelineLabel}>Processing Complete</Text><Text style={styles.timelineStatus}>45-60 days</Text></View>
      </View>
      {}
      <View style={styles.infoBox}>
        <Text style={styles.infoTitle}>❗ Important Information</Text>
        <Text style={styles.infoSubtitle}>What happens next:</Text>
        <View style={{marginLeft: 10}}>
          <Text style={styles.infoText}>• Your return will be processed within 15-30 days</Text>
          <Text style={styles.infoText}>• Refund (if any) will be credited to your bank account</Text>
          <Text style={styles.infoText}>• You'll receive email updates on processing status</Text>
        </View>
        <Text style={styles.infoSubtitle}>Keep these documents safe:</Text>
        <View style={{marginLeft: 10}}>
          <Text style={styles.infoText}>• Acknowledgment receipt</Text>
          <Text style={styles.infoText}>• ITR-V (if applicable)</Text>
          <Text style={styles.infoText}>• All supporting documents</Text>
          <Text style={styles.infoText}>• Form 16 and investment proofs</Text>
        </View>
      </View>
      {}
      <View style={styles.buttonContainer}>
        <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
          <Text style={styles.backButtonText}>Back to Filing Assistant</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.continueButton} onPress={() => navigation.navigate('TaxDashboard')}>
          <Text style={styles.continueText}>Go to Dashboard</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#1A1F2E' },
  contentContainer: { padding: 20, paddingBottom: 40 },
  stepsContainer: { paddingVertical: 16, backgroundColor: '#273142', marginHorizontal: 8, borderRadius: 20, marginBottom: 16 },
  stepsScrollContent: { paddingHorizontal: 20 },
  stepsBackground: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, gap: 16 },
  stepItem: { alignItems: 'center', minWidth: 85, maxWidth: 100 },
  stepCircle: { width: 40, height: 40, borderRadius: 20, backgroundColor: '#384152', justifyContent: 'center', alignItems: 'center', marginBottom: 8 },
  activeStep: { backgroundColor: '#00D4D4' },
  stepNumber: { color: '#9CA3AF', fontWeight: 'bold', fontSize: 18 },
  activeStepText: { color: '#1A1F2E' },
  stepLabel: { color: '#9CA3AF', fontSize: 11, textAlign: 'center', marginTop: 4, flexWrap: 'nowrap' },
  activeStepLabel: { color: '#fff' },
  statusBox: { backgroundColor: '#19272F', borderRadius: 16, padding: 20, marginBottom: 18, borderWidth: 1, borderColor: '#00D4D4' },
  statusTitle: { color: '#fff', fontSize: 20, fontWeight: 'bold', marginBottom: 6 },
  statusSubtitle: { color: '#9CA3AF', fontSize: 15, marginBottom: 16 },
  statusCard: { backgroundColor: '#273142', borderRadius: 12, padding: 24, alignItems: 'center', borderWidth: 1, borderColor: '#00D4D4', marginBottom: 10 },
  statusIcon: { fontSize: 40, color: '#9CA3AF', marginBottom: 10 },
  statusText: { color: '#fff', fontSize: 17, marginBottom: 8 },
  statusBadge: { backgroundColor: '#00D4D4', borderRadius: 8, paddingHorizontal: 12, paddingVertical: 4 },
  statusBadgeText: { color: '#1A1F2E', fontWeight: 'bold', fontSize: 13 },
  ackBox: { backgroundColor: '#273142', borderRadius: 12, padding: 16, marginBottom: 18, borderWidth: 1, borderColor: '#00D4D4' },
  ackTitle: { color: '#fff', fontSize: 16, fontWeight: 'bold', marginBottom: 6 },
  ackSubtitle: { color: '#9CA3AF', fontSize: 14, marginBottom: 10 },
  ackLabel: { color: '#fff', fontSize: 14, marginBottom: 4 },
  ackInputRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 6 },
  ackInput: { backgroundColor: '#19272F', color: '#fff', borderRadius: 8, padding: 10, flex: 1, marginRight: 8, fontSize: 15, borderWidth: 1, borderColor: '#384152' },
  ackSaveButton: { backgroundColor: '#00D4D4', borderRadius: 8, paddingVertical: 10, paddingHorizontal: 18 },
  ackSaveButtonText: { color: '#1A1F2E', fontWeight: 'bold', fontSize: 15 },
  ackExample: { color: '#9CA3AF', fontSize: 12, marginTop: 2 },
  ackSaved: { color: '#00D4D4', fontSize: 13, marginTop: 4 },
  timelineBox: { backgroundColor: '#273142', borderRadius: 12, padding: 16, marginBottom: 18, borderWidth: 1, borderColor: '#00D4D4' },
  timelineTitle: { color: '#fff', fontSize: 16, fontWeight: 'bold', marginBottom: 6 },
  timelineSubtitle: { color: '#9CA3AF', fontSize: 14, marginBottom: 10 },
  timelineRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 8 },
  timelineDot: { width: 12, height: 12, borderRadius: 6, backgroundColor: '#384152', marginRight: 10 },
  timelineLabel: { color: '#fff', fontSize: 14, flex: 1 },
  timelineStatus: { backgroundColor: '#19272F', color: '#00D4D4', borderRadius: 8, paddingHorizontal: 10, paddingVertical: 4, fontSize: 13, fontWeight: 'bold' },
  infoBox: { backgroundColor: '#19272F', borderRadius: 12, padding: 16, marginBottom: 18, borderWidth: 1, borderColor: '#00D4D4' },
  infoTitle: { color: '#00D4D4', fontSize: 16, fontWeight: 'bold', marginBottom: 6 },
  infoSubtitle: { color: '#fff', fontSize: 14, marginBottom: 4 },
  infoText: { color: '#9CA3AF', fontSize: 13, marginBottom: 4 },
  buttonContainer: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 8, gap: 12 },
  backButton: { flex: 1, padding: 16, borderRadius: 12, borderWidth: 1, borderColor: '#384152', alignItems: 'center' },
  backButtonText: { color: '#fff', fontSize: 16, fontWeight: '600' },
  continueButton: { flex: 1, padding: 16, borderRadius: 12, backgroundColor: '#00D4D4', alignItems: 'center' },
  continueText: { color: '#1A1F2E', fontSize: 16, fontWeight: '600' },
});

export default AcknowledgmentScreen;