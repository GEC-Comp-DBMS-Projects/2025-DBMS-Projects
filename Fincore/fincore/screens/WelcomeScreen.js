import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, SafeAreaView, Image, ScrollView } from 'react-native';

const steps = [
  { id: 1, title: 'Welcome', isActive: true },
  { id: 2, title: 'Document Upload', isActive: false },
  { id: 3, title: 'Data Review', isActive: false },
  { id: 4, title: 'Tax Calculation', isActive: false },
  { id: 5, title: 'ITR Generation', isActive: false },
  { id: 6, title: 'Filing Assistant', isActive: false },
  { id: 7, title: 'Acknowledgment', isActive: false },
  { id: 8, title: 'Dashboard', isActive: false }
];

const features = [
  {
    id: 1,
    title: 'Smart Document Processing',
    description: 'Upload your tax documents and let AI extract the data automatically',
    icon: '📄'
  },
  {
    id: 2,
    title: 'Tax Calculation & Optimization',
    description: 'Compare tax rules to save money and get suggestions for maximum savings',
    icon: '💰'
  },
  {
    id: 3,
    title: 'ITR Form Generation',
    description: 'Generate accurate ITR forms pre-filled with your data',
    icon: '📝'
  },
  {
    id: 4,
    title: 'Guided Filing',
    description: 'Step by step assistance for filing on the Income Tax Portal',
    icon: '✅'
  }
];

