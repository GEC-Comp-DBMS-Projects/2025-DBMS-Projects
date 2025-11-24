import * as FileSystem from 'expo-file-system';
import * as Sharing from 'expo-sharing';

export function generateITRXML(data) {

  const now = new Date();
  const pad = (n) => n < 10 ? '0' + n : n;
  const sysDate = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;

  return `<?xml version="1.0" encoding="UTF-8"?>\n<ITR xmlns="http://incometaxindiaefiling.gov.in/main"\n     xmlns:ITR1FORM="http://incometaxindiaefiling.gov.in/ITR/2018/ITR-1"\n     version="1.0">\n  <GeneratedDate>${sysDate}</GeneratedDate>\n  <ITR1FORM:ITR1>\n    <ITR1FORM:FormName>ITR-1</ITR1FORM:FormName>\n    <ITR1FORM:AssessmentYear>${data.assessmentYear}</ITR1FORM:AssessmentYear>\n    <ITR1FORM:FilingType>${data.filingType}</ITR1FORM:FilingType>\n    <ITR1FORM:FilingStatus>${data.filingStatus}</ITR1FORM:FilingStatus>\n    <ITR1FORM:PersonalInfo>\n      <ITR1FORM:Name>\n        <ITR1FORM:FirstName>${data.firstName}</ITR1FORM:FirstName>\n        <ITR1FORM:LastName>${data.lastName}</ITR1FORM:LastName>\n      </ITR1FORM:Name>\n      <ITR1FORM:PAN>${data.pan}</ITR1FORM:PAN>\n      <ITR1FORM:AadharNumber>${data.aadhar}</ITR1FORM:AadharNumber>\n      <ITR1FORM:Gender>${data.gender}</ITR1FORM:Gender>\n      <ITR1FORM:DOB>${sysDate}</ITR1FORM:DOB>\n      <ITR1FORM:Email>${data.email}</ITR1FORM:Email>\n      <ITR1FORM:Mobile>${data.mobile}</ITR1FORM:Mobile>\n      <ITR1FORM:Address>\n        <ITR1FORM:FlatDoor>${data.flatDoor}</ITR1FORM:FlatDoor>\n        <ITR1FORM:Premises>${data.premises}</ITR1FORM:Premises>\n        <ITR1FORM:Road>${data.road}</ITR1FORM:Road>\n        <ITR1FORM:Locality>${data.locality}</ITR1FORM:Locality>\n        <ITR1FORM:City>${data.city}</ITR1FORM:City>\n        <ITR1FORM:State>${data.state}</ITR1FORM:State>\n        <ITR1FORM:PIN>${data.pin}</ITR1FORM:PIN>\n      </ITR1FORM:Address>\n    </ITR1FORM:PersonalInfo>\n    <ITR1FORM:IncomeDetails>\n      <ITR1FORM:SalaryIncome>${data.salaryIncome}</ITR1FORM:SalaryIncome>\n      <ITR1FORM:IncomeFromOtherSources>${data.otherIncome}</ITR1FORM:IncomeFromOtherSources>\n      <ITR1FORM:GrossTotalIncome>${data.grossIncome}</ITR1FORM:GrossTotalIncome>\n    </ITR1FORM:IncomeDetails>\n    <ITR1FORM:Deductions>\n      <ITR1FORM:Section80C>${data.section80C}</ITR1FORM:Section80C>\n      <ITR1FORM:Section80D>${data.section80D}</ITR1FORM:Section80D>\n      <ITR1FORM:TotalDeductions>${data.totalDeductions}</ITR1FORM:TotalDeductions>\n    </ITR1FORM:Deductions>\n    <ITR1FORM:TaxComputation>\n      <ITR1FORM:NetTaxableIncome>${data.netTaxableIncome}</ITR1FORM:NetTaxableIncome>\n      <ITR1FORM:TaxPayable>${data.taxPayable}</ITR1FORM:TaxPayable>\n      <ITR1FORM:TDSonSalary>${data.tdsOnSalary}</ITR1FORM:TDSonSalary>\n      <ITR1FORM:NetTaxDue>${data.netTaxDue}</ITR1FORM:NetTaxDue>\n    </ITR1FORM:TaxComputation>\n    <ITR1FORM:BankDetails>\n      <ITR1FORM:PrimaryBank>\n        <ITR1FORM:IFSC>${data.ifsc}</ITR1FORM:IFSC>\n        <ITR1FORM:AccountNumber>${data.accountNumber}</ITR1FORM:AccountNumber>\n        <ITR1FORM:AccountType>${data.accountType}</ITR1FORM:AccountType>\n      </ITR1FORM:PrimaryBank>\n    </ITR1FORM:BankDetails>\n    <ITR1FORM:Verification>\n      <ITR1FORM:DeclarationText>\n        ${data.declaration}\n      </ITR1FORM:DeclarationText>\n      <ITR1FORM:Place>${data.place}</ITR1FORM:Place>\n      <ITR1FORM:Date>${sysDate}</ITR1FORM:Date>\n    </ITR1FORM:Verification>\n  </ITR1FORM:ITR1>\n</ITR>`;
}
import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Linking } from 'react-native';

