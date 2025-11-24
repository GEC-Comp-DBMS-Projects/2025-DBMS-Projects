import * as React from 'react';
import { View, Text, Image } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useEffect, useState } from 'react';
import { GestureHandlerRootView } from 'react-native-gesture-handler';

import HiddenPlaces from "./screens/HiddenPlaces"
import SmartItinerary from "./screens/SmartItinerary"
import SuggestionsScreen from "./screens/SuggestionsScreen"
import CrowdAnalysis from "./screens/CrowdAnalysis"
import UserLogin from "./screens/UserLogin"
import StoreOwner from "./screens/StoreOwner"
import StoresGallery from "./screens/StoresGallery"
import StoreDetail from "./screens/StoreDetail"
import PriceGuide from "./screens/PriceGuide"
import Profile from "./screens/Profile"
import SocialFeed from "./screens/SocialFeed"

// Firebase and authentication
import { auth } from './firebase';
import { onAuthStateChanged } from 'firebase/auth';

// Import your screens
import HomeScreen from './screens/HomeScreen';
import SignUpScreen from './screens/SignUpScreen';
import SignInScreen from './screens/SignInScreen';

import DetailScreen from './screens/PlaceDetails';
import PreferenceScreen from './screens/PreferenceScreen';

const Stack = createNativeStackNavigator();

function App() {
  const [user, setUser] = useState<any>(null);
  const [initializing, setInitializing] = useState(true);

  useEffect(() => {
    console.log('App.js mounted');
    

    const unsubscribe = onAuthStateChanged(auth, (user) => {
      console.log('User:', user);
      setUser(user);
      if (initializing) {
        console.log('User:', user?.email);
        setInitializing(false);
      }
      console.log('User:', user?.email);
    });

    return unsubscribe;
  }, [initializing]);

  if (initializing) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <Image
          source={require('./assets/splash.png')}
          style={{ width: 340, height: 340, opacity: 1 }}
        />
      </View>
    ); // or a loading component
  }

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <NavigationContainer>
        {user ? (
          <Stack.Navigator
            initialRouteName="Home"
            screenOptions={{
              headerShown: false,
            }}>
          
            <Stack.Screen name="detail" component={DetailScreen} />  
          <Stack.Screen name = "Hidden" component={HiddenPlaces} />
          <Stack.Screen name="itinerary" component={SmartItinerary} />
          <Stack.Screen name="suggestions" component={SuggestionsScreen} />
          <Stack.Screen name="crowd" component={CrowdAnalysis} />
            <Stack.Screen name="Home" component={HomeScreen} />
           <Stack.Screen name="preference" component={PreferenceScreen} />
            <Stack.Screen name="SignIn" component={SignInScreen} />
            <Stack.Screen name="SignUp" component={SignUpScreen} />
            <Stack.Screen name="userLogin" component={UserLogin} />
            <Stack.Screen name="StoreOwner" component={StoreOwner} />
            <Stack.Screen name="stores" component={StoresGallery} />
            <Stack.Screen name="storeDetail" component={StoreDetail} />
            <Stack.Screen name="priceGuide" component={PriceGuide} />
            <Stack.Screen name="Profile" component={Profile} />
            <Stack.Screen name="social" component={SocialFeed} />
          
          </Stack.Navigator>
        ) : (
          <Stack.Navigator
            initialRouteName="userLogin"
            screenOptions={{
              headerShown: false,
            }}>
            <Stack.Screen name="SignIn" component={SignInScreen} />
            <Stack.Screen name="SignUp" component={SignUpScreen} />
            <Stack.Screen name="Home" component={HomeScreen} />
            <Stack.Screen name="preference" component={PreferenceScreen} />
            <Stack.Screen name="detail" component={DetailScreen} />
            <Stack.Screen name="Hidden" component={HiddenPlaces} />
            <Stack.Screen name="itinerary" component={SmartItinerary} />
            <Stack.Screen name="suggestions" component={SuggestionsScreen} />
            <Stack.Screen name="crowd" component={CrowdAnalysis} />
            <Stack.Screen name="userLogin" component={UserLogin} />
            <Stack.Screen name="StoreOwner" component={StoreOwner} />
            <Stack.Screen name="stores" component={StoresGallery} />
            <Stack.Screen name="storeDetail" component={StoreDetail} />
            <Stack.Screen name="priceGuide" component={PriceGuide} />
            <Stack.Screen name="Profile" component={Profile} />
            <Stack.Screen name="social" component={SocialFeed} />
            {/* <Stack.Screen name="ActivityScreen" component={ActivityScreen} /> */}
          </Stack.Navigator>
        )}
      </NavigationContainer>
    </GestureHandlerRootView>
  );
}

export default App;
