import { Picker } from '@react-native-picker/picker';
import axios from 'axios';
import LottieView from 'lottie-react-native';
import React, { useRef, useState } from 'react';
import {
    Animated,
    Dimensions,
    Easing,
    ScrollView,
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
  const [error, setError] = useState('');
  const [expanded, setExpanded] = useState(false);

  const expandAnim = useRef(new Animated.Value(0)).current;

  const animateExpand = (toValue: number) => {
    Animated.timing(expandAnim, {
      toValue,
      duration: 450,
      easing: Easing.out(Easing.exp),
      useNativeDriver: false,
    }).start();
  };

  const generateBuild = async () => {
    setLoading(true);
    setError('');
    setResult(null);
    setExpanded(false);
    animateExpand(0);

    try {
      const res = await axios.post('http://10.102.232.54:5000/api/ai-recommend', {
        purpose,
        budget,
        customPrompt: customPrompt.trim().slice(0, 100),
      });
      setResult(res.data);
      setTimeout(() => {
        setExpanded(true);
        animateExpand(1);
      }, 300);
    } catch (e: any) {
      setError(e.message || 'Failed to generate build.');
    } finally {
      setLoading(false);
    }
  };

  const animatedStyle = {
    opacity: expandAnim,
    transform: [
      {
        translateY: expandAnim.interpolate({
          inputRange: [0, 1],
          outputRange: [30, 0],
        }),
      },
    ],
  };

  return (
    <ScrollView
      contentContainerStyle={styles.container}
      showsVerticalScrollIndicator={false}
    >
      <Text style={styles.title}>⚙️ AI PC Builder</Text>
      <Text style={styles.subtitle}>
        Let AI design your perfect PC setup based on your preferences and budget.
      </Text>

      <View style={styles.card}>
        <Text style={styles.sectionTitle}>🧠 Build Preferences</Text>

        <Text style={styles.label}>Purpose</Text>
        <View style={styles.pickerContainer}>
          <Picker
            selectedValue={purpose}
            onValueChange={setPurpose}
            style={styles.picker}
            dropdownIconColor="#0B3C8A"
          >
            <Picker.Item label="Gaming" value="Gaming" />
            <Picker.Item label="Video Editing" value="Video Editing" />
            <Picker.Item label="Streaming" value="Streaming" />
            <Picker.Item label="Office / Productivity" value="Office / Productivity" />
            <Picker.Item label="AI / ML Workstation" value="AI / ML Workstation" />
          </Picker>
        </View>

        <Text style={styles.label}>Budget</Text>
        <TextInput
          style={styles.input}
          keyboardType="numeric"
          value={budget}
          onChangeText={setBudget}
          placeholder="Enter your budget"
          placeholderTextColor="#999"
        />

        <Text style={styles.label}>Custom Preferences (optional)</Text>
        <TextInput
          style={[styles.input, styles.textArea]}
          multiline
          value={customPrompt}
          onChangeText={setCustomPrompt}
          placeholder="e.g., prefer RGB, compact case, quiet cooling..."
          placeholderTextColor="#999"
          maxLength={100}
        />

        <TouchableOpacity
          onPress={generateBuild}
          style={[styles.button, loading && { opacity: 0.7 }]}
          disabled={loading}
        >
          <Text style={styles.buttonText}>
            {loading ? 'Generating...' : 'Generate Build 🚀'}
          </Text>
        </TouchableOpacity>

        {loading && (
          <LottieView
            source={require('./../../assets/animations/ai-loader.json')}
            autoPlay
            loop
            style={styles.lottie}
          />
        )}

        {error ? <Text style={styles.error}>{error}</Text> : null}
      </View>

      {result && (
        <Animated.View style={[styles.resultCard, animatedStyle]}>
          <TouchableOpacity onPress={() => {
            const newState = !expanded;
            setExpanded(newState);
            animateExpand(newState ? 1 : 0);
          }}>
            <Text style={styles.resultHeader}>💡 AI Recommended Build</Text>
          </TouchableOpacity>

          {expanded && (
            <View>
              <View style={styles.divider} />

              {Object.keys(result.build || {}).map((key) => (
                <View key={key} style={styles.resultRow}>
                  <Text style={styles.resultLabel}>{key}:</Text>
                  <Text style={styles.resultValue}>{result.build[key]?.name || 'N/A'}</Text>
                </View>
              ))}

              <View style={styles.divider} />

              <Text style={styles.price}>
                💵 Estimated Total: {result.build?.EstimatedTotal ?? 'N/A'}
              </Text>

              <Text style={styles.reason}>{result.reasoning}</Text>
            </View>
          )}
        </Animated.View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    padding: 24,
    backgroundColor: '#EEF3FC',
    alignItems: 'center',
  },
  title: {
    fontSize: 30,
    fontWeight: '900',
    color: '#0B3C8A',
    textAlign: 'center',
    marginBottom: 6,
  },
  subtitle: {
    textAlign: 'center',
    color: '#4D4D4D',
    fontSize: 15,
    marginBottom: 24,
    maxWidth: width * 0.85,
  },
  card: {
    width: '100%',
    backgroundColor: '#FFFFFF',
    borderRadius: 18,
    padding: 20,
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowOffset: { width: 0, height: 4 },
    shadowRadius: 8,
    elevation: 3,
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#0B3C8A',
    marginBottom: 14,
  },
  label: {
    marginBottom: 6,
    fontWeight: '600',
    color: '#333',
  },
  pickerContainer: {
    borderWidth: 1,
    borderColor: '#B4C5E4',
    borderRadius: 12,
    backgroundColor: '#F9FBFF',
    marginBottom: 16,
    overflow: 'hidden',
  },
  picker: {
    height: 50,
    color: '#222',
  },
  input: {
    borderWidth: 1,
    borderColor: '#B4C5E4',
    borderRadius: 12,
    padding: 12,
    backgroundColor: '#F9FBFF',
    marginBottom: 16,
    color: '#333',
    fontSize: 15,
  },
  textArea: {
    height: 90,
    textAlignVertical: 'top',
  },
  button: {
    backgroundColor: '#0B3C8A',
    paddingVertical: 14,
    borderRadius: 12,
    shadowColor: '#0B3C8A',
    shadowOpacity: 0.4,
    shadowOffset: { width: 0, height: 4 },
    shadowRadius: 8,
    alignItems: 'center',
    marginTop: 8,
  },
  buttonText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 16,
  },
  lottie: {
    width: 180,
    height: 180,
    alignSelf: 'center',
    marginTop: 10,
  },
  error: {
    color: '#D64541',
    textAlign: 'center',
    marginTop: 14,
    fontWeight: '600',
  },
  resultCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    padding: 20,
    width: '100%',
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowOffset: { width: 0, height: 3 },
    shadowRadius: 8,
    elevation: 3,
    marginBottom: 20,
  },
  resultHeader: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#0B3C8A',
    textAlign: 'center',
  },
  divider: {
    height: 1,
    backgroundColor: '#E0E6F1',
    marginVertical: 12,
  },
  resultRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 6,
  },
  resultLabel: {
    fontWeight: '600',
    color: '#333',
  },
  resultValue: {
    color: '#222',
    textAlign: 'right',
    maxWidth: '70%',
  },
  price: {
    color: '#0E9A61',
    fontWeight: '800',
    fontSize: 17,
    textAlign: 'center',
    marginTop: 12,
  },
  reason: {
    fontStyle: 'italic',
    color: '#555',
    marginTop: 10,
    textAlign: 'center',
  },
});
