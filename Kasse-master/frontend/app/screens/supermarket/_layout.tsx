import { Stack,useSegments,router,useRootNavigationState,Redirect } from 'expo-router';
import {User} from "firebase/auth"
import { AdminContextProvider,useAdminContext } from './context/adminContext';
import { useEffect, useState } from 'react';
function InitialLayout(){

 const {authAdmin,loading,AdminProfileData}:{authAdmin:User|null,loading:boolean,AdminProfileData:any} = useAdminContext();
 const segments = useSegments(); // Get the current URL segments

//  const isInTabsGroup= (segments[2]=="(tabs)" ) || (segments[2]=="register");
//  console.log(isInTabsGroup);
//  const rootNavigationState = useRootNavigationState();

//   console.log(segments[2],authAdmin);


//  useEffect(() => {
//    if(loading) return;

//    console.log("hello");
 
//    if(!authAdmin && isInTabsGroup){
//     console.log("Not signed in and not in (auth)")

   

//    }
 
//    return () => {
     
//    }
//  }, [authAdmin,segments,loading])


// <Stack>
//       <Stack.Protected guard={!isLoggedIn}>
//         <Stack.Screen name="login" />
//       </Stack.Protected>

//       <Stack.Protected guard={isLoggedIn}>
//         <Stack.Screen name="private" />
//       </Stack.Protected>
//       {/* Expo Router includes all routes by default. Adding Stack.Protected creates exceptions for these screens. */}
//     </Stack>
const [isLoggedIn,setIsLoggedIn]=useState(false);
useEffect(()=>{
  console.log("4.");
const inSupermarketSection = (segments as string[]).includes('supermarket');

if(authAdmin && inSupermarketSection && AdminProfileData){
  setIsLoggedIn(true)
}
else{
  setIsLoggedIn(false);
}
console.log(isLoggedIn)
},[authAdmin,loading,AdminProfileData])
 console.log("Current isLoggedIn value:", isLoggedIn);

 return (   
      <Stack screenOptions={{headerShown:false}}>
        <Stack.Protected guard={isLoggedIn}>
          <Stack.Screen name="register" />
        </Stack.Protected>
        <Stack.Protected guard={isLoggedIn}>
          <Stack.Screen name="(tabs)" />
        </Stack.Protected>
      </Stack>  
 )

}

export default function StackLayout() {
  

  return (
  <AdminContextProvider>
    <InitialLayout/>
  </AdminContextProvider>  
  );

}

