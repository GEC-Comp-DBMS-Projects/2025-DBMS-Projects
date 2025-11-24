import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
  StatusBar,
  Image,
} from 'react-native';
import { Stack, useRouter } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons';

// The system prompt defines the AI's role and boundaries
const SYSTEM_PROMPT =
  'You are B-FIT AI, a friendly and encouraging fitness assistant. Your expertise is in exercise, nutrition, and workout planning. Answer user questions in a clear, concise, and supportive way. Always prioritize safety. Do not provide medical advice. If a user asks for medical advice, gently decline and suggest they consult a healthcare professional.';

const AIChatScreen = () => {
  const router = useRouter();
  const [messages, setMessages] = useState([
    {
      role: 'model',
      text: "Hello! I'm your AI Assistant. Ask me anything about fitness, nutrition, or your workout plan.",
    },
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const scrollViewRef = useRef(null);

  /**
   * Appends a new message to the chat history
   * @param {string} role - 'user' or 'model'
   * @param {string} text - The message content
   */
  const addMessage = (role, text) => {
    setMessages((prevMessages) => [...prevMessages, { role, text }]);
  };

  /**
   * Scrolls the ScrollView to the bottom
   */
  const scrollToBottom = () => {
    scrollViewRef.current?.scrollToEnd({ animated: true });
  };

  // Scroll to bottom when messages change
  useEffect(() => {
    scrollToBottom();
  }, [messages, loading]);

  /**
   * Handles sending the user's message to the Gemini API
   */
  const handleSend = async () => {
    const userInput = input.trim();
    if (userInput === '' || loading) return;

    setInput(''); // Clear input immediately
    addMessage('user', userInput);
    setLoading(true);

    // Prepare the API request payload
    // We send the system prompt and the entire chat history
    const payload = {
      contents: [
        ...messages.map((msg) => ({
          role: msg.role,
          parts: [{ text: msg.text }],
        })),
        {
          role: 'user',
          parts: [{ text: userInput }],
        },
      ],
      systemInstruction: {
        parts: [{ text: SYSTEM_PROMPT }],
      },
    };

    // --- 1. PASTE YOUR API KEY HERE ---
    // Get your key from https://aistudio.google.com/
    const apiKey = 'AIzaSyDu4mht33ADOIeyNc7MtJGUcjgv0seQSB0'; 

    // --- IMPORTANT ---
    // If you see "PASTE_YOUR_API_KEY_HERE", the chat will not work.
    if (apiKey === 'PASTE_YOUR_API_KEY_HERE' || apiKey === '') {
        console.error("Gemini API Error: API key is missing.");
        addMessage('model', "Sorry, the AI Assistant is not configured correctly. (Missing API Key)");
        setLoading(false);
        return;
    }

    const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key=${apiKey}`;

    try {
      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      });

      const data = await response.json(); // Always try to parse JSON

      if (!response.ok) {
        // Log the detailed error from the API
        console.error('Gemini API Error Response:', data);
        throw new Error(data.error?.message || `API Error: ${response.statusText}`);
      }

      if (data.candidates && data.candidates.length > 0) {
        const modelResponse = data.candidates[0].content.parts[0].text;
        addMessage('model', modelResponse);
      } else {
        // This might happen if the content was blocked
        console.warn('Gemini API Warning:', data);
        throw new Error('No response from AI. The content might have been blocked.');
      }
    } catch (error) {
      // --- 2. Improved error logging ---
      console.error('Gemini API Error:', error.message);
      addMessage('model', "Sorry, I'm having trouble connecting right now.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar barStyle="dark-content" />

      {/* Custom Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <FontAwesome5 name="arrow-left" size={20} color="#333" />
        </TouchableOpacity>
        <View style={styles.logoContainer}>
          <Image source={require('../../assets/images/logo.png')} style={styles.logo} />
          <Text style={styles.appName}>AI Assistant</Text>
        </View>
        <View style={{ width: 40 }} />{/* Spacer */}
      </View>

      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 0}
      >
        {/* Chat History */}
        <ScrollView
          style={styles.chatContainer}
          contentContainerStyle={styles.chatContent}
          ref={scrollViewRef}
          onContentSizeChange={scrollToBottom}
        >
          {messages.map((msg, index) => (
            <View
              key={index}
              style={[
                styles.messageBubble,
                msg.role === 'user' ? styles.userMessage : styles.modelMessage,
              ]}
            >
              <Text style={msg.role === 'user' ? styles.userText : styles.modelText}>
                {msg.text}
              </Text>
            </View>
          ))}
          {loading && (
            <View style={[styles.messageBubble, styles.modelMessage]}>
              <ActivityIndicator size="small" color="#F37307" />
            </View>
          )}
        </ScrollView>

        {/* Input Area */}
        <View style={styles.inputContainer}>
          <TextInput
            style={styles.input}
            placeholder="Ask a fitness question..."
            placeholderTextColor="#999"
            value={input}
            onChangeText={setInput}
            multiline
          />
          <TouchableOpacity
            style={[styles.sendButton, loading && styles.sendButtonDisabled]}
            onPress={handleSend}
            disabled={loading}
          >
            <FontAwesome5 name="paper-plane" size={20} color="#fff" solid />
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  flex: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: (StatusBar.currentHeight || 0) + 10,
    paddingBottom: 15,
    paddingHorizontal: 15,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  backButton: {
    padding: 10,
  },
  logoContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  logo: {
    width: 30,
    height: 30,
    marginRight: 8,
  },
  appName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#F37307',
  },
  chatContainer: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  chatContent: {
    padding: 15,
  },
  messageBubble: {
    padding: 15,
    borderRadius: 20,
    marginBottom: 10,
    maxWidth: '80%',
  },
  userMessage: {
    backgroundColor: '#F37307',
    alignSelf: 'flex-end',
    borderBottomRightRadius: 5,
  },
  modelMessage: {
    backgroundColor: '#e9e9eb',
    alignSelf: 'flex-start',
    borderBottomLeftRadius: 5,
  },
  userText: {
    color: '#fff',
    fontSize: 16,
  },
  modelText: {
    color: '#000',
    fontSize: 16,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 10,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  input: {
    flex: 1,
    backgroundColor: '#f8f9fa',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 25,
    padding: 15,
    paddingTop: 15, // for multiline
    fontSize: 16,
    marginRight: 10,
    maxHeight: 120, // Limit height of input box
  },
  sendButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#F37307',
    justifyContent: 'center',
    alignItems: 'center',
  },
  sendButtonDisabled: {
    backgroundColor: '#fda769',
  },
});

export default AIChatScreen;

