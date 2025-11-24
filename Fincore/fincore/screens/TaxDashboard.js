import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';

const steps = [
  { id: 1, title: 'Welcome', isCompleted: true },
  { id: 2, title: 'Document Upload', isCompleted: true },
  { id: 3, title: 'Data Review', isCompleted: true },
  { id: 4, title: 'Tax Calculation', isCompleted: true },
  { id: 5, title: 'ITR Generation', isCompleted: true },
  { id: 6, title: 'Filing Assistant', isCompleted: true },
  { id: 7, title: 'Acknowledgment', isCompleted: true },
  { id: 8, title: 'Dashboard', isActive: true }
];

const TaxDashboard = ({ navigation }) => {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {}
      <View style={{height: 24}} />
      <View style={{marginBottom: 24}}>
        <Text style={{color: '#fff', fontSize: 24, fontWeight: 'bold', textAlign: 'center', marginBottom: 4}}>ITR Filing Assistant</Text>
        <Text style={{color: '#9CA3AF', fontSize: 15, textAlign: 'center', marginBottom: 16}}>Simplify your tax filing</Text>
      </View>
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
      <Text style={styles.title}>Tax Dashboard</Text>
      <Text style={styles.subtitle}>Welcome back! Here's your tax filing overview.</Text>
      <View style={styles.card}>
        <View style={styles.row}>
          <Text style={styles.assessmentYear}>Assessment Year 2025-2026</Text>
          <View style={styles.statusBadge}><Text style={styles.statusBadgeText}>Filed Successfully</Text></View>
        </View>
        <View style={styles.infoBox}><Text style={styles.infoTitle}>₹8,75,000</Text><Text style={styles.infoDesc}>Gross Income</Text></View>
        <View style={styles.infoBox}><Text style={styles.infoTitle}>₹19,240</Text><Text style={styles.infoDesc}>Tax Payable</Text></View>
        <View style={styles.infoBox}><Text style={styles.infoTitle}>₹28,260</Text><Text style={styles.infoDesc}>Expected Refund</Text></View>
        <View style={styles.infoBox}><Text style={styles.infoTitle}>₹19,760</Text><Text style={styles.infoDesc}>Tax Optimized</Text></View>
        <View style={styles.progressSection}>
          <Text style={styles.progressLabel}>Filing Progress</Text>
          <View style={styles.progressBar}><View style={styles.progressFill} /></View>
          <Text style={styles.progressPercent}>70%</Text>
        </View>
        <View style={styles.ackSection}>
          <Text style={styles.ackLabel}>Acknowledgment Number</Text>
          <View style={styles.ackRow}>
            <Text style={styles.ackNumber}>123456789123467</Text>
            <Text style={styles.ackCheck}>✔️</Text>
          </View>
        </View>
      </View>
      <View style={styles.tabsRow}>
        <Text style={styles.tabActive}>Current Year</Text>
        <Text style={styles.tab}>Previous Year</Text>
        <Text style={styles.tab}>Tax Planning</Text>
      </View>
      <View style={styles.statusCard}>
        <Text style={styles.statusTitle}>Filing Status</Text>
        <View style={styles.statusRow}><Text style={styles.statusText}>Profile Setup</Text><Text style={styles.statusCheck}>✔️</Text></View>
        <View style={styles.statusRow}><Text style={styles.statusText}>Documents Uploaded</Text><Text style={styles.statusCheck}>✔️</Text></View>
        <View style={styles.statusRow}><Text style={styles.statusText}>Data Verified</Text><Text style={styles.statusCheck}>✔️</Text></View>
        <View style={styles.statusRow}><Text style={styles.statusText}>Tax Calculated</Text><Text style={styles.statusCheck}>✔️</Text></View>
        <View style={styles.statusRow}><Text style={styles.statusText}>ITR Generated</Text><Text style={styles.statusCheck}>✔️</Text></View>
        <View style={styles.statusRow}><Text style={styles.statusText}>Filed & Verified</Text><Text style={styles.statusCheck}>✔️</Text></View>
      </View>
      <View style={styles.actionsCard}>
        <Text style={styles.actionsTitle}>Important Actions</Text>
        <TouchableOpacity style={styles.actionButton}><Text style={styles.actionButtonText}>Download ITR File</Text></TouchableOpacity>
        <TouchableOpacity style={styles.actionButton}><Text style={styles.actionButtonText}>View Tax Summary</Text></TouchableOpacity>
        <TouchableOpacity style={styles.actionButton}><Text style={styles.actionButtonText}>Set Reminders</Text></TouchableOpacity>
        <View style={styles.nextStepsBox}>
          <Text style={styles.nextStepsTitle}>Next Steps</Text>
          <Text style={styles.nextStepsDesc}>Your return is being processed. Refund (if any) will be credited within 45-60 days.</Text>
        </View>
      </View>
      {}
      <TouchableOpacity style={styles.exploreButton} onPress={() => navigation.navigate('Explore')}>
        <Text style={styles.exploreButtonText}>Go to Explore Page</Text>
      </TouchableOpacity>
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
  title: { color: '#fff', fontSize: 24, fontWeight: 'bold', marginBottom: 8 },
  subtitle: { color: '#9CA3AF', fontSize: 15, marginBottom: 16 },
  card: { backgroundColor: '#19272F', borderRadius: 16, padding: 20, marginBottom: 18, borderWidth: 1, borderColor: '#00D4D4' },
  row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 },
  assessmentYear: { color: '#fff', fontSize: 15 },
  statusBadge: { backgroundColor: '#00D4D4', borderRadius: 8, paddingHorizontal: 12, paddingVertical: 4 },
  statusBadgeText: { color: '#1A1F2E', fontWeight: 'bold', fontSize: 13 },
  infoBox: { backgroundColor: '#273142', borderRadius: 12, padding: 16, alignItems: 'center', marginBottom: 10 },
  infoTitle: { color: '#00D4D4', fontSize: 22, fontWeight: 'bold' },
  infoDesc: { color: '#9CA3AF', fontSize: 13, marginTop: 4 },
  progressSection: { marginTop: 10, marginBottom: 10 },
  progressLabel: { color: '#fff', fontSize: 14, marginBottom: 4 },
  progressBar: { height: 8, backgroundColor: '#273142', borderRadius: 4, overflow: 'hidden', marginBottom: 4 },
  progressFill: { width: '70%', height: 8, backgroundColor: '#00D4D4' },
  progressPercent: { color: '#9CA3AF', fontSize: 13, marginBottom: 4 },
  ackSection: { marginTop: 10, marginBottom: 10 },
  ackLabel: { color: '#fff', fontSize: 14, marginBottom: 2 },
  ackRow: { flexDirection: 'row', alignItems: 'center' },
  ackNumber: { color: '#fff', fontSize: 16, fontWeight: 'bold', marginRight: 8 },
  ackCheck: { color: '#00D4D4', fontSize: 18 },
  tabsRow: { flexDirection: 'row', marginBottom: 10 },
  tabActive: { color: '#00D4D4', fontWeight: 'bold', marginRight: 16, fontSize: 15 },
  tab: { color: '#9CA3AF', marginRight: 16, fontSize: 15 },
  statusCard: { backgroundColor: '#19272F', borderRadius: 12, padding: 16, marginBottom: 18, borderWidth: 1, borderColor: '#00D4D4' },
  statusTitle: { color: '#fff', fontSize: 16, fontWeight: 'bold', marginBottom: 8 },
  statusRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 },
  statusText: { color: '#9CA3AF', fontSize: 14 },
  statusCheck: { color: '#00D4D4', fontSize: 16 },
  actionsCard: { backgroundColor: '#19272F', borderRadius: 12, padding: 16, marginBottom: 18, borderWidth: 1, borderColor: '#00D4D4' },
  actionsTitle: { color: '#fff', fontSize: 16, fontWeight: 'bold', marginBottom: 8 },
  actionButton: { backgroundColor: '#273142', borderRadius: 8, padding: 12, marginBottom: 8 },
  actionButtonText: { color: '#00D4D4', fontWeight: 'bold', fontSize: 15 },
  nextStepsBox: { backgroundColor: '#19272F', borderRadius: 8, padding: 10, borderColor: '#00D4D4', borderWidth: 1, marginTop: 8 },
  nextStepsTitle: { color: '#00D4D4', fontWeight: 'bold', marginBottom: 4 },
  nextStepsDesc: { color: '#9CA3AF' },
  exploreButton: { backgroundColor: '#00D4D4', borderRadius: 12, padding: 16, alignItems: 'center', marginTop: 24 },
  exploreButtonText: { color: '#1A1F2E', fontSize: 16, fontWeight: '600' },
});

export default TaxDashboard;