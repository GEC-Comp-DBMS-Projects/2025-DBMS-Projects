// import { Tabs } from 'expo-router';
// import {MaterialCommunityIcons} from '@expo/vector-icons';

// export default function TabLayout() {
//   return (
//     <Tabs screenOptions={{ tabBarActiveTintColor: '#FFBF00' ,headerShown:false}}>
//       <Tabs.Screen
//         name="Dashboard"
//         options={{
//           title: 'Dashboard',
//           tabBarIcon: ({ color }) => <MaterialCommunityIcons name="view-dashboard" size={30} color={color} />,
//         }}
//       />
//       <Tabs.Screen
//         name="Invetory"
//         options={{
//           title: 'Invetory',
//           tabBarIcon: ({ color }) => <MaterialCommunityIcons name="package-variant" size={30} color={color} />,
//         }}
//       />
//     </Tabs>
//   );
// }

import { Tabs } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons'; // Corrected import name

export default function TabLayout() {
  return (
    <Tabs screenOptions={{ tabBarActiveTintColor: '#FFBF00', headerShown: false }}>
      <Tabs.Screen
        name="Dashboard"
        options={{
          title: 'Dashboard',
          tabBarIcon: ({ color }) => <MaterialCommunityIcons name="view-dashboard" size={30} color={color} />,
        }}
      />
      <Tabs.Screen
        name="Invetory" // Note: You still have the typo "Invetory" here
        options={{
          title: 'Inventory', // Corrected title spelling
          tabBarIcon: ({ color }) => <MaterialCommunityIcons name="package-variant" size={30} color={color} />,
        }}
      />
      
      {/* --- ADD THIS NEW SCREEN --- */}
      <Tabs.Screen
        name="StockStatusScreen" // Matches the filename you created
        options={{
          title: 'Stock Status', // Sets the label under the icon
          tabBarIcon: ({ color }) => <MaterialCommunityIcons name="chart-line" size={30} color={color} />, // Example icon
        }}
      />
      {/* --- END OF ADDED SCREEN --- */}

    </Tabs>
  );
}
