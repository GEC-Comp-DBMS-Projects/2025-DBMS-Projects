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
  import React, { useId, useState } from 'react';
  import { SafeAreaView } from 'react-native-safe-area-context';
  import {auth, db} from '../firebase';
  import { signInWithEmailAndPassword, onAuthStateChanged, signOut, createUserWithEmailAndPassword } from "firebase/auth";
import { addDoc, collection } from 'firebase/firestore';
  
  const SignUpScreen = ({navigation}:any) => {
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    const getData = async () => {
      try {
        const docRef = await addDoc(collection(db, "users"), {
          uid: auth.currentUser?.uid,
          name: name,
          email: auth.currentUser?.email,
        
        });
        console.log("Document written with ID: ", docRef.id);

        
      } catch (e) {
        console.error("Error adding document: ", e);
      }
    }
    

    const signUp = () => {
       console.log('Sign Up:', { name, email, password });

       if(email === '' || password === '' || name === ''){
        alert('Please fill all the fields');
        return;
       }

    createUserWithEmailAndPassword(auth,email, password)
      .then((userCredential:any) => {
        // Signed in
        var user = userCredential.user;

        if(user){
          getData()
          navigation.navigate('preference');
        }
        console.log(user);
      }).catch((error:any) => {
        var errorCode = error.code;
        var errorMessage = error.nativeErrorMessage;
        alert(error.message);
        console.log(error.message);

      });
    };
  
    return (
      <SafeAreaView style={{ flex: 1 }}>
        <ImageBackground
          source={require('../assets/mountainBack.jpg')}
          style={{ flex: 1 }}
        >
          <KeyboardAvoidingView
          
           
            style={{ flex: 1 }}
          >
            <ScrollView
             horizontal={false}
              contentContainerStyle={{ flexGrow: 1, justifyContent: 'flex-end' }}
            >
              <View className="bg-[#040D19] h-[80%] w-full flex flex-col items-center rounded-t-3xl">
                <Image
                  source={require('../assets/manStars.png')}
                  className="w-32 h-32 mt-10"
                />
                <View className="w-full   items-center px-5 py-5">
                  <Text className="text-white text-2xl mb-1 font-medium">
                    Create An Account
                  </Text>
                  <Text className="text-gray-600 text-lg font-light">
                    Please fill all the fields to continue
                  </Text>
  
                  <TextInput
                    placeholder="Name"
                    placeholderTextColor={'#A0A0A0'}
                    value={name}
                    onChangeText={setName}
                    className="bg-[#1B203D] text-white w-full px-3 py-3 mt-5 rounded-lg"
                  />
  
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
                    onPress={signUp}
                  >
                    <Text className="text-white text-lg">Sign Up</Text>
                  </TouchableOpacity>
  
                  <Text className="text-gray-500 text-md mt-5">
                    Already have an account?
                    <Text className="text-orange-600" onPress={()=>navigation.navigate('SignIn')}> Sign In</Text>
                  </Text>
                </View>
              </View>
            </ScrollView>
          </KeyboardAvoidingView>
        </ImageBackground>
      </SafeAreaView>
    );
  };
  
  export default SignUpScreen;
