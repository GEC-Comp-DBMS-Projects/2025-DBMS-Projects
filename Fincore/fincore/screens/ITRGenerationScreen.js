import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator } from 'react-native';

const steps = [
  { id: 1, title: 'Welcome', isCompleted: true },
  { id: 2, title: 'Document Upload', isCompleted: true },
  { id: 3, title: 'Data Review', isCompleted: true },
  { id: 4, title: 'Tax Calculation', isCompleted: true },
  { id: 5, title: 'ITR Generation', isActive: true },
  { id: 6, title: 'Filing Assistant', isActive: false },
  { id: 7, title: 'Acknowledgment', isActive: false },
  { id: 8, title: 'Dashboard', isActive: false }
];

const ITRGenerationScreen = ({ navigation }) => {
  const [selectedForm, setSelectedForm] = useState('ITR-1');
  const [selectedFormat, setSelectedFormat] = useState('XML');
  const [isLoading, setIsLoading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [isGenerated, setIsGenerated] = useState(false);

  const handleGenerateITR = () => {
    setIsLoading(true);
    setProgress(0);
    let progressInterval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          clearInterval(progressInterval);
          setTimeout(() => {
            setIsLoading(false);
            setIsGenerated(true);
          }, 800);
          return prev;
        }
        return prev + 10;
      });
    }, 300);
  };

  const fileName = '1_ABCDE1234F_AY2024-25.xml';
  const fileSize = '45 KB';
  const formType = 'ITR-1';
  const format = 'XML';
  const generatedDate = '26/10/2025';

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {}
      <View style={styles.headerBar}>
        <Text style={styles.headerText}>ITR Filing Assistant</Text>
        <Text style={styles.headerSubText}>Simplify your tax filing</Text>
      </View>

      {isLoading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#00D4D4" />
          <Text style={styles.loadingText}>Generating Your ITR File</Text>
          <Text style={styles.loadingSubText}>Please wait while we prepare your tax return...</Text>
          <View style={styles.progressBarContainer}>
            <View style={[styles.progressBar, { width: `${progress}%` }]} />
          </View>
          <Text style={styles.progressText}>{progress}% Complete</Text>
        </View>
      ) : isGenerated ? (
        <View style={styles.generatedBox}>
          <View style={styles.successIconBox}>
            <Text style={styles.successIcon}>✔️</Text>
          </View>
          <Text style={styles.generatedTitle}>ITR File Generated Successfully!</Text>
          <Text style={styles.generatedSubText}>Your ITR-1 form is ready for filing.{"\n"}File size: {fileSize}</Text>
          <TouchableOpacity style={styles.downloadButton}>
            <Text style={styles.downloadButtonText}>Download ITR File</Text>
          </TouchableOpacity>
          <View style={styles.fileDetailsBox}>
            <Text style={styles.fileDetailsTitle}>File Details</Text>
            <View style={styles.fileDetailsRow}><Text style={styles.fileDetailsLabel}>File Name:</Text><Text style={styles.fileDetailsValue}>{fileName}</Text></View>
            <View style={styles.fileDetailsRow}><Text style={styles.fileDetailsLabel}>Form Type:</Text><Text style={styles.fileDetailsValue}>{formType}</Text></View>
            <View style={styles.fileDetailsRow}><Text style={styles.fileDetailsLabel}>Format:</Text><Text style={styles.fileDetailsValue}>{format}</Text></View>
            <View style={styles.fileDetailsRow}><Text style={styles.fileDetailsLabel}>Generated:</Text><Text style={styles.fileDetailsValue}>{generatedDate}</Text></View>
          </View>
          <View style={styles.importantNotesBox}>
            <Text style={styles.importantNotesTitle}>Important Notes</Text>
            <Text style={styles.importantNote}>• Keep this file safe until your return is processed</Text>
            <Text style={styles.importantNote}>• File your return before the due date: September 15, 2025</Text>
            <Text style={styles.importantNote}>• Verify your return within 120 days of filing</Text>
          </View>
          <View style={styles.generatedButtonContainer}>
            <TouchableOpacity style={styles.backButton} onPress={() => { setIsGenerated(false); }}>
              <Text style={styles.backButtonText}>Back to Tax Calculation</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.continueButton} onPress={() => navigation.navigate('FilingAssistant')}>
              <Text style={styles.continueText}>Continue to Filing Guide</Text>
            </TouchableOpacity>
          </View>
        </View>
      ) : (
        <View>
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
          <View style={styles.cardBox}>
            <Text style={styles.cardTitle}>Generate Your ITR File</Text>
            <Text style={styles.cardSubtitle}>Choose the correct ITR form and generate a ready-to-file document</Text>
            <Text style={styles.selectLabel}>Select ITR Form <Text style={styles.suggested}>Auto-suggested: ITR-1</Text></Text>
            <View style={styles.radioGroup}>
              {['ITR-1', 'ITR-2', 'ITR-3'].map((form) => (
                <TouchableOpacity
                  key={form}
                  style={[styles.radioCard, selectedForm === form && styles.radioCardActive]}
                  onPress={() => setSelectedForm(form)}
                >
                  <View style={styles.radioRow}>
                    <View style={[styles.radioDot, selectedForm === form && styles.radioDotActive]} />
                    <Text style={styles.radioTitle}>{form}</Text>
                  </View>
                  <Text style={styles.radioDesc}>{
                    form === 'ITR-1' ? 'For salary income up to ₹50 lakhs' :
                    form === 'ITR-2' ? 'For individuals with capital gains' :
                    'For business/professional income'
                  }</Text>
                </TouchableOpacity>
              ))}
            </View>
            {}
            <Text style={[styles.selectLabel, { marginTop: 18 }]}>File Format</Text>
            <View style={styles.radioGroup}>
              {['XML', 'Excel'].map((format) => (
                <TouchableOpacity
                  key={format}
                  style={[styles.radioCard, selectedFormat === format && styles.radioCardActive]}
                  onPress={() => setSelectedFormat(format)}
                >
                  <View style={styles.radioRow}>
                    <View style={[styles.radioDot, selectedFormat === format && styles.radioDotActive]} />
                    <Text style={styles.radioTitle}>{format === 'XML' ? 'XML/JSON File' : 'Excel Utility'}</Text>
                    {format === 'XML' && <Text style={styles.recommended}>Recommended</Text>}
                  </View>
                  <Text style={styles.radioDesc}>
                    {format === 'XML'
                      ? 'Direct upload to Income Tax Portal. Fastest filing method.'
                      : 'Pre-filled Excel file for offline utility. Requires manual import.'}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
            {}
            <Text style={[styles.selectLabel, { marginTop: 18 }]}>Form Summary</Text>
            <View style={styles.summaryBox}>
              <View style={styles.summaryRow}><Text style={styles.summaryLabel}>PAN:</Text><Text style={styles.summaryValue}>ABCDE1234F</Text></View>
              <View style={styles.summaryRow}><Text style={styles.summaryLabel}>Assessment Year:</Text><Text style={styles.summaryValue}>2024-25</Text></View>
              <View style={styles.summaryRow}><Text style={styles.summaryLabel}>Gross Income:</Text><Text style={styles.summaryValue}>₹8,75,000</Text></View>
              <View style={styles.summaryRow}><Text style={styles.summaryLabel}>Tax Payable:</Text><Text style={styles.summaryValue}>₹19,240</Text></View>
            </View>
            {}
            <View style={styles.buttonContainer}>
              <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
                <Text style={styles.backButtonText}>Back to Tax Calculation</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.continueButton} onPress={handleGenerateITR}>
                <Text style={styles.continueText}>Generate ITR File</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      )}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#1A1F2E' },
  contentContainer: { padding: 20, paddingBottom: 40 },
  headerBar: { alignItems: 'center', marginBottom: 16, marginTop: 18 },
  headerText: { color: '#fff', fontSize: 24, fontWeight: 'bold', textAlign: 'center', marginBottom: 8 },
  headerSubText: { color: '#9CA3AF', fontSize: 14, textAlign: 'center', marginBottom: 16 },
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
  cardBox: { backgroundColor: '#273142', borderRadius: 16, padding: 20, marginBottom: 18, borderWidth: 1, borderColor: '#384152' },
  cardTitle: { color: '#fff', fontSize: 20, fontWeight: 'bold', marginBottom: 6 },
  cardSubtitle: { color: '#9CA3AF', fontSize: 13, marginBottom: 14 },
  selectLabel: { color: '#fff', fontSize: 15, fontWeight: 'bold', marginBottom: 8 },
  suggested: { color: '#00D4D4', backgroundColor: '#1A1F2E', borderRadius: 8, paddingHorizontal: 8, paddingVertical: 2, fontSize: 12, marginLeft: 8 },
  radioGroup: { marginBottom: 10 },
  radioCard: { backgroundColor: '#1A1F2E', borderRadius: 12, padding: 14, marginBottom: 12, borderWidth: 1, borderColor: '#384152' },
  radioCardActive: { borderColor: '#00D4D4', backgroundColor: '#19272F' },
  radioRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 6 },
  radioDot: { width: 16, height: 16, borderRadius: 8, borderWidth: 2, borderColor: '#384152', marginRight: 10, backgroundColor: '#273142' },
  radioDotActive: { borderColor: '#00D4D4', backgroundColor: '#00D4D4' },
  radioTitle: { color: '#fff', fontWeight: 'bold', fontSize: 15, marginRight: 8 },
  radioDesc: { color: '#9CA3AF', fontSize: 13, marginBottom: 6 },
  buttonContainer: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 16, gap: 12 },
  backButton: { flex: 1, padding: 16, borderRadius: 12, borderWidth: 1, borderColor: '#384152', alignItems: 'center' },
  backButtonText: { color: '#fff', fontSize: 16, fontWeight: '600' },
  continueButton: { flex: 1, padding: 16, borderRadius: 12, backgroundColor: '#00D4D4', alignItems: 'center' },
  continueText: { color: '#1A1F2E', fontSize: 16, fontWeight: '600' },
  loadingContainer: { alignItems: 'center', justifyContent: 'center', marginTop: 40 },
  loadingText: { color: '#fff', fontSize: 18, fontWeight: 'bold', marginTop: 20 },
  loadingSubText: { color: '#9CA3AF', fontSize: 14, marginTop: 10, textAlign: 'center' },
  progressBarContainer: { height: 10, width: '80%', backgroundColor: '#384152', borderRadius: 5, marginTop: 20 },
  progressBar: { height: '100%', backgroundColor: '#00D4D4', borderRadius: 5 },
  progressText: { color: '#fff', fontSize: 14, marginTop: 10 },
  generatedBox: { backgroundColor: '#19272F', borderRadius: 16, padding: 20, marginTop: 20, alignItems: 'center', borderWidth: 1, borderColor: '#00D4D4' },
  successIconBox: { marginBottom: 12 },
  successIcon: { fontSize: 48, color: '#00D4D4' },
  generatedTitle: { color: '#fff', fontSize: 20, fontWeight: 'bold', marginBottom: 8, textAlign: 'center' },
  generatedSubText: { color: '#9CA3AF', fontSize: 15, marginBottom: 16, textAlign: 'center' },
  downloadButton: { backgroundColor: '#00D4D4', borderRadius: 8, paddingVertical: 12, paddingHorizontal: 24, marginBottom: 18 },
  downloadButtonText: { color: '#1A1F2E', fontWeight: 'bold', fontSize: 16 },
  fileDetailsBox: { backgroundColor: '#273142', borderRadius: 12, padding: 16, marginBottom: 16, width: '100%' },
  fileDetailsTitle: { color: '#fff', fontSize: 16, fontWeight: 'bold', marginBottom: 8 },
  fileDetailsRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 4 },
  fileDetailsLabel: { color: '#9CA3AF', fontSize: 14 },
  fileDetailsValue: { color: '#fff', fontSize: 14, fontWeight: 'bold' },
  importantNotesBox: { backgroundColor: '#273142', borderRadius: 12, padding: 16, marginBottom: 16, width: '100%' },
  importantNotesTitle: { color: '#00D4D4', fontSize: 15, fontWeight: 'bold', marginBottom: 8 },
  importantNote: { color: '#9CA3AF', fontSize: 13, marginBottom: 4 },
  generatedButtonContainer: { flexDirection: 'row', justifyContent: 'space-between', width: '100%', marginTop: 8, gap: 12 },
  summaryLabel: { color: '#fff', fontSize: 14 },
  summaryValue: { color: '#fff', fontSize: 15, fontWeight: 'bold' },
});

export default ITRGenerationScreen;