import {onAuthStateChanged, signOut, User} from "firebase/auth"
import { createContext,ReactNode,useContext, useEffect } from "react";
import { useState,useMemo } from 'react';
import {auth,db} from "@/firebase"
import { router,useSegments } from "expo-router";
import { doc, getDoc, onSnapshot } from "firebase/firestore";


interface AdminProfile{
    createdAt:Date;
    email:string;
    role:string
    supermarketId:string;
    username:string;
    profilePictureURL:string
}

interface AdminContextType {
  authAdmin: User | null;
  AdminProfileData: AdminProfile | null;
  loading: boolean;
}

const AdminContext = createContext<AdminContextType>({
 authAdmin:null,
 AdminProfileData:null,
 loading:true
});



export function AdminContextProvider({children}:{children:ReactNode}){
  const [authAdmin, setAuthAdmin] = useState<User | null>(null);
  const [AdminProfileData, setAdminProfileData] = useState<AdminProfile | null>(null);
  const [loading, setLoading] = useState(false);
const segments = useSegments(); // Get the current URL segments

onAuthStateChanged(auth, (user) => {
  let unsubscribeUserDocListener:any= null; // Store the listener cleanup function

  if (user) {
    const docRef = doc(db, "users", user.uid);

    // Start listening to the user document
    unsubscribeUserDocListener = onSnapshot(docRef, (docSnap) => {
      if (docSnap.exists()) {
        console.log("User document found/updated:", docSnap.data());
        setAuthAdmin(user); // Set auth user
        //setAdminProfileData(docSnap.data()as any); // Set profile data
        // Navigation logic might trigger based on AdminProfileData existing now
      } else {
        // This might run briefly right after signup before setDoc completes,
        // but onSnapshot will run AGAIN automatically when the doc IS created.
        console.log("User document doesn't exist yet...");
        // Don't clear authAdmin here if you expect the doc to be created soon
      }
    }, (error) => {
      console.error("Error listening to user document:", error);
      // Handle error, maybe clear state
      setAuthAdmin(null);
      //setAdminProfileData(null);
    });

  } else {
    // User is signed out
    setAuthAdmin(null);
    setAdminProfileData(null);
    // Cleanup the listener if it exists from a previous login
    if (unsubscribeUserDocListener) {
      unsubscribeUserDocListener();
    }
  }

  // Make sure to return a cleanup function for the onAuthStateChanged listener itself
  // How you do this depends on where this code lives (e.g., inside a useEffect)
  return () => {
    if (unsubscribeUserDocListener) {
      unsubscribeUserDocListener();
    }
  };
});

// useEffect(() => {
//   console.log("2.");
//  const unsubscribe=onAuthStateChanged(auth,(user)=>{
//     if(user){
//     setAuthAdmin(user);
//     console.log("admin sign in");
//     console.log(user.uid);
//     // router.push("/screens/supermarket/register")
//     }
//     else{
          
//             setAdminProfileData(null);
//             setLoading(false);
//     }
//   })
//   return ()=>{
//     unsubscribe();
//   }
// }, [])


useEffect(()=>{
  console.log("1:",AdminProfileData,authAdmin)
  if(AdminProfileData && authAdmin){
    if(AdminProfileData.role=="supermarket admin"){
      console.log("AdminProfileData.role : ",AdminProfileData.role)
      if(AdminProfileData.supermarketId==''){
        console.log("Navigating too /screens/supermarket/(tabs)/register")
        router.navigate("/screens/supermarket/register")
      }
      else{
          console.log("Navigating too /screens/supermarket/(tabs)/Dashboard")
          router.navigate("/screens/supermarket/(tabs)/Dashboard")
      }
    }
  }


  // if(authAdmin){
  //   router.push("/screens/supermarket/register")
  // }

},[authAdmin,AdminProfileData])

// import { doc, getDoc } from "firebase/firestore";

// const docRef = doc(db, "cities", "SF");
// const docSnap = await getDoc(docRef);

// if (docSnap.exists()) {
//   console.log("Document data:", docSnap.data());
// } else {
//   // docSnap.data() will be undefined in this case
//   console.log("No such document!");
// }

    useEffect(()=>{
      console.log("3.")
        const getAdminData=async ()=>{

        const inSupermarketSection = (segments as string[]).includes('supermarket');
        try{  
          console.log("3.",authAdmin)  
        if(authAdmin && inSupermarketSection){
            const uid=authAdmin.uid;
            const docRef = doc(db, "users",uid);
            const docSnap = await getDoc(docRef);
            if (docSnap.exists()) {
            const data = docSnap.data();
            console.log("Document data:", data);
            console.log("profile data :",AdminProfileData)
            console.log(segments);

              const profileData: AdminProfile = {
                email: data.email,
                role: data.role,
                supermarketId:data.supermarketId,
                username: data.username,
                createdAt: data.createdAt.toDate(), // <-- Key change here!
                profilePictureURL:data.profilePictureURL
            };
            if(profileData.role=="supermarket admin"){
            setAdminProfileData(profileData);

            console.log("Admin Profile data set : ",AdminProfileData);
            }  

            //code to check if admin has registered his supermarket or no



            } else {
          // Handle case where user exists in Auth but not Firestore
          setAdminProfileData(null);
          console.log("no such doc in firestore")
        }
        setLoading(false);
         }
       }
       catch (error) {
        console.error("Failed to fetch Admin data:", error);
      }
    }

    getAdminData();

    },[authAdmin])  //removed segment as dep



    useEffect(() => {
  // This will always log the most up-to-date value
  console.log("AdminProfileData has been updated in state:", AdminProfileData);
}, [AdminProfileData]);
            


   

      const value = useMemo(
    () => ({
      authAdmin,
      loading,
    }),
    [authAdmin, loading]
  );
  
 

  return (
    <AdminContext.Provider value={{authAdmin,AdminProfileData,loading}}>
        {children}
    </AdminContext.Provider>
  )
}



export const useAdminContext= ()=>useContext(AdminContext) 
