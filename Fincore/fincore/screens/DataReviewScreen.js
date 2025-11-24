import React, { useState, useEffect } from 'react';
import { ScrollView as RNScrollView } from 'react-native';
const steps = [
  { id: 1, title: 'Welcome', isCompleted: true },
  { id: 2, title: 'Document Upload', isCompleted: true },
  { id: 3, title: 'Data Review', isActive: true },
  { id: 4, title: 'Tax Calculation', isActive: false },
  { id: 5, title: 'ITR Generation', isActive: false },
  { id: 6, title: 'Filing Assistant', isActive: false },
  { id: 7, title: 'Acknowledgment', isActive: false },
  { id: 8, title: 'Dashboard', isActive: false }
];
import { View, Text, StyleSheet, SafeAreaView, ScrollView, TouchableOpacity, TextInput } from 'react-native';

const DataReviewScreen = ({ navigation, route }) => {
  const [taxData, setTaxData] = useState({
    salaryIncome: 0,
    otherIncomes: 0,
    deductions80C: 0,
    deductions80D: 0,
    hraDeduction: 0,
    tdsDeducted: 0,
  });

  const [isEditing, setIsEditing] = useState({});

  useEffect(() => {
    setTaxData({
      salaryIncome: 850000,
      otherIncomes: 25000,
      deductions80C: 150000,
      deductions80D: 25000,
      hraDeduction: 120000,
      tdsDeducted: 45000,
    });
  }, []);

  const toggleEdit = (field) => {
    setIsEditing((prev) => ({ ...prev, [field]: !prev[field] }));
  };

  const handleEditChange = (field, value) => {
    setTaxData((prev) => ({ ...prev, [field]: Number(value) || 0 }));
  };

  const incomeData = [
    {
      category: 'Salary Income',
      field: 'salaryIncome',
      source: 'Form 16',
      tooltip: 'Basic salary + allowances + bonus as per Form 16',
    },
    {
      category: 'Other Incomes',
      field: 'otherIncomes',
      source: 'Form 26AS',
      tooltip: 'Interest income, dividend, other sources',
    },
  ];

  const deductionData = [
    {
      category: 'Section 80C',
      field: 'deductions80C',
      source: 'Investment Proofs',
      tooltip: 'PPF, ELSS, Life Insurance, Home Loan Principal (max ₹1.5L)',
    },
    {
      category: 'Section 80D',
      field: 'deductions80D',
      source: 'Insurance Certificates',
      tooltip: 'Health insurance premiums for self and family',
    },
    {
      category: 'HRA Deduction',
      field: 'hraDeduction',
      source: 'Form 16',
      tooltip: 'House Rent Allowance exemption',
    },
  ];

  const renderEditableRow = (item) => (
    <View key={item.field} style={styles.row}>
      <Text style={styles.cell}>{item.category}</Text>
      <View style={[styles.cell, styles.editCell]}>
        {isEditing[item.field] ? (
          <TextInput
            style={styles.input}
            value={String(taxData[item.field])}
            onChangeText={(v) => handleEditChange(item.field, v)}
            keyboardType="numeric"
          />
        ) : (
          <Text style={styles.textValue}>₹{taxData[item.field].toLocaleString('en-IN')}</Text>
        )}
        <TouchableOpacity onPress={() => toggleEdit(item.field)}>
          <Text style={styles.editButton}>{isEditing[item.field] ? '✔' : '✎'}</Text>
        </TouchableOpacity>
      </View>
      <Text style={styles.cell}>{item.source}</Text>
      <Text style={[styles.cell, styles.tooltipText]}>{item.tooltip}</Text>
    </View>
  );

  const totalGrossIncome = taxData.salaryIncome + taxData.otherIncomes;
  const totalDeductions = taxData.deductions80C + taxData.deductions80D + taxData.hraDeduction;
  const totalTDS = taxData.tdsDeducted + 2500;

  return (
    <SafeAreaView style={styles.container}>
      <RNScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {}
        <View style={styles.headerBar}>
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Text style={styles.backText}>←</Text>
          </TouchableOpacity>
          <View style={{ flex: 1 }}>
            <Text style={styles.headerTitle}>Review Your Income & Deductions</Text>
            <Text style={styles.headerSubtitle}>
              Review auto-filled data. Tap ✎ to edit any field.
            </Text>
          </View>
        </View>
        {}
        <View style={styles.stepsContainer}>
          <RNScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.stepsScrollContent}>
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
          </RNScrollView>
        </View>

        {}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Income Details</Text>
          <View style={styles.tableHeader}>
            <Text style={styles.headerCell}>Category</Text>
            <Text style={styles.headerCell}>Amount</Text>
            <Text style={styles.headerCell}>Source</Text>
            <Text style={styles.headerCell}>Details</Text>
          </View>
          {incomeData.map(renderEditableRow)}
          <View style={styles.summaryBox}>
            <Text style={styles.summaryLabel}>Total Gross Income:</Text>
            <Text style={styles.summaryValue}>₹{totalGrossIncome.toLocaleString('en-IN')}</Text>
          </View>
        </View>

        {}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Deductions</Text>
          <View style={styles.tableHeader}>
            <Text style={styles.headerCell}>Category</Text>
            <Text style={styles.headerCell}>Amount</Text>
            <Text style={styles.headerCell}>Source</Text>
            <Text style={styles.headerCell}>Details</Text>
          </View>
          {deductionData.map(renderEditableRow)}
          <View style={styles.summaryBox}>
            <Text style={styles.summaryLabel}>Total Deductions:</Text>
            <Text style={styles.summaryValue}>₹{totalDeductions.toLocaleString('en-IN')}</Text>
          </View>
        </View>

        {}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>TDS Summary</Text>
          <View style={styles.tdsRow}>
            <Text style={styles.tdsLabel}>TDS on Salary</Text>
            <Text style={styles.tdsValue}>₹{taxData.tdsDeducted.toLocaleString('en-IN')}</Text>
          </View>
          <View style={styles.tdsRow}>
            <Text style={styles.tdsLabel}>TDS on Other Income</Text>
            <Text style={styles.tdsValue}>₹2,500</Text>
          </View>
          <View style={styles.tdsRow}>
            <Text style={styles.tdsLabel}>Total TDS Deducted</Text>
            <Text style={styles.tdsValue}>₹{totalTDS.toLocaleString('en-IN')}</Text>
          </View>
        </View>

        {}
        <View style={styles.buttonContainer}>
          <TouchableOpacity
            style={styles.backButton}
            onPress={() => navigation.goBack()}
          >
            <Text style={styles.backButtonText}>Back to Documents</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.continueButton}
            onPress={() => navigation.navigate('TaxCalculation')}
          >
            <Text style={styles.continueText}>Continue to Tax Calculation</Text>
          </TouchableOpacity>
        </View>
  </RNScrollView>
    </SafeAreaView>
  );
};

