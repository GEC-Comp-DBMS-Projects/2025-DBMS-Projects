import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, SafeAreaView, Alert, ActivityIndicator } from 'react-native';
import * as DocumentPicker from 'expo-document-picker';
import { CONSENT_BASE_URL } from '../apiConfig';

const steps = [
    { id: 1, title: 'Welcome', isCompleted: true },
    { id: 2, title: 'Document Upload', isActive: true },
    { id: 3, title: 'Data Review', isActive: false },
    { id: 4, title: 'Tax Calculation', isActive: false },
    { id: 5, 'title': 'ITR Generation', 'isActive': false },
    { id: 6, 'title': 'Filing Assistant', 'isActive': false },
    { id: 7, 'title': 'Acknowledgment', 'isActive': false },
    { id: 8, 'title': 'Dashboard', 'isActive': false }
];

const documents = [
  { id: 1, title: 'Form 16', description: 'Salary certificate from employer', icon: '📄', required: true },
  { id: 2, title: 'Form 26AS / AIS', description: 'TDS statement and Annual Information statement', icon: '📄', required: true },
  { id: 3, title: 'Investment Proofs', description: '80C, 80D deductions and other investment certificates', icon: '📄' },
  { id: 4, title: 'Capital Gains Statement', description: 'Stock trading, mutual fund statements', icon: '📄' },
];

