import React from 'react';
import { View, Text, StyleSheet,TouchableOpacity } from 'react-native';
import { Linking } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useState } from 'react';
import { Alert } from 'react-native';
import { ImageBackground } from 'react-native';


interface SpinCardProps {
  winner: string;
  lat: number;
  lon: number;
  userlat:number;
  userlon:number;
}

import NetInfo from '@react-native-community/netinfo';
import { useEffect } from 'react';
import { updateUserWheel } from '../utils/updateUser';



const SpinCard: React.FC<SpinCardProps> = ({ winner, lat, lon,userlat,userlon,navigation }:any) => {
const [points, setPoints] = useState<number>(0)
const [noInternet, setNoInternet] = useState<boolean>(false);

useEffect(() => {
  const unsubscribe = NetInfo.addEventListener(state => {
    setNoInternet(!state.isConnected);
  });

  // Check initial connection status
  NetInfo.fetch().then(state => {
    setNoInternet(!state.isConnected);
  });

  return () => {
    unsubscribe();
  };
}, []);

const setcoords=async() => {
  await AsyncStorage.setItem('coords', JSON.stringify({lat:lat,lon:lon}));
}
if(lat!=90 && lon!=90){
  setcoords();
}

const openInMaps = (lat : number, lon : number) => {
  const url = `https://www.google.com/maps/search/?api=1&query=${lat},${lon}`;
  Linking.openURL(url).catch(err => console.error("Failed to open Google Maps:", err));
};
console.log("Chinmay:"+userlat,userlon);

const updateAsync = async(points:any)=>{
  console.log("Updating async...")


  try {
      const jsonValue = await AsyncStorage.getItem('user');
      let data = jsonValue != null ? JSON.parse(jsonValue) : {};
      
      // Update a specific field, for example, 'name'
      data.points = data.points+ 500;
     
      
  
      // Save the updated data

      await AsyncStorage.setItem('user', JSON.stringify(data));
      console.log()
    } catch (error) {
      console.error('Error updating field:', error);
    }

}



const refusedChallenge = async () => {
  Alert.alert(
    "Confirm Refusal",
    "Are you sure you want to refuse the challenge?",
    [
      {
        text: "Cancel",
        onPress: () => console.log("Challenge refusal cancelled"),
        style: "cancel",
      },
      {
        text: "OK",
        onPress: async () => {
          console.log("Refused challenge");
          try {
            // await updateUserWheel(-70);
            // Alert.alert("Challenge Refused", "You have lost 70 points.");
            await AsyncStorage.setItem('isSpinActive', "false");
            await AsyncStorage.setItem('winner', JSON.stringify(''));
            navigation.goBack();
          } catch (error) {
            console.error('Error updating field:', error);
          }
        },
      },
    ]
  );
};





const increaseUserPoints = async () => {
  try {
    if(!noInternet){  // Always update async storage first
     await updateUserWheel(500); // Then update
    }else{
      await updateAsync(500)
      console.log("No internet connection, updating async storage only");
    }
    console.log()
  } catch (error) {
    console.error('Error updating field:', error);
  }

};

const checkDist = async () => {
  var R = 6371; // Radius of the earth in km

  if(lat==90 && lon==90){
    let coords = await AsyncStorage.getItem('coords');
    let parsedCoords = JSON.parse(coords!);
    lat = parsedCoords.lat;
    lon = parsedCoords.lon;
  }
  var dLat = (lat - userlat) * Math.PI / 180;  // deg2rad below
  var dLon = (lon - userlon) * Math.PI / 180;
  var a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(userlat * Math.PI / 180) * Math.cos(lat * Math.PI / 180) * 
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
  console.log(a);
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)); 
  var d = R * c; // Distance in km

  console.log("User lat lon"+userlat+" "+userlon);
  console.log("Place lat lon"+lat+" "+lon);
  
  //! For testing
  //  let d=0.4;
  console.log(d);

  
  if (d < 0.5) {
    alert("You are within 0.5 km! 500 points awarded.");
    increaseUserPoints();
      
  } else {
    alert("You are in " + d.toFixed(2) + " km radius from the destination.( get within 0.5 km to get 500 points)");
  }
  return d;
};


  return (
    <View style={styles.card}>
      <View style={{
        display: 'flex',
        flexDirection: 'row',
        justifyContent: 'center',
      }}>
      <Text style={styles.title}>Selected : </Text>
      <Text
        style={styles.title}  
      >{winner}</Text>
      </View>
      
      <View style={
        {
          display: 'flex',
          flexDirection: 'row',
          justifyContent: 'space-between',
          marginTop: 10,
        }
      }>

      <TouchableOpacity style={{
        backgroundColor: 'red',
        padding: 10,
        borderRadius: 10,
      }}
      onPress={()=>refusedChallenge()} 
      >
        <Text style={{
          color: 'white',
          fontWeight: 'bold',
        }}>Reject</Text>
      </TouchableOpacity>
      <TouchableOpacity style={{
        backgroundColor: 'blue',
        padding: 10,
        borderRadius: 10,
      }} onPress={()=>openInMaps(lat,lon)}>
        <Text style={{
          color: 'white',
          fontWeight: 'bold',
        }}>Start</Text>
      </TouchableOpacity>
      </View>
      <View style={{
        display: 'flex',
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        marginTop: 10,
      }}>

      <TouchableOpacity style={{
        backgroundColor: 'green',
        padding: 10,
        borderRadius: 10,
        width: 200,
      }} onPress={()=>checkDist()}>
        <Text style={{
          color: 'white',
          fontWeight: 'bold',
          textAlign: 'center',
        }}>Check progress</Text>
      </TouchableOpacity>
        </View>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#fff',
    padding: 20,
    margin: 10,
    borderRadius: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.8,
    shadowRadius: 2,
    elevation: 5,
    minWidth: 300,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  coordinates: {
    fontSize: 16,
    marginTop: 5,
  },
});

export default SpinCard;