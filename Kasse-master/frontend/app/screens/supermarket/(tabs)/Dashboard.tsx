

// import React from 'react'

// import {
//   View,
//   Text,
//   TouchableOpacity,
//   StyleSheet,
// } from 'react-native';
// import { Ionicons } from '@expo/vector-icons';
// import { router } from "expo-router"
// import { signOut } from 'firebase/auth';
// import { auth } from '@/firebase'; // Import your firebase auth instance

// export default function Dashboard() {
  
//   const handleLogout = async () => {
    
//             try {
//               await signOut(auth);
//               router.navigate("/")
//               // Firebase auth state change will trigger the context to set authAdmin to null
//               // The root layout's logic will automatically redirect to login
//             } catch (error) {
//               console.error('Error signing out:', error);
//               console.log('Error', 'Failed to logout. Please try again.');
//             }
//           }
     

//   return (
//     <View style={styles.container}>
//       <View style={styles.header}>
//         {/* <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
//           <Ionicons name="arrow-back" size={24} color="#000" />
//         </TouchableOpacity> */}
//         <Text style={styles.headerTitle}>Dashboard</Text>
//         <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
//           <Ionicons name="log-out-outline" size={24} color="#DC2626" />
//         </TouchableOpacity>
//       </View>

//       {/* Add your dashboard content here */}
//       <View style={styles.content}>
//         <Text style={styles.welcomeText}>Welcome to Dashboard</Text>
//       </View>
//     </View>
//   )
// }

// const styles = StyleSheet.create({
//   container: {
//     flex: 1,
//     backgroundColor: '#FFFEF9',
//   },
//   scrollContent: {
//     paddingBottom: 30,
//   },
//   header: {
//     flexDirection: 'row',
//     alignItems: 'center',
//     justifyContent: 'space-between',
//     paddingHorizontal: 16,
//     paddingVertical: 16,
//     borderBottomWidth: 1,
//     borderBottomColor: '#f0f0f0',
//   },
//   backButton: {
//     width: 40,
//   },
//   headerTitle: {
//     fontSize: 18,
//     fontWeight: '700',
//     color: '#000',
//   },
//   logoutButton: {
//     width: 40,
//     alignItems: 'flex-end',
//   },
//   content: {
//     flex: 1,
//     justifyContent: 'center',
//     alignItems: 'center',
//   },
//   welcomeText: {
//     fontSize: 20,
//     fontWeight: '600',
//     color: '#000',
//   },
//   placeholder: {
//     width: 40,
//   },
//   form: {
//     paddingHorizontal: 16,
//     paddingTop: 10,
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
//     marginBottom: 20,
//   },
//   label: {
//     fontSize: 14,
//     fontWeight: '600',
//     color: '#000',
//     marginBottom: 8,
//   },
//   input: {
//     backgroundColor: '#FFF8E7',
//     borderRadius: 8,
//     paddingHorizontal: 16,
//     paddingVertical: 16,
//     fontSize: 14,
//     color: '#000',
//   },
//   passwordContainer: {
//     flexDirection: 'row',
//     alignItems: 'center',
//     backgroundColor: '#FFF8E7',
//     borderRadius: 8,
//     paddingHorizontal: 16,
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
//   uploadSection: {
//     marginBottom: 24,
//   },
//   uploadLabel: {
//     fontSize: 14,
//     fontWeight: '600',
//     color: '#000',
//     marginBottom: 12,
//   },
//   optionalText: {
//     fontWeight: '400',
//     color: '#666',
//   },
//   uploadContainer: {
//     marginTop: 8,
//   },
//   uploadBox: {
//     backgroundColor: '#fff',
//     borderRadius: 12,
//     borderWidth: 2,
//     borderColor: '#e0e0e0',
//     borderStyle: 'dashed',
//     padding: 40,
//     alignItems: 'center',
//     justifyContent: 'center',
//     minHeight: 160,
//     marginBottom: 12,
//   },
//   uploadTitle: {
//     fontSize: 16,
//     fontWeight: '600',
//     color: '#000',
//     marginBottom: 8,
//   },
//   uploadSubtitle: {
//     fontSize: 13,
//     color: '#666',
//     textAlign: 'center',
//   },
//   profileImage: {
//     width: 120,
//     height: 120,
//     borderRadius: 60,
//     resizeMode: 'cover',
//   },
//   uploadButton: {
//     backgroundColor: '#fff',
//     borderRadius: 8,
//     paddingVertical: 12,
//     paddingHorizontal: 32,
//     alignSelf: 'center',
//     borderWidth: 1,
//     borderColor: '#ddd',
//   },
//   uploadButtonText: {
//     fontSize: 14,
//     fontWeight: '600',
//     color: '#000',
//   },
//   completeButton: {
//     backgroundColor: '#FDB022',
//     borderRadius: 8,
//     paddingVertical: 16,
//     alignItems: 'center',
//     marginTop: 20,
//     shadowColor: '#000',
//     shadowOffset: {
//       width: 0,
//       height: 2,
//     },
//     shadowOpacity: 0.1,
//     shadowRadius: 4,
//     elevation: 3,
//   },
//   completeButtonDisabled: {
//     opacity: 0.7,
//   },
//   completeButtonText: {
//     fontSize: 16,
//     fontWeight: '600',
//     color: '#000',
//   },
// });

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  Image,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import { useRouter } from 'expo-router';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { signOut } from 'firebase/auth';
import { auth } from '@/firebase'; 
import { doc, getDoc, getFirestore,getCountFromServer, collection, getDocs,where,query,onSnapshot } from 'firebase/firestore'; // To fetch data
import { useAdminContext } from '../context/adminContext';

