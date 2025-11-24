import { Picker } from '@react-native-picker/picker';
import axios from 'axios';
import { LinearGradient } from 'expo-linear-gradient';
import LottieView from 'lottie-react-native';
import React, { useRef, useState } from 'react';
import {
  Animated,
  Dimensions,
  Easing,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';

const { width } = Dimensions.get('window');

export default function AIBuildScreen() {
  const [purpose, setPurpose] = useState('Gaming');
  const [budget, setBudget] = useState('1500');
  const [customPrompt, setCustomPrompt] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const expandAnim = useRef(new Animated.Value(0)).current;

  const generateBuild = async () => {
    setLoading(true);
    setResult(null);
    Animated.timing(expandAnim, {
      toValue: 0,
      duration: 300,
      useNativeDriver: true,
    }).start();

    try {
      const res = await axios.post('URL_Backend/api/ai-recommend', {
        purpose,
        budget,
        customPrompt: customPrompt.trim().slice(0, 100),
      });
      setResult(res.data);
      Animated.timing(expandAnim, {
        toValue: 1,
        duration: 500,
        easing: Easing.out(Easing.exp),
        useNativeDriver: true,
      }).start();
    } catch {
      setResult({ error: '⚠️ Failed to generate build. Please try again.' });
    } finally {
      setLoading(false);
    }
  };

  return (
    <LinearGradient
      colors={['#0f2027', '#203a43', '#2c5364']}
      style={styles.container}
    >
      <StatusBar barStyle="light-content" />

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scroll}
      >
        <Text style={styles.title}>AI PC Builder</Text>
        <Text style={styles.subtitle}>
          Smartly generate your dream PC build powered by intelligent AI matching.
        </Text>

        <View style={styles.formCard}>
          <Text style={styles.section}>Preferences</Text>

          <Text style={styles.label}>Purpose</Text>
          <View style={styles.pickerWrap}>
            <Picker
              selectedValue={purpose}
              onValueChange={setPurpose}
              style={styles.picker}
              dropdownIconColor="#00eaff"
            >
              <Picker.Item label="Gaming" value="Gaming" />
              <Picker.Item label="Video Editing" value="Video Editing" />
              <Picker.Item label="Streaming" value="Streaming" />
              <Picker.Item label="Productivity" value="Productivity" />
              <Picker.Item label="AI / ML Workstation" value="AI / ML Workstation" />
            </Picker>
          </View>

          <Text style={styles.label}>Budget</Text>
          <TextInput
            value={budget}
            onChangeText={setBudget}
            keyboardType="numeric"
            style={styles.input}
            placeholder="INR"
            placeholderTextColor="#aaa"
          />

          <Text style={styles.label}>Custom Preferences</Text>
          <TextInput
            value={customPrompt}
            onChangeText={setCustomPrompt}
            style={[styles.input, { height: 90, textAlignVertical: 'top' }]}
            multiline
            placeholder="Surprise me with a balanced setup for gaming and streaming!"
            placeholderTextColor="#aaa"
          />
        </View>

        <TouchableOpacity
          onPress={generateBuild}
          disabled={loading}
          activeOpacity={0.8}
        >
          <LinearGradient
            colors={['#00c6ff', '#0072ff']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={[styles.button, loading && { opacity: 0.7 }]}
          >
            <Text style={styles.buttonText}>
              {loading ? 'Generating...' : 'Generate Build 🚀'}
            </Text>
          </LinearGradient>
        </TouchableOpacity>

        {loading && (
          <LottieView
            source={require('./../../assets/animations/ai-loader.json')}
            autoPlay
            loop
            style={styles.lottie}
          />
        )}

        {result && (
          <Animated.View
            style={[
              styles.resultCard,
              {
                opacity: expandAnim,
                transform: [
                  {
                    translateY: expandAnim.interpolate({
                      inputRange: [0, 1],
                      outputRange: [40, 0],
                    }),
                  },
                ],
              },
            ]}
          >
            {result.error ? (
              <Text style={styles.error}>{result.error}</Text>
            ) : (
              <>
                <Text style={styles.resultTitle}>💡 Recommended Build</Text>
                <View style={styles.divider} />

                {Object.keys(result.build || {}).map((key) => (
                  <View key={key} style={styles.resultRow}>
                    <Text style={styles.resultLabel}>{key}</Text>
                    <Text style={styles.resultValue}>
                      {result.build[key]?.name || 'N/A'}
                    </Text>
                  </View>
                ))}

                <View style={styles.divider} />
                <Text style={styles.price}>
                  💰 Total: {result.build?.EstimatedTotal ?? 'N/A'}
                </Text>
                <Text style={styles.reason}>{result.reasoning}</Text>
              </>
            )}
          </Animated.View>
        )}
      </ScrollView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  scroll: {
    padding: 20,
    paddingBottom: 80,
  },
  title: {
    fontSize: 32,
    fontWeight: '900',
    color: '#fff',
    textAlign: 'center',
    marginTop: 30,
    letterSpacing: 0.8,
  },
  subtitle: {
    textAlign: 'center',
    color: '#C9E6FF',
    fontSize: 15,
    marginBottom: 25,
    marginTop: 8,
    paddingHorizontal: 10,
  },
  formCard: {
    backgroundColor: 'rgba(255,255,255,0.1)',
    borderRadius: 20,
    padding: 18,
    marginBottom: 24,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.15)',
    backdropFilter: 'blur(20px)',
  },
  section: {
    color: '#00eaff',
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 14,
  },
  label: {
    color: '#DCE7F2',
    marginBottom: 6,
    marginTop: 8,
    fontWeight: '600',
  },
  pickerWrap: {
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.25)',
    overflow: 'hidden',
    marginBottom: 8,
  },
  picker: { color: '#fff', height: 50 },
  input: {
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.25)',
    color: '#fff',
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginBottom: 6,
    backgroundColor: 'rgba(255,255,255,0.05)',
  },
  button: {
    borderRadius: 16,
    paddingVertical: 15,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 24,
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 16,
    letterSpacing: 0.3,
  },
  lottie: {
    width: 180,
    height: 180,
    alignSelf: 'center',
    marginVertical: 20,
  },
  resultCard: {
    backgroundColor: 'rgba(255,255,255,0.1)',
    borderRadius: 20,
    padding: 20,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.15)',
  },
  resultTitle: {
    color: '#00eaff',
    fontWeight: '800',
    fontSize: 20,
    textAlign: 'center',
    marginBottom: 10,
  },
  divider: {
    height: 1,
    backgroundColor: 'rgba(255,255,255,0.2)',
    marginVertical: 10,
  },
  resultRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 6,
  },
  resultLabel: { color: '#E3EEFF', fontWeight: '600' },
  resultValue: { color: '#fff', maxWidth: '70%', textAlign: 'right' },
  price: {
    color: '#6BFFB8',
    fontWeight: '800',
    fontSize: 17,
    textAlign: 'center',
    marginTop: 10,
  },
  reason: {
    color: '#CDE3F5',
    fontStyle: 'italic',
    textAlign: 'center',
    marginTop: 8,
    lineHeight: 20,
  },
  error: {
    color: '#FF7B7B',
    textAlign: 'center',
    fontWeight: '700',
  },
});
