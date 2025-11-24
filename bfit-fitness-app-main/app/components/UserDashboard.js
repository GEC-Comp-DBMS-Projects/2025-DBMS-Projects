import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { FontAwesome5 } from '@expo/vector-icons';

const UserDashboard = ({ userData }) => {
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.welcomeText}>Welcome back,</Text>
        <Text style={styles.userName}>{userData.fullName}!</Text>
      </View>
      <View style={styles.card}>
        <FontAwesome5 name="check-circle" size={24} color="green" />
        <View style={styles.cardContent}>
          <Text style={styles.cardTitle}>Your Plan is Active!</Text>
          <Text style={styles.cardText}>Let's get started on your journey.</Text>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    paddingTop: 40,
  },
  header: {
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  welcomeText: {
    fontSize: 22,
    color: '#555',
  },
  userName: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#212121',
  },
  card: {
    backgroundColor: '#f9f9f9',
    borderRadius: 15,
    padding: 20,
    marginHorizontal: 20,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#eee',
  },
  cardContent: {
      marginLeft: 15,
  },
  cardTitle: {
      fontSize: 16,
      fontWeight: 'bold',
      color: '#333',
  },
  cardText: {
      fontSize: 14,
      color: '#666',
      marginTop: 5,
  }
});

export default UserDashboard;
