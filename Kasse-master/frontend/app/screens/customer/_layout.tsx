import { Stack, useRouter, useSegments } from "expo-router";
import React, { useEffect, useState } from "react";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "@/firebase";
import "@/global.css"

const InitialLayout = () => {
  const { user } = useAuth();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    if (typeof user === "undefined") return;

    const inAuthGroup =
      segments[0] &&
      typeof segments[0] === "string" &&
      segments[0].startsWith("auth");

    // if (user && !inAuthGroup) {
    //   router.replace("/home");
    // } else if (!user && inAuthGroup) {
    // } else if (!user && !inAuthGroup) {
    //   router.replace("/");
    // }
  }, [user, segments, router]);

  return <Stack 
            screenOptions={{
              headerShown: false,
            }}
          />;
};
function useAuth() {
  const [user, setUser] = useState<any | null | undefined>(undefined);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (firebaseUser) => {
      setUser(firebaseUser);
    });
    return () => unsubscribe();
  }, []);

  return { user };
}

export default InitialLayout;
