

// import React, { useState } from 'react';
// import {
//   View,
//   Text,
//   TextInput,
//   TouchableOpacity,
//   StyleSheet,
//   SafeAreaView,
//   KeyboardAvoidingView,
//   Platform,
  
//   ActivityIndicator,
// } from 'react-native';
// import { Ionicons } from '@expo/vector-icons';
// import {router} from "expo-router"
// import { signInWithEmailAndPassword,signOut} from 'firebase/auth';
// import { auth,db} from '@/firebase'; // Import your firebase auth instance
// import { doc, getDoc } from 'firebase/firestore';


// export default function LoginScreen() {
//   const [email, setEmail] = useState('');
//   const [password, setPassword] = useState('');
//   const [loading, setLoading] = useState(false);
//   const [error, setError] = useState<string | null>(null);
//   const [secureText, setSecureText] = useState(true);




//   const handleSignIn = async () => {
//     // Clear previous error
//     setError(null);

//     // Validation
//     if (!email || !password) {
//       setError('Please fill in all fields');
//       return;
//     }

//     setLoading(true);
//     try {
//       const userCredential = await signInWithEmailAndPassword(auth, email, password);


//       const user = userCredential.user;

//       // 2. Fetch the user's document from Firestore
//       const userDocRef = doc(db, "users", user.uid);
//       const docSnap = await getDoc(userDocRef);

//       // 3. Check if the user has the correct role
//       if (docSnap.exists() && docSnap.data().role === 'supermarket admin') {
//         // Success! The root layout's redirection logic will take over.
        
//         console.log("Admin signed in successfully.");
//       } else {
//         // 4. If not an admin, sign them out immediately and throw an error
//         await signOut(auth);
//         throw new Error("Access denied. Not an admin account.");
//       }



//       // On success, the root layout's redirection logic will take over.
//     } catch (err: any) {
//       // Handle different Firebase error codes
//       let errorMessage = 'An error occurred during sign in';
      
//       if (err.code === 'auth/invalid-email') {
//         errorMessage = 'Invalid email address';
//       } else if (err.code === 'auth/user-disabled') {
//         errorMessage = 'This account has been disabled';
//       } else if (err.code === 'auth/user-not-found') {
//         errorMessage = 'No account found with this email';
//       } else if (err.code === 'auth/wrong-password') {
//         errorMessage = 'Incorrect password';
//       } else if (err.code === 'auth/invalid-credential') {
//         errorMessage = 'Invalid email or password';
//       } else {
//         errorMessage = err.message;
//       }
      
//       setError(errorMessage);
//     } finally {
//       setLoading(false);
//     }
//   };

//   return (
//     <SafeAreaView style={styles.container}>
//       <KeyboardAvoidingView
//         behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
//         style={styles.keyboardView}
//       >
//         <View style={styles.content}>
//           {/* Header */}
//           <View style={styles.header}>
//             <TouchableOpacity style={styles.backButton} onPress={()=>router.back()}>
//               <Ionicons name="arrow-back" size={24} color="#000" />
//             </TouchableOpacity>
//             <Text style={styles.headerTitle}>Login</Text>
//             <View style={styles.placeholder} />
//           </View>

//           {/* Form */}
//           <View style={styles.form}>
//             {/* Error Message */}
//             {error && (
//               <View style={styles.errorContainer}>
//                 <Ionicons name="alert-circle" size={20} color="#DC2626" />
//                 <Text style={styles.errorText}>{error}</Text>
//               </View>
//             )}

//             {/* Email Input */}
//             <View style={styles.inputGroup}>
//               <Text style={styles.label}>Email</Text>
//               <TextInput
//                 style={styles.input}
//                 placeholder="Enter Email"
//                 placeholderTextColor="#4d4843d5"
//                 value={email}
//                 onChangeText={(text) => {
//                   setEmail(text);
//                   if (error) setError(null); // Clear error on input
//                 }}
//                 keyboardType="email-address"
//                 autoCapitalize="none"
//                 autoCorrect={false}
//                 editable={!loading}
//               />
//             </View>

//             {/* Password Input */}
//             <View style={styles.inputGroup}>
//               <Text style={styles.label}>Password</Text>
//               <View style={styles.passwordContainer}>
//                 <TextInput
//                   style={styles.passwordInput}
//                   placeholder="Enter your password"
//                   placeholderTextColor="#4d4843d5"
//                   value={password}
//                   onChangeText={(text) => {
//                     setPassword(text);
//                     if (error) setError(null); // Clear error on input
//                   }}
//                   secureTextEntry={secureText}
//                   autoCapitalize="none"
//                   autoCorrect={false}
//                   editable={!loading}
//                 />
//                 <TouchableOpacity
//                   style={styles.eyeIcon}
//                   onPress={() => setSecureText(!secureText)}
//                   disabled={loading}
//                 >
//                   <Ionicons
//                     name={secureText ? 'eye-off' : 'eye'}
//                     size={20}
//                     color="#666"
//                   />
//                 </TouchableOpacity>
//               </View>
//             </View>
//           </View>

