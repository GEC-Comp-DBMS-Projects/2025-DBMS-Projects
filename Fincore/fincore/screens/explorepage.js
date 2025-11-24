import React, { useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Alert,
  StatusBar,
  BackHandler,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { API_ENDPOINTS } from '../apiConfig';

const ExplorePage = ({ navigation }) => {

  useEffect(() => {
    const backAction = () => {
      Alert.alert(
        'Exit App',
        'Are you sure you want to exit?',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Exit', onPress: () => BackHandler.exitApp() },
        ],
        { cancelable: false }
      );
      return true;
    };

    const backHandler = BackHandler.addEventListener('hardwareBackPress', backAction);
    return () => backHandler.remove();
  }, []);

  const exploreCards = [
    {
      id: 1,
      title: 'Dashboard',
      description: 'Track your financial health at a glance',
      icon: '📊',
      screen: 'Dashboard',
      bgColor: '#2d3748',
    },
    {
      id: 2,
      title: 'Stocks',
      description: 'Manage your investments and portfolio',
      icon: '📈',
      screen: 'Stocks',
      bgColor: '#2d3748',
    },
    {
      id: 3,
      title: 'Advisor Connect',
      description: 'Get personalized financial advice',
      icon: '👥',
      screen: 'Advisor',
      bgColor: '#2d3748',
    },
    {
      id: 4,
      title: 'Tax Center',
      description: 'Simplify your tax filing process',
      icon: '📄',
      screen: 'TaxCenter',
      bgColor: '#2d3748',
    },
  ];

  const handleCardPress = (screen) => {
    if (screen === 'Dashboard') {
      checkConsentAndNavigate();
    } else if (screen === 'Stocks') {
      navigation.navigate('LoginScreen');
    } else if (screen === 'TaxCenter') {

      navigation.navigate('Welcome', { autoNext: true });
    } else {
      navigation.navigate(screen);
    }
  };

  const checkConsentAndNavigate = async () => {
    try {
      const userEmail = await AsyncStorage.getItem('userEmail');
      if (!userEmail) {
        Alert.alert('Error', 'Please login again');
        navigation.navigate('Login');
        return;
      }

      const response = await fetch(API_ENDPOINTS.CHECK_USER_CONSENT, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: userEmail }),
      });

      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

      const data = await response.json();
      if (data.hasConsent && data.status === 'ACTIVE') {
        navigation.navigate('Dashboard');
      } else {
        navigation.navigate('Consent');
      }
    } catch (error) {
      console.error('Error checking consent:', error);
      Alert.alert(
        'Connection Error',
        'Unable to connect to server. Please check your internet connection and try again.',
        [
          { text: 'Retry', onPress: () => checkConsentAndNavigate() },
          { text: 'Go to Consent', onPress: () => navigation.navigate('Consent') },
        ]
      );
    }
  };

  return (
    <View style={styles.outerContainer}>
      <StatusBar barStyle="light-content" backgroundColor="#1a1f2e" translucent={false} />
      <SafeAreaView style={styles.container}>
        {}
        <View style={styles.header}>
          <View style={styles.headerCenter}>
            <Text style={styles.headerTitle}>Fincore</Text>
          </View>
          <TouchableOpacity style={styles.settingsButton}>
            <Text style={styles.settingsIcon}>⚙️</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.content}>
          <Text style={styles.pageTitle}>Explore</Text>

          {}
          <View style={styles.cardsContainer}>
            {exploreCards.map((card) => (
              <TouchableOpacity
                key={card.id}
                style={styles.card}
                onPress={() => handleCardPress(card.screen)}
                activeOpacity={0.7}
              >
                <View style={styles.cardContent}>
                  <View style={styles.cardText}>
                    <Text style={styles.cardTitle}>{card.title}</Text>
                    <Text style={styles.cardDescription}>{card.description}</Text>
                    <View style={styles.goButton}>
                      <Text style={styles.goButtonText}>Go</Text>
                    </View>
                  </View>
                  <View style={[styles.cardImage, { backgroundColor: card.bgColor }]}>
                    <Text style={styles.cardIcon}>{card.icon}</Text>
                  </View>
                </View>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      </SafeAreaView>

      {}
      <View style={styles.fabContainer}>
        <TouchableOpacity
          style={styles.fab}
          activeOpacity={0.8}
          onPress={() =>
            Alert.alert('Voice Assistant', 'Voice assistant feature coming soon!')
          }
        >
          <View style={styles.voiceWaveform}>
            <View style={[styles.wavBar, { height: 12 }]} />
            <View style={[styles.wavBar, { height: 20 }]} />
            <View style={[styles.wavBar, { height: 16 }]} />
            <View style={[styles.wavBar, { height: 24 }]} />
            <View style={[styles.wavBar, { height: 18 }]} />
            <View style={[styles.wavBar, { height: 14 }]} />
          </View>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  outerContainer: {
    flex: 1,
    backgroundColor: '#1a1f2e',
  },
  container: {
    flex: 1,
    backgroundColor: '#1a1f2e',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 8,
    paddingBottom: 12,
    position: 'relative',
  },
  headerCenter: {
    flex: 1,
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#ffffff',
  },
  settingsButton: {
    position: 'absolute',
    right: 20,
    width: 32,
    height: 32,
    justifyContent: 'center',
    alignItems: 'center',
  },
  settingsIcon: {
    fontSize: 18,
  },
  content: {
    flex: 1,
    paddingTop: 16,
  },
  pageTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#ffffff',
    paddingHorizontal: 20,
    marginBottom: 16,
  },
  cardsContainer: {
    flex: 1,
    paddingHorizontal: 20,
    paddingBottom: 16,
  },
  card: {
    backgroundColor: '#273142',
    borderRadius: 12,
    marginBottom: 10,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#374151',
  },
  cardContent: {
    flexDirection: 'row',
    padding: 14,
    alignItems: 'center',
  },
  cardText: {
    flex: 1,
    paddingRight: 12,
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#ffffff',
    marginBottom: 4,
  },
  cardDescription: {
    fontSize: 12,
    color: '#9ca3af',
    lineHeight: 16,
    marginBottom: 8,
  },
  goButton: {
    alignSelf: 'flex-start',
    backgroundColor: '#00d4d4',
    paddingHorizontal: 16,
    paddingVertical: 6,
    borderRadius: 5,
  },
  goButtonText: {
    color: '#1a1f2e',
    fontSize: 12,
    fontWeight: '600',
  },
  cardImage: {
    width: 60,
    height: 60,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
  },
  cardIcon: {
    fontSize: 30,
  },
  fabContainer: {
    backgroundColor: '#1a1f2e',
    paddingVertical: 20,
    paddingBottom: 24,
    alignItems: 'center',
  },
  fab: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#00d4d4',
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 8,
  },
  voiceWaveform: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 3,
  },
  wavBar: {
    width: 3,
    backgroundColor: '#1a1f2e',
    borderRadius: 2,
  },
});

export default ExplorePage;