const DocumentUploadScreen = ({ navigation }) => {
  const [uploadedFiles, setUploadedFiles] = useState({});

          <View style={styles.headerBar}>
            <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
              <Text style={styles.backText}>←</Text>
            </TouchableOpacity>
            <View style={styles.headerTextContainer}>
              <Text style={styles.headerText}>ITR Filing Assistant</Text>
              <Text style={styles.headerSubText}>Simplify your filing</Text>
            </View>
          </View>
    
          <ScrollView style={styles.mainScroll} showsVerticalScrollIndicator={false} contentContainerStyle={styles.contentContainer}>
            <View style={styles.contentSection}>
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
              <View style={styles.titleContainer}>
                <Text style={styles.title}>Upload Your Documents</Text>
                <Text style={styles.subtitle}>Upload your tax documents for automatic data extraction and processing</Text>
              </View>
    
              {}
              <View style={styles.documentsContainer}>
                {documents.map((doc) => (
                  <View key={doc.id} style={styles.uploadBox}>
                    <View style={styles.docHeader}>
                      <View style={styles.docIconContainer}>
                        <Text style={styles.docIcon}>{doc.icon}</Text>
                      </View>
                      <View style={styles.docInfo}>
                        <View style={styles.docTitleContainer}>
                          <Text style={styles.docTitle}>{doc.title}</Text>
                        </View>
                        <Text style={styles.docDescription}>{doc.description}</Text>
                      </View>
                    </View>
    
                    {}
                    <TouchableOpacity style={styles.uploadArea} onPress={() => handleFileUpload(doc.title)} disabled={uploadedFiles[doc.title]?.uploading}>
                      {uploadedFiles[doc.title] && uploadedFiles[doc.title].processing ? (
                        <View style={{ alignItems: 'center' }}>
                          <ActivityIndicator size="small" color="#00D4D4" />
                          <Text style={{ color: '#00D4D4', marginTop: 8 }}>Processing...</Text>
                        </View>
                      ) : uploadedFiles[doc.title] && uploadedFiles[doc.title].uploaded ? (
                        <View style={{ alignItems: 'center' }}>
                          <Text style={[styles.uploadedFileName]}>{uploadedFiles[doc.title].filename || 'Uploaded file'}</Text>
                          {uploadedFiles[doc.title].fileUploaded ? (
                            <View style={styles.uploadedBadge}>
                              <Text style={styles.uploadedText}>File uploaded</Text>
                            </View>
                          ) : null}
                          {uploadedFiles[doc.title].extracted ? (
                            <View style={styles.extractedBadge}>
                              <Text style={styles.extractedText}>Data extracted successfully</Text>
                            </View>
                          ) : null}
                        </View>
                      ) : (
                        <>
                          <Text style={styles.uploadIcon}>↑</Text>
                          <Text style={styles.uploadText}>Click to upload .pdf, .jpg, .png, or .odf (max 5MB)</Text>
                        </>
                      )}
                    </TouchableOpacity>
                  </View>
                ))}
              </View>
    
              {}
              <View style={styles.buttonContainer}>
                <TouchableOpacity style={styles.backToProfileButton} onPress={() => navigation.goBack()}>
                  <Text style={styles.backToProfileText}>Back to Profile</Text>
                </TouchableOpacity>
                {}
                <TouchableOpacity style={styles.continueButton} onPress={handleContinue}> 
                  <Text style={styles.continueText}>Continue to Data Review</Text>
                </TouchableOpacity>
              </View>
            </View>
          </ScrollView>
        </SafeAreaView>
      );
};

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: '#1A1F2E' },
    headerBar: { paddingTop: 20, paddingHorizontal: 16, paddingBottom: 12, backgroundColor: '#1A1F2E' },
    backButton: { position: 'absolute', left: 16, top: 32, zIndex: 1, padding: 8 },
    backText: { color: '#fff', fontSize: 32, fontWeight: 'bold' },
    headerTextContainer: { alignItems: 'center', justifyContent: 'center', paddingTop: 20, width: '100%' },
    headerText: { color: '#fff', fontSize: 24, fontWeight: 'bold', textAlign: 'center', marginBottom: 8 },
    headerSubText: { color: '#9CA3AF', fontSize: 14, textAlign: 'center', paddingHorizontal: 20 },
    stepsContainer: { paddingVertical: 16, backgroundColor: '#273142', marginHorizontal: 8, borderRadius: 20 },
    stepsScrollContent: { paddingHorizontal: 20 },
    stepsBackground: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, gap: 16 },
    stepItem: { alignItems: 'center', minWidth: 85, maxWidth: 100 },
    stepCircle: { width: 40, height: 40, borderRadius: 20, backgroundColor: '#384152', justifyContent: 'center', alignItems: 'center', marginBottom: 8 },
    activeStep: { backgroundColor: '#00D4D4' },
    stepNumber: { color: '#9CA3AF', fontWeight: 'bold', fontSize: 18 },
    activeStepText: { color: '#1A1F2E' },
    stepLabel: { color: '#9CA3AF', fontSize: 11, textAlign: 'center', marginTop: 4, flexWrap: 'nowrap' },
    activeStepLabel: { color: '#fff' },
    mainScroll: { flex: 1 },
    contentContainer: { flexGrow: 1 },
    contentSection: { padding: 20, paddingBottom: 40 },
    titleContainer: { alignItems: 'center', marginBottom: 24 },
    title: { color: '#fff', fontSize: 24, fontWeight: 'bold', marginBottom: 8, textAlign: 'center' },
    subtitle: { color: '#9CA3AF', fontSize: 16, textAlign: 'center', paddingHorizontal: 20 },
    documentsContainer: { marginTop: 20, marginBottom: 24 },
    uploadBox: { backgroundColor: '#273142', borderRadius: 12, padding: 16, marginBottom: 16 },
    docHeader: { flexDirection: 'row', marginBottom: 12 },
    docIconContainer: { width: 40, height: 40, borderRadius: 20, backgroundColor: '#00D4D4', justifyContent: 'center', alignItems: 'center', marginRight: 12 },
    docIcon: { fontSize: 20 },
    docInfo: { flex: 1 },
    docTitleContainer: { flexDirection: 'row', alignItems: 'center', marginBottom: 4 },
    docTitle: { color: '#fff', fontSize: 16, fontWeight: '600', marginRight: 8 },
    docDescription: { color: '#9CA3AF', fontSize: 14 },
    uploadArea: { borderWidth: 1, borderColor: '#384152', borderStyle: 'dashed', borderRadius: 8, padding: 20, alignItems: 'center' },
    uploadIcon: { color: '#00D4D4', fontSize: 24, marginBottom: 8 },
    uploadText: { color: '#9CA3AF', fontSize: 14, textAlign: 'center' },
  uploadedFileName: { color: '#fff', fontSize: 14, fontWeight: '600', marginBottom: 8 },
  uploadedBadge: { backgroundColor: '#D1FAE5', paddingVertical: 6, paddingHorizontal: 12, borderRadius: 8, marginBottom: 6 },
  uploadedText: { color: '#065F46', fontSize: 13, fontWeight: '600' },
  extractedBadge: { backgroundColor: '#E6FFFA', paddingVertical: 6, paddingHorizontal: 12, borderRadius: 8 },
  extractedText: { color: '#047857', fontSize: 13, fontWeight: '600' },
    buttonContainer: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 24, gap: 12 },
    backToProfileButton: { flex: 1, padding: 16, borderRadius: 12, borderWidth: 1, borderColor: '#384152', alignItems: 'center' },
    backToProfileText: { color: '#fff', fontSize: 16, fontWeight: '600' },
    continueButton: { flex: 1, padding: 16, borderRadius: 12, backgroundColor: '#00D4D4', alignItems: 'center' },
    continueText: { color: '#1A1F2E', fontSize: 16, fontWeight: '600' },
});

export default DocumentUploadScreen;