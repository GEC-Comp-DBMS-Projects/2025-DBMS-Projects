import {
  View,
  Text,
  ImageBackground,
  TextInput,
  TouchableOpacity,
  Image,
  KeyboardAvoidingView,
  Platform,
  ScrollView
} from 'react-native';
import React, { useEffect, useState } from 'react';
import { SafeAreaView } from 'react-native-safe-area-context';
import { signInWithEmailAndPassword, onAuthStateChanged, signOut } from "firebase/auth";

import {auth, db} from '../firebase';
import { addDoc, collection } from 'firebase/firestore';

const SignInScreen = ({navigation}:any) => {


  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');




  const signIn = () => {
    console.log('Sign Up:', {  email, password });

    signInWithEmailAndPassword(auth,email, password)
    .then((userCredential:any) => {
      // Signed in
      const user = userCredential.user;
      console.log(user.email);
      if(user?.email){
        navigation.replace('Home');
      }

    }).catch((error:any) => {
      const errorCode = error.code;
      const errorMessage = error.message;
      console.log(errorMessage);
      alert(errorMessage);
    })
  };

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <ImageBackground
        source={require('../assets/mountainBack.jpg')}
        style={{ flex: 1 }}
      >
        <KeyboardAvoidingView
          // behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={{ flex: 1 }}
        >
          <ScrollView
            contentContainerStyle={{ flexGrow: 1, justifyContent: 'flex-end' }}
          >
            <View className="bg-[#040D19] h-[80%] w-full flex flex-col items-center rounded-t-3xl">
              <Image
                source={require('../assets/manStars.png')}
                className="w-40 h-40 mt-10 scale-x-[-1]"
              />
              <View className="w-full items-center px-5 py-10">
                <Text className="text-white text-2xl mb-1 font-medium">
                  Log in to your account
                </Text>
                <Text className="text-gray-600 text-lg font-light">
                  Please sign in to continue
                </Text>

            
                <TextInput
                  placeholder="Email"
                  placeholderTextColor={'#A0A0A0'}
                  value={email}
                  onChangeText={setEmail}
                  keyboardType="email-address"
                  className="bg-[#1B203D] text-white w-full px-3 py-3 mt-5 rounded-lg"
                />

                <TextInput
                  placeholder="Password"
                  placeholderTextColor={'#A0A0A0'}
                  value={password}
                  onChangeText={setPassword}
                  secureTextEntry
                  className="bg-[#1B203D] text-white w-full px-3 py-3 mt-5 rounded-lg"
                />

                <TouchableOpacity
                  className="px-12 py-2 mt-5 rounded-xl bg-orange-600 items-center"
                  onPress={signIn}
                >
                  <Text className="text-white text-lg">Sign In</Text>
                </TouchableOpacity>

                <Text className="text-gray-500 text-md mt-12">
                  Dont have an Account?
                  <Text className="text-orange-600" onPress={()=>navigation.navigate('SignUp')} > Sign Up</Text>
                </Text>
              </View>
            </View>
          </ScrollView>
        </KeyboardAvoidingView>
      </ImageBackground>
    </SafeAreaView>
  );
};

export default SignInScreen;