import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';

const steps = [
  { id: 1, title: 'Welcome', isCompleted: true },
  { id: 2, title: 'Document Upload', isCompleted: true },
  { id: 3, title: 'Data Review', isCompleted: true },
  { id: 4, title: 'Tax Calculation', isActive: true },
  { id: 5, title: 'ITR Generation', isActive: false },
  { id: 6, title: 'Filing Assistant', isActive: false },
  { id: 7, title: 'Acknowledgment', isActive: false },
  { id: 8, title: 'Dashboard', isActive: false }
];

const TaxCalculationScreen = ({ navigation }) => {

  const grossIncome = 875000;
  const totalDeductions = 295000;
  const tdsPaid = 47500;

  const standardDeduction = 50000;
  const taxableIncomeOld = grossIncome - totalDeductions - standardDeduction;
  const taxPayableOld = 19240;
  const refundOld = tdsPaid - taxPayableOld;

  const taxableIncomeNew = grossIncome - standardDeduction;
  const taxPayableNew = 39000;
  const refundNew = tdsPaid - taxPayableNew;

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {}
      <View style={styles.headerBar}>
        <Text style={styles.headerText}>ITR Filing Assistant</Text>
        <Text style={styles.headerSubText}>Simplify your tax filing</Text>
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
      <View style={styles.summaryBox}>
        <Text style={styles.summaryTitle}>Your Tax Summary</Text>
        <Text style={styles.summarySubtitle}>Compare Old vs New Tax Regime and see which saves you more money</Text>
        <View style={styles.summaryItem}><Text style={styles.summaryLabel}>Gross Income</Text><Text style={styles.summaryValue}>₹8,75,000</Text></View>
        <View style={styles.summaryItem}><Text style={styles.summaryLabel}>Total Deductions</Text><Text style={styles.summaryValue}>₹2,95,000</Text></View>
        <View style={styles.summaryItem}><Text style={styles.summaryLabel}>TDS Paid</Text><Text style={styles.summaryValue}>₹47,500</Text></View>
      </View>
      <View style={styles.regimeTabs}>
        <Text style={styles.activeTab}>Regime Comparison</Text>
    
      </View>
      {}
      <View style={styles.regimeBox}>
        <View style={styles.regimeHeader}><Text style={styles.regimeTitle}>Old Tax Regime</Text><Text style={styles.regimeTag}>With Deductions</Text></View>
        <Text style={styles.regimeRow}>Gross Income: <Text style={styles.value}>₹8,75,000</Text></Text>
        <Text style={styles.regimeRow}>Less: Deductions <Text style={styles.minusValue}>-₹2,95,000</Text></Text>
        <Text style={styles.regimeRow}>Less: Standard Deduction <Text style={styles.value}>₹50,000</Text></Text>
        <Text style={styles.regimeRow}>Taxable Income: <Text style={styles.value}>₹5,30,000</Text></Text>
        <Text style={styles.regimeRow}>Tax Payable: <Text style={styles.value}>₹19,240</Text></Text>
        <Text style={styles.regimeRow}>Less: TDS Paid <Text style={styles.minusValue}>-₹47,500</Text></Text>
        <Text style={styles.refundRow}>Refund/Additional Tax: <Text style={styles.refundValue}>Refund: ₹28,260</Text></Text>
      </View>
      {}
      <View style={styles.regimeBox}>
        <View style={styles.regimeHeader}><Text style={styles.regimeTitle}>New Tax Regime</Text><Text style={styles.regimeTag}>Lower Rates</Text></View>
        <Text style={styles.regimeRow}>Gross Income: <Text style={styles.value}>₹8,75,000</Text></Text>
        <Text style={styles.regimeRow}>Less: Standard Deduction <Text style={styles.value}>₹50,000</Text></Text>
        <Text style={styles.regimeRow}>Other deductions: <Text style={styles.value}>Not applicable</Text></Text>
        <Text style={styles.regimeRow}>Taxable Income: <Text style={styles.value}>₹8,25,000</Text></Text>
        <Text style={styles.regimeRow}>Tax Payable: <Text style={styles.value}>₹39,000</Text></Text>
        <Text style={styles.regimeRow}>Less: TDS Paid <Text style={styles.minusValue}>-₹47,500</Text></Text>
        <Text style={styles.refundRow}>Refund/Additional Tax: <Text style={styles.refundValue}>Refund: ₹8,500</Text></Text>
      </View>
      <View style={styles.buttonContainer}>
        <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
          <Text style={styles.backButtonText}>Back to Data Review</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.continueButton} onPress={() => navigation.navigate('ITRGeneration')}>
          <Text style={styles.continueText}>Generate ITR File</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#1A1F2E' },
  contentContainer: { padding: 20, paddingBottom: 40 },
  headerBar: { alignItems: 'center', marginBottom: 16, marginTop: 18 },
  headerText: { color: '#fff', fontSize: 24, fontWeight: 'bold', textAlign: 'center', marginBottom: 8 },
  headerSubText: { color: '#9CA3AF', fontSize: 14, textAlign: 'center', marginBottom: 16 },
  summaryBox: { backgroundColor: '#273142', borderRadius: 16, padding: 18, marginBottom: 18 },
  summaryTitle: { color: '#fff', fontSize: 20, fontWeight: 'bold', marginBottom: 6 },
  summarySubtitle: { color: '#9CA3AF', fontSize: 13, marginBottom: 14 },
  summaryItem: { backgroundColor: '#1A1F2E', borderRadius: 12, padding: 12, marginBottom: 10 },
  summaryLabel: { color: '#9CA3AF', fontSize: 14 },
  summaryValue: { color: '#fff', fontSize: 20, fontWeight: 'bold' },
  regimeTabs: { flexDirection: 'row', marginBottom: 10, gap: 10 },
  activeTab: { color: '#fff', backgroundColor: '#384152', borderRadius: 10, paddingVertical: 6, paddingHorizontal: 14, fontWeight: 'bold' },
  inactiveTab: { color: '#9CA3AF', paddingVertical: 6, paddingHorizontal: 14 },
  regimeBox: {
    backgroundColor: '#273142',
    borderRadius: 16,
    padding: 20,
    marginBottom: 28,
    borderWidth: 1,
    borderColor: '#384152',
    shadowColor: '#000',
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 2,
  },
  regimeHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#384152',
    paddingBottom: 8,
  },
  regimeTitle: { color: '#fff', fontSize: 16, fontWeight: 'bold' },
  regimeTag: { color: '#00D4D4', backgroundColor: '#1A1F2E', borderRadius: 8, paddingVertical: 2, paddingHorizontal: 10, fontSize: 12, fontWeight: 'bold' },
  regimeRow: {
    color: '#fff',
    fontSize: 15,
    marginBottom: 8,
    paddingLeft: 4,
    paddingRight: 4,
    lineHeight: 22,
  },
  value: { color: '#fff', fontWeight: 'bold' },
  minusValue: { color: '#00D4D4', fontWeight: 'bold' },
  refundRow: {
    color: '#fff',
    fontSize: 15,
    marginTop: 12,
    paddingLeft: 4,
    paddingRight: 4,
    lineHeight: 22,
    borderTopWidth: 1,
    borderTopColor: '#384152',
    paddingTop: 10,
  },
  refundValue: { color: '#00D4D4', fontWeight: 'bold', fontSize: 17 },
  buttonContainer: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 16, gap: 12 },
  backButton: { flex: 1, padding: 16, borderRadius: 12, borderWidth: 1, borderColor: '#384152', alignItems: 'center' },
  backButtonText: { color: '#fff', fontSize: 16, fontWeight: '600' },
  continueButton: { flex: 1, padding: 16, borderRadius: 12, backgroundColor: '#00D4D4', alignItems: 'center' },
  continueText: { color: '#1A1F2E', fontSize: 16, fontWeight: '600' },
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
});

export default TaxCalculationScreen;