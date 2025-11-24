import { View, Image, TouchableOpacity, StyleSheet, Animated, Text, Modal, Button, ImageBackground, Linking } from 'react-native';
import React, { useState, useRef } from 'react';
import { query } from 'firebase/firestore';

const MysteryLetter = ({quest}:any) => {
  const [isLetterOpen, setIsLetterOpen] = useState(false); // State to track if the letter is open
  const [isModalVisible, setIsModalVisible] = useState(false); // State to manage the modal visibility
  const scaleValue = useRef(new Animated.Value(1)).current; // Start the scale at 1 (no scaling)

  
const openInMaps = (lat : number, lon : number) => {
  const url = `https://www.google.com/maps/search/?api=1&query=${lat},${lon}`;
  Linking.openURL(url).catch(err => console.error("Failed to open Google Maps:", err));
};

  const handlePress = () => {
    if (!isLetterOpen) {
      // Show pop-up and open the letter only when the closed letter is clicked
      setIsLetterOpen(true);
      setIsModalVisible(true);

      // Animate the scale with a "pop" effect
      Animated.spring(scaleValue, {
        toValue: 1.1, // Slightly larger size for pop effect
        friction: 5, // Control the bounciness
        useNativeDriver: true,
      }).start(() => {
        // Reset the scale back to normal after the pop
        Animated.spring(scaleValue, {
          toValue: 1,
          useNativeDriver: true,
        }).start();
      });
    } else {
      // Close the letter when the open letter is clicked
      setIsLetterOpen(false);
    }
  };

  const closeModal = () => {
    setIsModalVisible(false); // Close the pop-up when the button is clicked
  };

  return (
    <View style={styles.card}>
      <TouchableOpacity onPress={handlePress}>
        <Animated.View
          style={[
            styles.animatedContainer,
            {
              transform: [
                {
                  scale: scaleValue, // Apply the scale animation to the container
                },
              ],
            },
          ]}
        >
          <Image
            source={
              !isLetterOpen
                ? require('../assets/letterclosed.png') // Show closed letter
                : require('../assets/letteropen.png')   // Show open letter
            }
            style={styles.image} // Use same styling for both images
          />
        </Animated.View>
      </TouchableOpacity>

      {/* Modal for the pop-up (only for closed letter click) */}
      <Modal
        visible={isModalVisible}
        transparent={true}
        animationType="slide"
      >
        <View style={styles.modalContainer}>
          <ImageBackground
            source={require('../assets/paperImg.png')} // Set the paperImg image as background
            style={styles.imageBackground}
            resizeMode="contain" // Ensure the image fits properly
          >
            <Text style={[styles.modalText, {fontSize:25, fontWeight: '600'}]}>{quest?.quest}</Text>
            <Text style={styles.modalText}>{quest?.description}</Text>
            <View style={{display: "flex", flexDirection: 'row', justifyContent:'center', gap:10, width: "80%", flexWrap: 'wrap'}}>
             
            {
              quest.activities.map((activity:any, index:number) => {
                return (
                  <Text key={index} style={{backgroundColor: '#000000', color:'white', padding: 7, borderRadius: 8}}>
                    {activity},
                  </Text>
                );
              })
            }
            </View>
            <View style={{display:'flex', marginTop: 30, flexDirection:"row", alignItems:'center', justifyContent:'space-between', width:"100%", paddingHorizontal:30 }}>

            <TouchableOpacity
  style={{
    backgroundColor: '#2563EB', // Tailwind class 'bg-blue-600'
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 8, // Rounded corners
    width: 80, // Tailwind 'w-20'
    height: 32, // Tailwind 'h-8'
  }}
  onPress={() => openInMaps(quest.coordinates?.latitude, quest.coordinates?.longitude)}
>
  <Text style={{ color: '#FFFFFF' }}>Navigate</Text>
</TouchableOpacity>

<TouchableOpacity
  style={{
    marginTop: 16,
    justifyContent:'center' ,
    alignItems: 'center'// Tailwind 'mt-4'
  }}
  onPress={closeModal}
>
  <Text style={{ color: '#3B82F6', fontWeight: '600' }}>Close</Text>
</TouchableOpacity>


         
            </View>
          </ImageBackground>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    padding: 20,
    borderRadius: 10,
    backgroundColor: 'rgb(0,0,0,0.0)',
    
    alignItems: 'center',
    justifyContent: 'center',
    
    top: -15,
    left:0,
  },
  image: {
    height: 202, // Fixed height for both images
    width: 282,  // Fixed width for both images
    borderRadius: 30,
    top:10,
    left:-10,
  },
  animatedContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    width: 50, // Fixed width to prevent white box during transition
    height: 182, // Fixed height to prevent white box during transition
    left:4,
  },
  modalContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.5)', // Dim background
  },
  imageBackground: {
    width: 360,
    height: 500, // Adjust the size according to your paperImg image
    padding: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalText: {
    width: '80%',
    fontSize: 16,
    marginBottom: 20,
    color: '#000', // Text color for contrast with the paperImg background
  },
});

export default MysteryLetter;
