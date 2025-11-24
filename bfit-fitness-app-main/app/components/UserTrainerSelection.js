import React from 'react';
import { StyleSheet, Text, View, StatusBar, FlatList, TouchableOpacity, Image } from 'react-native';
import { FontAwesome5 } from '@expo/vector-icons';

// This component receives userData, trainers, and the onSelectTrainer function as props
const UserTrainerSelection = ({ userData, trainers, onSelectTrainer }) => {
  return (
    <View style={styles.container}>
      <View style={styles.header}>
         <Image source={require('../../assets/images/logo.png')} style={styles.logo} />
         <View>
            <Text style={styles.welcomeText}>Hi {userData.fullName.split(' ')[0]},</Text>
            <Text style={styles.subHeaderText}>Ready for your Fitness journey?</Text>
         </View>
      </View>
      <Text style={styles.selectTitle}>Before we begin, please select a Trainer for you.</Text>
      <FlatList
        data={trainers}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <TouchableOpacity style={styles.trainerCard} onPress={() => onSelectTrainer(item.id)}>
            <FontAwesome5 name="user-tie" size={40} color="#F37307" />
            <View style={styles.trainerInfo}>
              <Text style={styles.trainerName}>{item.fullName}</Text>
              <Text style={styles.trainerQuals}>{item.qualifications}</Text>
            </View>
            <FontAwesome5 name="chevron-right" size={20} color="#ccc" />
          </TouchableOpacity>
        )}
        ListEmptyComponent={<Text style={styles.noTrainersText}>No trainers available at the moment.</Text>}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    paddingTop: StatusBar.currentHeight || 40,
  },
  header: {
    paddingHorizontal: 20,
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  logo: {
      width: 50,
      height: 50,
      marginRight: 15,
  },
  welcomeText: {
    fontSize: 22,
    color: '#555',
  },
  subHeaderText: {
      fontSize: 16,
      color: '#666',
  },
  selectTitle: {
    fontSize: 18,
    color: '#333',
    fontWeight: '600',
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  trainerCard: {
    backgroundColor: '#f9f9f9',
    borderRadius: 15,
    padding: 20,
    marginHorizontal: 20,
    marginBottom: 15,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#eee',
  },
  trainerInfo: {
    flex: 1,
    marginLeft: 15,
  },
  trainerName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  trainerQuals: {
    fontSize: 14,
    color: '#777',
    marginTop: 4,
  },
  noTrainersText: {
      textAlign: 'center',
      marginTop: 30,
      color: '#888'
  },
});


export default UserTrainerSelection;
