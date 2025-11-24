import React, { useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons'; // Importing icon set
import { auth } from '../firebase';
import { useNavigation } from '@react-navigation/core';
import { signOut } from 'firebase/auth';
import { fetchDoc } from '../utils/getUser';
import Menu from '../screens/Menu';


const Navbar = () => {

  const navigation = useNavigation();



  const signout = () => {
    console.log('Sign Out');
    signOut(auth).then(() => {
      navigation.navigate('SignIn' as never);

    }
    ).catch((error:any) => {
      console.log(error.message);
    });
  };



  return (
    <View style={styles.container}>

      <View style={styles.Navbar}>
        <TouchableOpacity style={styles.navButton} onPress={()=>navigation.navigate('Home' as never)}>
          <Icon name="home" size={30} color="#FFFFFF" />
          <Text style={styles.navText}>Home</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navButton} onPress={()=>{navigation.navigate("Social" as never)}}>
          <Icon name="search" size={30} color="#FFFFFF" />
          <Text style={styles.navText}>Search</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navButton} onPress={()=>navigation.navigate('Matching' as never)}>
          <Icon name="camera" size={30} color="#FFFFFF" />
          <Text style={styles.navText}>Camera</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navButton} onPress={()=>navigation.navigate('Maps' as never)}>
          <Icon name="map" size={30} color="#FFFFFF" />
          <Text style={styles.navText}>Maps</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navButton} onPress={()=>navigation.navigate('Menu' as never)}>
          <Icon name="menu" size={30} color="#FFFFFF" />
          <Text style={styles.navText}>Menu</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'flex-end',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  mainText: {
    fontSize: 24,
  },
  Navbar: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: 60,
    flexDirection: 'row',
    backgroundColor: '#000000',
    justifyContent: 'space-around',
    alignItems: 'center',
  },
  navButton: {
    flex: 1,
    alignItems: 'center',
  },
  navText: {
    color: '#FFFFFF',
    fontSize: 12,
    marginTop: 4,
  },
});

export default Navbar;