const steps = [
  { id: 1, title: 'Login to Income Tax Portal' },
  { id: 2, title: 'Upload ITR File' },
  { id: 3, title: 'E-Verification' }
];

const FilingAssistantScreen = ({ navigation }) => {

  const itrData = {
    assessmentYear: '2024-25',
    filingType: 'Original',
    filingStatus: 'Individual',
    firstName: 'Pooja',
    lastName: 'Thanait',
    pan: 'ABCDE1234F',
    aadhar: '123456789012',
    gender: 'F',
    dob: '1998-05-15',
    email: 'pooja@example.com',
    mobile: '9876543210',
    flatDoor: 'No. 12',
    premises: 'Green View Apartments',
    road: 'MG Road',
    locality: 'Andheri East',
    city: 'Mumbai',
    state: 'MH',
    pin: '400093',
    salaryIncome: '850000',
    otherIncome: '20000',
    grossIncome: '870000',
    section80C: '150000',
    section80D: '25000',
    totalDeductions: '175000',
    netTaxableIncome: '695000',
    taxPayable: '45000',
    tdsOnSalary: '5000',
    netTaxDue: '40000',
    ifsc: 'SBIN0000456',
    accountNumber: '12345678901',
    accountType: 'Savings',
    declaration: 'I, Pooja Thanait, do hereby declare that the information given above is true and correct.',
    place: 'Mumbai',
    date: '2025-07-25',
  };

  const handleDownloadITR = async () => {
    const xmlString = generateITRXML(itrData);
    const fileUri = FileSystem.documentDirectory + 'ITR1_Pooja_Thanait.xml';
    await FileSystem.writeAsStringAsync(fileUri, xmlString, { encoding: FileSystem.EncodingType.UTF8 });
    if (await Sharing.isAvailableAsync()) {
      await Sharing.shareAsync(fileUri);
    }
  };
  const [expandedStep, setExpandedStep] = useState(1);
  const [completed, setCompleted] = useState({ 1: false, 2: false, 3: false });

  const handleExpand = (step) => setExpandedStep(step);
  const handleComplete = (step) => setCompleted({ ...completed, [step]: true });

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {}
      <View style={styles.stepsContainerTop}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.stepsScrollContentTop}>
          <View style={styles.stepsBackgroundTop}>
            { [
              { id: 1, title: 'Welcome', isCompleted: true },
              { id: 2, title: 'Document Upload', isCompleted: true },
              { id: 3, title: 'Data Review', isCompleted: true },
              { id: 4, title: 'Tax Calculation', isCompleted: true },
              { id: 5, title: 'ITR Generation', isCompleted: true },
              { id: 6, title: 'Filing Assistant', isActive: true },
              { id: 7, title: 'Acknowledgment', isActive: false },
              { id: 8, title: 'Dashboard', isActive: false }
            ].map((step) => (
              <View key={step.id} style={styles.stepItemTop}>
                <View style={[styles.stepCircleTop, (step.isActive || step.isCompleted) && styles.activeStepTop]}>
                  <Text style={[styles.stepNumberTop, (step.isActive || step.isCompleted) && styles.activeStepTextTop]}>{step.id}</Text>
                </View>
                <Text style={[styles.stepLabelTop, (step.isActive || step.isCompleted) && styles.activeStepLabelTop]}>{step.title}</Text>
              </View>
            )) }
          </View>
        </ScrollView>
      </View>
      {}
      <View style={styles.progressBox}>
        <Text style={styles.progressTitle}>File Your Return in 3 Steps</Text>
        <Text style={styles.progressSubtitle}>Follow our guided process to file your ITR on the official government portal</Text>
        {steps.map((step, idx) => (
          <TouchableOpacity key={step.id} style={[styles.stepCard, expandedStep === step.id && styles.stepCardActive]} onPress={() => handleExpand(step.id)}>
            <View style={styles.stepCircleWrap}>
              <View style={[styles.stepCircle, expandedStep === step.id && styles.stepCircleActive]}>
                <Text style={styles.stepCircleText}>{step.id}</Text>
              </View>
            </View>
            <View style={styles.stepTextWrap}>
              <Text style={[styles.stepTitle, expandedStep === step.id && styles.stepTitleActive]}>{step.title}</Text>
              <Text style={styles.stepDesc}>
                {step.id === 1 && 'Access the official government portal'}
                {step.id === 2 && 'Submit your generated ITR file'}
                {step.id === 3 && 'Complete the verification process'}
              </Text>
            </View>
            {completed[step.id] && <Text style={styles.completedBadge}>Completed</Text>}
          </TouchableOpacity>
        ))}
      </View>
      {}
      <View style={styles.detailsBox}>
        {expandedStep === 1 && (
          <View>
            <Text style={styles.detailsTitle}>Login to Income Tax Portal</Text>
            <Text style={styles.detailsList}>1. Go to www.incometax.gov.in{"\n"}2. Click on "e-File" → "Login Here"{"\n"}3. Enter your PAN and password{"\n"}4. Complete the login process</Text>
            <TouchableOpacity style={styles.openPortalButton} onPress={() => Linking.openURL('https://www.incometax.gov.in/')}> 
              <Text style={styles.openPortalText}>Open Portal</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.completeButton} onPress={() => handleComplete(1)}>
              <Text style={styles.completeButtonText}>Mark as Complete</Text>
            </TouchableOpacity>
          </View>
        )}
        {expandedStep === 2 && (
          <View>
            <Text style={styles.detailsTitle}>Upload ITR File</Text>
            <Text style={styles.detailsList}>1. Navigate to "e-File" → "Income Tax Return" → "Submit ITR Online"{"\n"}2. Select Assessment Year 2024-25{"\n"}3. Choose "Upload ITR" option{"\n"}4. Browse and select your downloaded ITR file{"\n"}5. Verify the data and submit</Text>
            <TouchableOpacity style={styles.completeButton} onPress={() => handleComplete(2)}>
              <Text style={styles.completeButtonText}>Mark as Complete</Text>
            </TouchableOpacity>
          </View>
        )}
        {expandedStep === 3 && (
          <View>
            <Text style={styles.detailsTitle}>E-Verification</Text>
            <Text style={styles.detailsList}>1. After successful submission, go to "e-Verify Return"{"\n"}2. Choose verification method: Aadhaar OTP, Net Banking, or EVC{"\n"}3. Complete the verification within 120 days{"\n"}4. Receive acknowledgment receipt</Text>
            <TouchableOpacity style={styles.completeButton} onPress={() => handleComplete(3)}>
              <Text style={styles.completeButtonText}>Mark as Complete</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>
      {}
      <View style={styles.checklistBox}>
        <Text style={styles.checklistTitle}>📋 Important Filing Checklist</Text>
        <Text style={styles.checklistItem}>Before Filing:</Text>
        <Text style={styles.checklistItem}>✓ ITR file downloaded and ready</Text>
        <Text style={styles.checklistItem}>✓ All bank details verified</Text>
        <Text style={styles.checklistItem}>✓ Valid email ID and mobile number</Text>
        <Text style={styles.checklistItem}>✓ Aadhaar linked with PAN</Text>
        <Text style={styles.checklistItem}>Important Dates:</Text>
        <Text style={styles.checklistDate}>• Filing Due Date: September 15, 2025</Text>
        <Text style={styles.checklistDate}>• Verification: Within 120 days</Text>
        <Text style={styles.checklistDate}>• Refund Processing: 45-60 days</Text>
        <Text style={styles.checklistDate}>• Late Filing: Penalty applicable</Text>
        <TouchableOpacity style={[styles.completeButton, {marginTop: 12}]} onPress={handleDownloadITR}>
          <Text style={styles.completeButtonText}>Download ITR file</Text>
        </TouchableOpacity>
      </View>
      {}
      <View style={styles.buttonContainer}>
        <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
          <Text style={styles.backButtonText}>Back to ITR Generation</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.continueButton} onPress={() => navigation.navigate('Acknowledgment')}>
          <Text style={styles.continueText}>Continue to Acknowledgment</Text>
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
  stepsContainerTop: { paddingVertical: 16, backgroundColor: '#273142', marginHorizontal: 8, borderRadius: 20, marginBottom: 16 },
  stepsScrollContentTop: { paddingHorizontal: 20 },
  stepsBackgroundTop: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, gap: 16 },
  stepItemTop: { alignItems: 'center', minWidth: 85, maxWidth: 100 },
  stepCircleTop: { width: 40, height: 40, borderRadius: 20, backgroundColor: '#384152', justifyContent: 'center', alignItems: 'center', marginBottom: 8 },
  activeStepTop: { backgroundColor: '#00D4D4' },
  stepNumberTop: { color: '#9CA3AF', fontWeight: 'bold', fontSize: 18 },
  activeStepTextTop: { color: '#1A1F2E' },
  stepLabelTop: { color: '#9CA3AF', fontSize: 11, textAlign: 'center', marginTop: 4, flexWrap: 'nowrap' },
  activeStepLabelTop: { color: '#fff' },
  progressBox: { backgroundColor: '#19272F', borderRadius: 16, padding: 20, marginBottom: 18, borderWidth: 1, borderColor: '#00D4D4' },
  progressTitle: { color: '#fff', fontSize: 20, fontWeight: 'bold', marginBottom: 6 },
  progressSubtitle: { color: '#9CA3AF', fontSize: 15, marginBottom: 16 },
  stepCard: { backgroundColor: '#273142', borderRadius: 12, padding: 16, marginBottom: 12, borderWidth: 1, borderColor: '#384152', flexDirection: 'row', alignItems: 'center', position: 'relative' },
  stepCardActive: { borderColor: '#00D4D4' },
  stepCircleWrap: { marginRight: 16 },
  stepCircle: { width: 36, height: 36, borderRadius: 18, backgroundColor: '#384152', justifyContent: 'center', alignItems: 'center' },
  stepCircleActive: { backgroundColor: '#00D4D4' },
  stepCircleText: { color: '#fff', fontWeight: 'bold', fontSize: 18 },
  stepTextWrap: { flex: 1 },
  stepTitle: { color: '#fff', fontSize: 16, fontWeight: 'bold' },
  stepTitleActive: { color: '#00D4D4' },
  stepDesc: { color: '#9CA3AF', fontSize: 13 },
  completedBadge: { backgroundColor: '#00D4D4', color: '#1A1F2E', fontWeight: 'bold', fontSize: 12, borderRadius: 8, paddingHorizontal: 10, paddingVertical: 4, position: 'absolute', right: 16, top: 16 },
  detailsBox: { backgroundColor: '#273142', borderRadius: 12, padding: 16, marginBottom: 18 },
  detailsTitle: { color: '#00D4D4', fontSize: 16, fontWeight: 'bold', marginBottom: 8 },
  detailsList: { color: '#fff', fontSize: 14, marginBottom: 12 },
  openPortalButton: { backgroundColor: '#384152', borderRadius: 8, paddingVertical: 10, alignItems: 'center', marginBottom: 10 },
  openPortalText: { color: '#fff', fontWeight: 'bold', fontSize: 15 },
  completeButton: { backgroundColor: '#00D4D4', borderRadius: 8, paddingVertical: 10, alignItems: 'center', marginBottom: 10 },
  completeButtonText: { color: '#1A1F2E', fontWeight: 'bold', fontSize: 15 },
  checklistBox: { backgroundColor: '#FFF8E1', borderRadius: 12, padding: 16, marginBottom: 18, borderWidth: 1, borderColor: '#FFD700' },
  checklistTitle: { color: '#1A1F2E', fontSize: 16, fontWeight: 'bold', marginBottom: 8 },
  checklistItem: { color: '#1A1F2E', fontSize: 14, marginBottom: 4 },
  checklistDate: { color: '#B8860B', fontSize: 13, marginBottom: 2 },
  buttonContainer: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 8, gap: 12 },
  backButton: { flex: 1, padding: 16, borderRadius: 12, borderWidth: 1, borderColor: '#384152', alignItems: 'center' },
  backButtonText: { color: '#fff', fontSize: 16, fontWeight: '600' },
  continueButton: { flex: 1, padding: 16, borderRadius: 12, backgroundColor: '#00D4D4', alignItems: 'center' },
  continueText: { color: '#1A1F2E', fontSize: 16, fontWeight: '600' },
});

export default FilingAssistantScreen;