export default DataReviewScreen;

const styles = StyleSheet.create({
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
  container: {
    flex: 1,
    backgroundColor: '#1A1F2E',
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 60,
  },
  headerBar: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 24,
  },
  backText: {
    color: '#fff',
    fontSize: 28,
    marginRight: 12,
    marginBottom: 8,
  },
  headerTitle: {
    color: '#fff',
    fontSize: 22,
    fontWeight: '700',
    textAlign: 'center',
    marginTop: 28,
  },
  headerSubtitle: {
    color: '#9CA3AF',
    fontSize: 14,
    textAlign: 'center',
    marginTop: 6,
  },
  card: {
    backgroundColor: '#273142',
    borderRadius: 12,
    padding: 16,
    marginBottom: 24,
  },
  cardTitle: {
    color: '#00D4D4',
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 10,
  },
  tableHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  headerCell: {
    color: '#9CA3AF',
    fontWeight: '600',
    flex: 1,
    fontSize: 13,
    textAlign: 'center',
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1F2533',
    borderRadius: 8,
    paddingVertical: 10,
    marginBottom: 8,
  },
  cell: {
    color: '#fff',
    flex: 1,
    fontSize: 13,
    textAlign: 'center',
    paddingHorizontal: 4,
  },
  editCell: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 6,
  },
  input: {
    backgroundColor: '#384152',
    color: '#fff',
    width: 80,
    borderRadius: 6,
    textAlign: 'center',
    paddingVertical: 4,
  },
  editButton: {
    color: '#00D4D4',
    fontSize: 18,
    marginLeft: 6,
  },
  tooltipText: {
    color: '#9CA3AF',
    fontSize: 11,
  },
  summaryBox: {
    marginTop: 8,
    backgroundColor: '#1F2533',
    borderRadius: 8,
    padding: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  summaryLabel: {
    color: '#9CA3AF',
    fontSize: 14,
  },
  summaryValue: {
    color: '#00D4D4',
    fontWeight: '700',
    fontSize: 16,
  },
  tdsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginVertical: 4,
  },
  tdsLabel: {
    color: '#9CA3AF',
  },
  tdsValue: {
    color: '#fff',
    fontWeight: '600',
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 16,
    gap: 12,
  },
  backButton: {
    flex: 1,
    padding: 14,
    borderRadius: 10,
    borderColor: '#384152',
    borderWidth: 1,
    alignItems: 'center',
  },
  backButtonText: {
    color: '#fff',
    fontWeight: '600',
  },
  continueButton: {
    flex: 1,
    padding: 14,
    borderRadius: 10,
    backgroundColor: '#00D4D4',
    alignItems: 'center',
  },
  continueText: {
    color: '#1A1F2E',
    fontWeight: '700',
  },
});