//           {/* Login Button */}
//           <View style={styles.buttonContainer}>
//             <TouchableOpacity
//               style={[styles.loginButton, loading && styles.loginButtonDisabled]}
//               onPress={handleSignIn}
//               disabled={loading}
//             >
//               {loading ? (
//                 <ActivityIndicator size="small" color="#000" />
//               ) : (
//                 <Text style={styles.loginButtonText}>Login</Text>
//               )}
//             </TouchableOpacity>
//           </View>
//         </View>
//       </KeyboardAvoidingView>
//     </SafeAreaView>
//   );
// }

// const styles = StyleSheet.create({
//   container: {
//     flex: 1,
//     backgroundColor: '#FFFEF9',
//   },
//   keyboardView: {
//     flex: 1,
//   },
//   content: {
//     flex: 1,
//   },
//   header: {
//     flexDirection: 'row',
//     alignItems: 'center',
//     justifyContent: 'space-between',
//     paddingHorizontal: 16,
//     paddingVertical: 16,
//   },
//   backButton: {
//     width: 40,
//   },
//   headerTitle: {
//     fontSize: 18,
//     fontWeight: '600',
//     color: '#000',
//   },
//   placeholder: {
//     width: 40,
//   },
//   form: {
//     paddingHorizontal: 16,
//     paddingTop: 20,
//   },
//   errorContainer: {
//     flexDirection: 'row',
//     alignItems: 'center',
//     backgroundColor: '#FEE2E2',
//     borderRadius: 8,
//     padding: 12,
//     marginBottom: 16,
//     gap: 8,
//   },
//   errorText: {
//     flex: 1,
//     fontSize: 14,
//     color: '#DC2626',
//     fontWeight: '500',
//   },
//   inputGroup: {
//     marginBottom: 24,
//   },
//   label: {
//     fontSize: 14,
//     fontWeight: '500',
//     color: '#000',
//     marginBottom: 8,
//   },
//   input: {
//     backgroundColor: '#ffbf003a',
//     borderRadius: 8,
//     paddingHorizontal: 16,
//     paddingVertical: 16,
//     fontSize: 14,
//     color: '#000',
//     shadowColor: "#000",
//     shadowOffset: { width: 0, height: 4 },
//     shadowOpacity: 0.15,
//     shadowRadius: 4,
//     elevation: 4,
//   },
//   passwordContainer: {
//     flexDirection: 'row',
//     alignItems: 'center',
//     backgroundColor: '#ffbf003a',
//     borderRadius: 8,
//     paddingHorizontal: 16,
//     shadowColor: "#000",
//     shadowOffset: { width: 0, height: 4 },
//     shadowOpacity: 0.15,
//     shadowRadius: 4,
//     elevation: 4,
//   },
//   passwordInput: {
//     flex: 1,
//     paddingVertical: 16,
//     fontSize: 14,
//     color: '#000',
//   },
//   eyeIcon: {
//     padding: 4,
//   },
//   buttonContainer: {
//     position: 'absolute',
//     bottom: 30,
//     left: 16,
//     right: 16,
//   },
//   loginButton: {
//     backgroundColor: '#FDB022',
//     borderRadius: 8,
//     paddingVertical: 16,
//     alignItems: 'center',
//     shadowColor: '#000',
//     shadowOffset: {
//       width: 0,
//       height: 2,
//     },
//     shadowOpacity: 0.1,
//     shadowRadius: 4,
//     elevation: 3,
//   },
//   loginButtonDisabled: {
//     opacity: 0.7,
//   },
//   loginButtonText: {
//     fontSize: 16,
//     fontWeight: '600',
//     color: '#000',
//   },
// });



import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
  
  ActivityIndicator,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import {router} from "expo-router"
import { signInWithEmailAndPassword,signOut} from 'firebase/auth';
import { auth,db} from '@/firebase'; // Import your firebase auth instance
import { doc, getDoc } from 'firebase/firestore';