const db = getFirestore();

export default function AdminDashboardScreen() {
  const router = useRouter();

  const {AdminProfileData,authAdmin}=useAdminContext();
  const [storeData, setStoreData] = useState<any>(null);
  const [storeRef,setstoreRef]=useState<any>(null);
  const [totalProducts,setTotalProducts]=useState<any>(0);
  const [loadingStoreData, setLoadingStoreData] = useState(true);
  const [totalStock,setTotalStock]=useState(0);
  const [lowStockCount, setLowStockCount] = useState<any>(0);
  const [lowStockItems, setLowStockItems] = useState<any>([]);
  const [totalCustomers, setTotalCustomers] = useState(0);

  const PRIMARY_AMBER = '#FFBF00';
  const CARD_SHADOW = {
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 5,
    elevation: 3,
  };


  
  const handleLogout = async () => {
    try {
      await signOut(auth);
      router.navigate("/");
    } catch (error) {
      console.error('Error signing out:', error);
      console.log('Error', 'Failed to logout. Please try again.');
    }
  };



  useEffect(() => {
    if (!storeRef) {
      return;
    }
    const cartCollectionRef = collection(storeRef, 'cart');
    const completedCartsQuery = query(cartCollectionRef, where('status', '==', 'completed'));

    const unsubscribe = onSnapshot(completedCartsQuery, (querySnapshot) => {
      // let todaySum = 0;
      // let weekSum = 0;
      // let monthSum = 0;
      // let allTimeSum = 0;
      
      // --- ADD: Use a Set to store unique customer IDs ---
      const customerIds = new Set<string>(); 
      // ----------------------------------------------------

      // const now = new Date();
      // ... (rest of your date boundary calculations: startOfDay, startOfWeek, etc.)

      querySnapshot.forEach((doc) => { 
           const data = doc.data();
        // const amount = data.totalAmount || 0;
        // const paidAtTimestamp = data.paidAt;
        const userId = data.userId; // --- Get the userId ---

        // --- ADD: Add userId to the Set (duplicates are automatically ignored) ---
        if (userId) {
          customerIds.add(userId);
        }
        // -----------------------------------------------------------------------


        // --- Keep your existing revenue calculation logic ---
      //   if (paidAtTimestamp?.toDate) {
      //      const paidAtDate = paidAtTimestamp.toDate();
      //      allTimeSum += amount;
      //      if (paidAtDate >= startOfDay) todaySum += amount;
      //      if (paidAtDate >= startOfWeek) weekSum += amount;
      //      if (paidAtDate >= startOfMonth) monthSum += amount;
      //   } else {
      //        allTimeSum += amount;
      //        console.log(`Cart ${doc.id} missing valid paidAt timestamp.`);
      //   }
      //   // --- End of revenue logic ---
      // });

      // Update revenue states
      // setRevenueToday(todaySum);
      // setRevenueThisWeek(weekSum);
      // setRevenueThisMonth(monthSum);
      // setRevenueAllTime(allTimeSum);
      
      // --- ADD: Update total customer count ---
      // setTotalCustomers(customerIds.size);
      // ----------------------------------------

    // }, (error) => {
    //   console.error("Error listening to completed carts:", error);
      // Reset states on error
      // setRevenueToday(0);
      // setRevenueThisWeek(0);
      // setRevenueThisMonth(0);
      // setRevenueAllTime(0);
    //   setTotalCustomers(0); // --- ADD Reset ---
    });

    setTotalCustomers(customerIds.size);

    });

    return () => unsubscribe();

  }, [storeRef]);



// --- New useEffect to listen for real-time store data ---
useEffect(() => {
  // 1. Check if we have the AdminProfileData and the supermarketId
  if (!AdminProfileData?.supermarketId) {
    console.log("Admin profile or supermarketId not loaded yet.");
    setLoadingStoreData(false); // Stop loading
    return; // Wait until we have the ID
  }

  setLoadingStoreData(true);
  
  // 2. Define the document reference
  const localStoreRef = doc(db, 'supermarket', AdminProfileData.supermarketId);
  
  // 3. Set the storeRef for the *other* useEffect (inventory stats) to use
  setstoreRef(localStoreRef);

  // 4. Set up the real-time listener for the supermarket document
  const unsubscribe = onSnapshot(localStoreRef, (docSnap) => {
    if (docSnap.exists()) {
      // 5. Update state with the new data
      setStoreData(docSnap.data());
    } else {
      console.log("No such store document!");
      setStoreData(null);
    }
    setLoadingStoreData(false); // Stop loading once data is fetched/updated
  }, (error) => {
    // Handle listener errors
    console.error("Error listening to store data:", error);
    setStoreData(null);
    setLoadingStoreData(false);
  });

  // 6. Return the cleanup function
  return () => unsubscribe();

}, [AdminProfileData]); // Dependency: Re-run if the admin profile (and ID) changes




  // async function fetchInvetoryStats(){
  //       if(storeRef && authAdmin){
  //       try{ 
  //       //for total products   
  //       const productCollectionRef = collection(storeRef,"products");

  //       let noOfProducts=await getCountFromServer(productCollectionRef);
  //       console.log(noOfProducts.data().count);
  //       setTotalProducts(noOfProducts.data().count)

  //   //for total stock
  //       let sumOfProducts=0;
  //       const products=await getDocs(productCollectionRef);
  //       products.forEach((doc)=>{
  //         const data=doc.data();
  //         console.log(data.productName);
  //         sumOfProducts+=data.stockQuantity;
  //         console.log(sumOfProducts);
  //       })  
  //       setTotalStock(sumOfProducts);

  //         //for low stock items
  //         const lowStockQuery = query(productCollectionRef, where("stockQuantity", "<", 20));
          
  //         const querySnapshot = await getDocs(lowStockQuery);
          
  //         // Set the count
  //         setLowStockCount(querySnapshot.size);

  //         // Get the actual product data and store it
  //           const items:any[] = [];
  //           querySnapshot.forEach((doc) => {
  //             items.push({ id: doc.id, ...doc.data() });
  //           });
  //           setLowStockItems(items); // Store items for navigation  
  //           }
  //           catch(error){
  //           console.log("Error fetching stats",error);
  //         }
  //   }
  
  // }

  // useEffect(()=>{
  //   //console.log("hello from ",storeData.supermarketName);
  //   fetchInvetoryStats();
  // },[storeData,storeRef])


  // REPLACE it with this new useEffect
useEffect(() => {
  // Ensure we have the storeRef and the user is logged in
  if (storeRef && authAdmin) {
    
    // 1. Get the reference to the products subcollection
    const productCollectionRef = collection(storeRef, "products");

    // 2. Set up the real-time listener
    const unsubscribe = onSnapshot(productCollectionRef, (querySnapshot) => {
      
      let sumOfProducts = 0;
      let lowStockCount = 0;
      const items: any[] = [];

      // 3. Loop through all product documents in the snapshot
      querySnapshot.forEach((doc) => {
        const data = doc.data();
        const stock = data.stockQuantity || 0; // Default to 0 if undefined

        // Calculate total stock
        sumOfProducts += stock;

        // Calculate low stock items (stock < 20)
        if (stock < 20) {
          lowStockCount++;
          items.push({ id: doc.id, ...data });
        }
      });

      // 4. Update all states at once
      setTotalProducts(querySnapshot.size); // Total products is just the snapshot size
      setTotalStock(sumOfProducts);
      setLowStockCount(lowStockCount);
      setLowStockItems(items); // You were already setting this, so keep it

    }, (error) => {
      // Handle listener errors
      console.error("Error listening to product stats:", error);
    });

    // 5. Return the cleanup function to stop listening when the component unmounts
    return () => unsubscribe();
  }
}, [storeRef, authAdmin]); // Dependencies



  // --- UI/Frontend Logic from dashboard2 ---
  const dashboardMetrics = [
    { title: 'Total Products', value: totalProducts, subtitle: 'Active products in inventory', icon: 'key-chain-variant' },
    { title: 'Total Stock', value: totalStock, subtitle: 'Units across all products', icon: 'chart-bar' },
    { title: 'Low Stock Items', value: lowStockCount, subtitle: 'Products below 20 units', icon: 'cart-off' },
    { title: 'Total Customers', value: totalCustomers, subtitle: 'Unique users with purchases', icon: 'account-group' },
  ];

  const renderMetricCard = (metric: (typeof dashboardMetrics)[0], index: number) => {
    let iconColor = '#808080';
    if (metric.title === 'Low Stock Items') {
      iconColor = '#DC2626';
    }

    return (
      <View key={index} style={[styles.metricCard, CARD_SHADOW]}>
        <View style={styles.metricHeader}>
          <Text style={styles.metricTitle}>{metric.title}</Text>
          <Icon
            name={
              metric.title === 'Total Products' ? 'archive-lock' :
              metric.title === 'Total Stock' ? 'chart-bar-stacked' :
              'alert-octagon'
            }
            size={20}
            color={iconColor}
          />
        </View>
        <Text style={[styles.metricValue, { color: metric.title === 'Low Stock Items' ? '#DC2626' : '#000' }]}>
          {metric.value}
        </Text>
        <Text style={styles.metricSubtitle}>{metric.subtitle}</Text>
      </View>
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        {/* <TouchableOpacity onPress={() => router.back()} style={styles.headerButton}>
          <Icon name="arrow-left" size={24} color="#000" />
        </TouchableOpacity> */}
        <View style={styles.headerTitleContainer}>
          <Text style={styles.headerTitle}>Admin Dashboard</Text>
        </View>
        <TouchableOpacity style={styles.headerButton} onPress={()=>{router.navigate('/screens/supermarket/AdminProfile')}}>
          <Icon name="account-circle" size={24} color={PRIMARY_AMBER} />
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        {loadingStoreData ? (
          <ActivityIndicator size="large" color={PRIMARY_AMBER} style={{ marginTop: 50 }} />
        ) : (
          <View style={[styles.storeCard, CARD_SHADOW]}>
            <Image
              source={{ uri: storeData?.supermarketImgUrl || 'https://picsum.photos/150' }}
              style={{width: '100%', height: 200,borderRadius: 10, marginBottom: 10}}
              resizeMode='cover'
              onError={() => console.log('Image failed to load',storeData.supermarketImgUrl)}
            />
            <Text style={styles.storeName}>{storeData?.sname || 'Fresh and Fine foods'}</Text>
            <Text style={styles.storeAddress}>{storeData?.streetAddress || '123 Main Street, Cityville'}</Text>
            <Text style={styles.storeAddress}>
              {storeData?.state || 'State'} - {storeData?.pinCode || '000000'}
            </Text>
            <Text style={styles.storeDescription}>
              {storeData?.desc || 'Your neighborhood supermarket offering fresh produce, dairy, and daily essentials at great prices.'}
            </Text>
            <TouchableOpacity
              style={[styles.editButton, { backgroundColor: '#1A1A1A' }]}
              onPress={()=>router.navigate('/screens/supermarket/products/EditSupermarket')}
            >
              <Text style={styles.editButtonText}>Edit</Text>
            </TouchableOpacity>
          </View>
        )}

        <View style={styles.metricsContainer}>
          {dashboardMetrics.map(renderMetricCard)}
        </View>
        <View style={{ height: 100 }} />
      </ScrollView>

     
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F7F7F7',
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 80,
    alignItems: 'center',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  headerButton: {
    width: 30,
    alignItems: 'center',
  },
  headerTitleContainer: {
    flex: 1,
    alignItems:"flex-start",
    justifyContent: 'center',
    marginLeft:15
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#000',
  },
  storeCard: {
    backgroundColor: '#fff',
    borderRadius: 15,
    padding: 20,
    alignItems: 'center',
    marginBottom: 16,
    width: '100%',
  },
  storeImage: {
    width: 150,
    height: 150,
    borderRadius: 10,
    marginBottom: 10,
    resizeMode: 'cover',
  },
  storeName: {
    fontSize: 18,
    fontWeight: '700',
    color: '#000',
    marginBottom: 4,
    textAlign: 'center',
  },
  storeAddress: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
    textAlign: 'center',
  },
  storeDescription: {
    fontSize: 14,
    color: '#444',
    textAlign: 'center',
    marginBottom: 20,
  },
  editButton: {
    paddingHorizontal: 30,
    paddingVertical: 8,
    borderRadius: 8,
  },
  editButtonText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 16,
  },
  metricsContainer: {
    width: '100%',
    gap: 16,
  },
  metricCard: {
    backgroundColor: '#fff',
    borderRadius: 15,
    padding: 20,
    width: '100%',
  },
  metricHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  metricTitle: {
    fontSize: 14,
    color: '#666',
    fontWeight: '500',
  },
  metricValue: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  metricSubtitle: {
    fontSize: 14,
    color: '#666',
  },
  bottomNav: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#eee',
    paddingBottom: 5,
    paddingTop: 8,
  },
  navItem: {
    alignItems: 'center',
  },
  navTextActive: {
    fontSize: 12,
    fontWeight: '600',
    color: '#000',
  },
  navTextInactive: {
    fontSize: 12,
    fontWeight: '600',
    color: '#FFBF00',
  },
});