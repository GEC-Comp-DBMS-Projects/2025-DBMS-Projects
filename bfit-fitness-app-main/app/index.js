import React from 'react';
import { StyleSheet, Text, View, TouchableOpacity, StatusBar, Image } from 'react-native';
import { LinearGradient as ExpoLinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';

const WelcomeScreen = () => {
  const router = useRouter();

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" />
      
      {/* This view is now larger and rotated to create the sharp diagonal line */}
      <View style={styles.backgroundShape} />

      <View style={styles.contentContainer}>
        <View style={styles.logoContainer}>
            {/* 1. Added a new Text component for the B-FIT title */}
            <Text style={styles.bfitText}>B-FIT</Text>
            {/* For this to match the Figma, your 'logo.png' should include the 'B-FIT' text */}
            <Image 
              source={require('../assets/images/logo.png')} 
              style={styles.logo} 
            />
        </View>

        {/* The two welcome text lines are now combined for better styling */}
        <Text style={styles.title}>
            Welcome to B FIT{'\n'}The Ultimate FITNESS APP
        </Text>

        <TouchableOpacity 
            style={styles.loginButtonWrapper} 
            onPress={() => router.push('/login')} 
        >
            <ExpoLinearGradient
                colors={['#FFD200', '#F37307']}
                style={styles.loginButton}
                start={{ x: 0, y: 0.5 }}
                end={{ x: 1, y: 0.5 }}
            >
                <Text style={styles.loginButtonText}>LOGIN</Text>
            </ExpoLinearGradient>
        </TouchableOpacity>
        
        <Text style={styles.loginHelper}>Click here to Login</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    // A lighter, cleaner background color
    backgroundColor: '#FFFFFF',
  },
  backgroundShape: {
    position: 'absolute',
    width: '150%', // Wider than screen to ensure full diagonal coverage
    height: '60%', // Covers the top portion
    left: '-25%', // Repositioned for the angle
    top: '-15%', // Repositioned for the angle
    backgroundColor: '#F37307',
    // Rotated to create the diagonal effect from the Figma design
    transform: [{ rotate: '-15deg' }],
  },
  contentContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  logoContainer: {
    alignItems: 'center',
    // Adjusted spacing to match Figma
    marginBottom: 50,
  },
    // 2. Added new styles for the rich, bold B-FIT text
  bfitText: {
    fontSize: 50,
    fontWeight: 'bold',
    color: '#f3c007ff',
    letterSpacing: 3,
    marginBottom: 2, // Creates space between the text and the logo image
    textShadowColor: 'rgba(0, 0, 0, 0.1)',
    textShadowOffset: { width: 0, height: 4 },
    textShadowRadius: 5,
  },
  logo: {
    width: 170, // Slightly larger logo
    height: 170,
    resizeMode: 'contain',
  },
  title: {
    fontSize: 22, // Matched font size
    fontWeight: 'bold', // Bolder text
    color: '#212121', // Darker text for better contrast
    textAlign: 'center', // Centered text
    marginBottom: 80, // Increased space between text and button
  },
  loginButtonWrapper: {
    width: '80%',
    borderRadius: 50,
    // More subtle shadow to match the design
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 5 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 10, // For Android shadow
  },
  loginButton: {
    paddingVertical: 18, // Slightly taller button
    borderRadius: 50,
    alignItems: 'center',
  },
  loginButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold', // Bolder button text
    letterSpacing: 1.5, // Wider letter spacing
  },
  loginHelper: {
    marginTop: 20, // Increased spacing
    color: '#555',
    fontSize: 16,
  },
});

export default WelcomeScreen;