const WelcomeScreen = ({ navigation }) => {

  return (
    <SafeAreaView style={styles.container}>
      {}
      <View style={styles.headerBar}>
        <TouchableOpacity 
          style={styles.backButton} 
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.backText}>←</Text>
        </TouchableOpacity>
        <View style={styles.headerTextContainer}>
          <Text style={styles.headerText}>ITR Filing Assistant</Text>
          <Text style={styles.headerSubText}>Simplify your filing</Text>
        </View>
      </View>

      <ScrollView 
        style={styles.mainScroll}
        showsVerticalScrollIndicator={false}
      >
        {}
        <View style={styles.stepsContainer}>
          <ScrollView 
            horizontal 
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.stepsScrollContent}
          >
            <View style={styles.stepsBackground}>
              {steps.map((step) => (
                <View key={step.id} style={styles.stepItem}>
                  <View style={[styles.stepCircle, step.isActive && styles.activeStep]}>
                    <Text style={[styles.stepNumber, step.isActive && styles.activeStepText]}>
                      {step.id}
                    </Text>
                  </View>
                  <Text style={[styles.stepLabel, step.isActive && styles.activeStepLabel]}>
                    {step.title}
                  </Text>
                </View>
              ))}
            </View>
          </ScrollView>
        </View>

        {}
        <View style={styles.welcomeSection}>
          <View style={styles.shieldContainer}>
            <Text style={styles.shieldIcon}>🛡️</Text>
          </View>
          <Text style={styles.headerTitle}>Welcome to ITR Filing Assistant</Text>
          <Text style={styles.headerSubtitle}>Simplify your tax filing. Fast, accurate, and secure.</Text>
        </View>

        {}
        <View style={styles.content}>
          <Text style={styles.subtitle}>How it works:</Text>
          <View style={styles.stepsContainer2}>
            <View style={styles.stepRow}>
              <View style={styles.stepCircle2}>
                <Text style={styles.stepNumber2}>1</Text>
              </View>
              <Text style={styles.stepText}>Upload Documents</Text>
            </View>
            <View style={styles.stepRow}>
              <View style={styles.stepCircle2}>
                <Text style={styles.stepNumber2}>2</Text>
              </View>
              <Text style={styles.stepText}>Review & Calculate</Text>
            </View>
            <View style={styles.stepRow}>
              <View style={styles.stepCircle2}>
                <Text style={styles.stepNumber2}>3</Text>
              </View>
              <Text style={styles.stepText}>File your Return</Text>
            </View>
          </View>

          <Text style={styles.subtitle}>What you'll get:</Text>
          <View style={styles.features}>
            {features.map(feature => (
              <View key={feature.id} style={styles.featureCard}>
                <Text style={styles.featureIcon}>{feature.icon}</Text>
                <View style={styles.featureContent}>
                  <Text style={styles.featureTitle}>{feature.title}</Text>
                  <Text style={styles.featureDescription}>{feature.description}</Text>
                </View>
              </View>
            ))}
          </View>

          <View style={styles.securityNote}>
            <Text style={styles.securityIcon}>🔒</Text>
            <View>
              <Text style={styles.securityTitle}>Your Data is secure</Text>
              <Text style={styles.securityText}>
                All your financial information is encrypted and processed securely. We never store sensitive data longer than necessary.
              </Text>
            </View>
          </View>

          <TouchableOpacity 
            style={styles.button} 
            onPress={() => navigation.navigate('DocumentsUploadScreen')}
          >
            <Text style={styles.buttonText}>Start ITR Filing Process</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1A1F2E',
  },
  headerBar: {
    paddingTop: 20,
    paddingHorizontal: 16,
    paddingBottom: 12,
    backgroundColor: '#1A1F2E',
  },
  backButton: {
    position: 'absolute',
    left: 16,
    top: 32,
    zIndex: 1,
    padding: 8,
  },
  backText: {
    color: '#fff',
    fontSize: 32,
    fontWeight: 'bold',
  },
  headerTextContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingTop: 20,
    width: '100%',
  },
  headerText: {
    color: '#fff',
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
  },
  headerSubText: {
    color: '#9CA3AF',
    fontSize: 14,
    textAlign: 'center',
    paddingHorizontal: 20,
  },
  mainScroll: {
    flex: 1,
  },
  welcomeSection: {
    paddingHorizontal: 20,
    paddingVertical: 24,
    alignItems: 'center',
  },
  shieldContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#00D4D4',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  shieldIcon: {
    fontSize: 24,
  },
  headerTitle: {
    color: '#fff',
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
  },
  headerSubtitle: {
    color: '#9CA3AF',
    fontSize: 14,
    textAlign: 'center',
    lineHeight: 20,
    paddingHorizontal: 20,
  },
  stepsContainer: {
    paddingVertical: 16,
    backgroundColor: '#273142',
    marginHorizontal: 16,
    borderRadius: 20,
  },
  stepsScrollContent: {
    paddingHorizontal: 20,
  },
  stepsBackground: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    gap: 16,
  },
  stepItem: {
    alignItems: 'center',
    minWidth: 85,
    maxWidth: 100,
  },
  stepCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#384152',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  activeStep: {
    backgroundColor: '#00D4D4',
  },
  stepNumber: {
    color: '#9CA3AF',
    fontWeight: 'bold',
    fontSize: 18,
  },
  activeStepText: {
    color: '#1A1F2E',
  },
  stepLabel: {
    color: '#9CA3AF',
    fontSize: 11,
    textAlign: 'center',
    marginTop: 4,
    flexWrap: 'nowrap',
  },
  activeStepLabel: {
    color: '#fff',
  },
  content: {
    padding: 24,
    paddingBottom: 40,
  },
  subtitle: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 16,
  },
  stepsContainer2: {
    backgroundColor: '#273142',
    borderRadius: 16,
    padding: 20,
    marginBottom: 24,
  },
  stepRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  stepCircle2: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#00D4D4',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  stepNumber2: {
    color: '#1A1F2E',
    fontSize: 18,
    fontWeight: 'bold',
  },
  stepText: {
    color: '#fff',
    fontSize: 16,
    flex: 1,
  },
  features: {
    marginBottom: 24,
  },
  featureCard: {
    flexDirection: 'row',
    backgroundColor: '#273142',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    alignItems: 'center',
  },
  featureIcon: {
    fontSize: 24,
    marginRight: 16,
  },
  featureContent: {
    flex: 1,
  },
  featureTitle: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  featureDescription: {
    color: '#9CA3AF',
    fontSize: 14,
    lineHeight: 20,
  },
  securityNote: {
    flexDirection: 'row',
    backgroundColor: '#273142',
    borderRadius: 12,
    padding: 16,
    marginBottom: 24,
    alignItems: 'center',
  },
  securityIcon: {
    fontSize: 24,
    marginRight: 16,
  },
  securityTitle: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  securityText: {
    color: '#9CA3AF',
    fontSize: 14,
    lineHeight: 20,
  },
  button: {
    backgroundColor: '#00D4D4',
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 'auto',
  },
  buttonText: {
    color: '#1A1F2E',
    fontWeight: 'bold',
    fontSize: 16,
  },
});

export default WelcomeScreen;