export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [secureText, setSecureText] = useState(true);




  const handleSignIn = async () => {
    // Clear previous error
    setError(null);

    // Validation
    if (!email || !password) {
      setError('Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);


      const user = userCredential.user;

      // 2. Fetch the user's document from Firestore
      const userDocRef = doc(db, "users", user.uid);
      const docSnap = await getDoc(userDocRef);

      // 3. Check if the user has the correct role
      if (docSnap.exists() && docSnap.data().role === 'supermarket admin') {
        // Success! The root layout's redirection logic will take over.
        console.log("Admin signed in successfully.");

      } else {
        // 4. If not an admin, sign them out immediately and throw an error
        await signOut(auth);
        throw new Error("Access denied. Not an admin account.");
      }



      // On success, the root layout's redirection logic will take over.
    } catch (err: any) {
      // Handle different Firebase error codes
      let errorMessage = 'An error occurred during sign in';
      
      if (err.code === 'auth/invalid-email') {
        errorMessage = 'Invalid email address';
      } else if (err.code === 'auth/user-disabled') {
        errorMessage = 'This account has been disabled';
      } else if (err.code === 'auth/user-not-found') {
        errorMessage = 'No account found with this email';
      } else if (err.code === 'auth/wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (err.code === 'auth/invalid-credential') {
        errorMessage = 'Invalid email or password';
      } else {
        errorMessage = err.message;
      }
      
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <View style={styles.content}>
          {/* Header */}
          <View style={styles.header}>
            <TouchableOpacity style={styles.backButton} onPress={()=>router.back()}>
              <Ionicons name="arrow-back" size={24} color="#000" />
            </TouchableOpacity>
            <Text style={styles.headerTitle}>Login</Text>
            <View style={styles.placeholder} />
          </View>

          {/* Form */}
          <View style={styles.form}>
            {/* Error Message */}
            {error && (
              <View style={styles.errorContainer}>
                <Ionicons name="alert-circle" size={20} color="#DC2626" />
                <Text style={styles.errorText}>{error}</Text>
              </View>
            )}

            {/* Email Input */}
            <View style={styles.inputGroup}>
              <Text style={styles.label}>Email</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter Email"
                placeholderTextColor="#B8956A"
                value={email}
                onChangeText={(text) => {
                  setEmail(text);
                  if (error) setError(null); // Clear error on input
                }}
                keyboardType="email-address"
                autoCapitalize="none"
                autoCorrect={false}
                editable={!loading}
              />
            </View>

            {/* Password Input */}
            <View style={styles.inputGroup}>
              <Text style={styles.label}>Password</Text>
              <View style={styles.passwordContainer}>
                <TextInput
                  style={styles.passwordInput}
                  placeholder="Enter your password"
                  placeholderTextColor="#B8956A"
                  value={password}
                  onChangeText={(text) => {
                    setPassword(text);
                    if (error) setError(null); // Clear error on input
                  }}
                  secureTextEntry={secureText}
                  autoCapitalize="none"
                  autoCorrect={false}
                  editable={!loading}
                />
                <TouchableOpacity
                  style={styles.eyeIcon}
                  onPress={() => setSecureText(!secureText)}
                  disabled={loading}
                >
                  <Ionicons
                    name={secureText ? 'eye-off' : 'eye'}
                    size={20}
                    color="#666"
                  />
                </TouchableOpacity>
              </View>
            </View>
          </View>

          {/* Login Button */}
          <View style={styles.buttonContainer}>
            <TouchableOpacity
              style={[styles.loginButton, loading && styles.loginButtonDisabled]}
              onPress={handleSignIn}
              disabled={loading}
            >
              {loading ? (
                <ActivityIndicator size="small" color="#000" />
              ) : (
                <Text style={styles.loginButtonText}>Login</Text>
              )}
            </TouchableOpacity>
          </View>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFEF9',
  },
  keyboardView: {
    flex: 1,
  },
  content: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 16,
  },
  backButton: {
    width: 40,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000',
  },
  placeholder: {
    width: 40,
  },
  form: {
    paddingHorizontal: 16,
    paddingTop: 20,
  },
  errorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FEE2E2',
    borderRadius: 8,
    padding: 12,
    marginBottom: 16,
    gap: 8,
  },
  errorText: {
    flex: 1,
    fontSize: 14,
    color: '#DC2626',
    fontWeight: '500',
  },
  inputGroup: {
    marginBottom: 24,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: '#000',
    marginBottom: 8,
  },
  input: {
    backgroundColor: '#FFF8E7',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 16,
    fontSize: 14,
    color: '#000',
  },
  passwordContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFF8E7',
    borderRadius: 8,
    paddingHorizontal: 16,
  },
  passwordInput: {
    flex: 1,
    paddingVertical: 16,
    fontSize: 14,
    color: '#000',
  },
  eyeIcon: {
    padding: 4,
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 30,
    left: 16,
    right: 16,
  },
  loginButton: {
    backgroundColor: '#FDB022',
    borderRadius: 8,
    paddingVertical: 16,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  loginButtonDisabled: {
    opacity: 0.7,
  },
  loginButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000',
  },
});