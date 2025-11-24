// app/screens/supermarket/(tabs)/StockStatusScreen.tsx
import React, { useEffect, useState, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  FlatList,
  ActivityIndicator,
  TextInput, // --- ADDED ---
  Platform, // --- ADDED ---
  TouchableOpacity, // --- ADDED ---
} from 'react-native';
import { collection, doc, onSnapshot, query, orderBy } from 'firebase/firestore';
import { db } from '@/firebase';
import { useAdminContext } from '../context/adminContext';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { Ionicons } from '@expo/vector-icons'; // --- ADDED ---
import RNPickerSelect from 'react-native-picker-select'; // --- ADDED ---


// --- Constants (same as yours) ---
const PRIMARY_AMBER = '#FFBF00';
const CARD_BG = '#FFFFFF';
const LIGHT_BG = '#F7F7F7';
const DETAIL_BORDER_COLOR = '#E0E0E0';
const TEXT_COLOR = '#333';
const LIGHT_TEXT_COLOR = '#666';
const CRITICAL_RED = '#DC2626';
const LOW_YELLOW = '#FDB022';
const MEDIUM_BLUE = '#3B82F6';
const SUFFICIENT_GREEN = '#10B981';
const INPUT_BG = '#FFFFFF'; // --- ADDED ---

// --- Category List (Same as AddProductScreen) ---
const categories = [
    { label: 'All Categories', value: null }, // Add an "All" option
    { label: 'Accessories', value: 'Accessories' },
    { label: 'Groceries', value: 'Groceries' },
    { label: 'Electronics', value: 'Electronics' },
    { label: 'Snacks', value: 'Snacks' },
    { label: 'Beverages', value: 'Beverages' },
];

// Product Type - Added category
type Product = {
  id: string;
  productName: string;
  stockQuantity: number;
  category: string; // --- ADDED ---
};

// StockStatusBadge Component (No changes needed)
const StockStatusBadge = ({ stock }: { stock: number }) => {
    // ... (keep existing code)
    let statusText = 'Sufficient';
    let statusColor = SUFFICIENT_GREEN;

    if (stock < 5) {
        statusText = 'Critical';
        statusColor = CRITICAL_RED;
    } else if (stock < 12) {
        statusText = 'Low';
        statusColor = LOW_YELLOW;
    } else if (stock < 20) {
        statusText = 'Medium';
        statusColor = MEDIUM_BLUE;
    }

    return (
        <View style={[styles.statusBadge, { backgroundColor: statusColor }]}>
        <Text style={styles.statusText}>{statusText}</Text>
        </View>
    );
};

// --- Main Screen Component ---
export default function StockStatusScreen() {
  const { AdminProfileData } = useAdminContext();
  const [productList, setProductList] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchText, setSearchText] = useState(''); // --- ADDED Search State ---
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null); // --- ADDED Category State ---

  // --- Real-time data fetching (fetch category too) ---
  useEffect(() => {
    // ... (keep existing checks and refs)
    if (!AdminProfileData?.supermarketId) {
      setIsLoading(false);
      return;
    }
    
    setIsLoading(true);
    const localStoreRef = doc(db, 'supermarket', AdminProfileData.supermarketId);
    const localProductRef = collection(localStoreRef, "products");
    const q = query(localProductRef, orderBy('stockQuantity', 'desc'));

    const unsubscribe = onSnapshot(q, (snapshot) => {
      let dataList: Product[] = [];
      snapshot.forEach((doc) => {
        const data = doc.data();
        dataList.push({
          id: doc.id,
          productName: data.productName || 'No Name',
          stockQuantity: data.stockQuantity || 0,
          category: data.category || 'N/A', // --- Fetch category ---
        } as Product);
      });
      setProductList(dataList);
      setIsLoading(false);
    }, (error) => {
      console.error("Error fetching stock status:", error);
      setIsLoading(false);
    });

    return () => unsubscribe();
  }, [AdminProfileData]);

  // --- Filtered list based on search and category ---
  const filteredProductList = useMemo(() => {
    return productList.filter(product => {
      // Check category first
      const categoryMatch = !selectedCategory || product.category === selectedCategory;
      // Then check search text
      const searchMatch = !searchText || product.productName.toLowerCase().includes(searchText.toLowerCase());
      
      return categoryMatch && searchMatch;
    });
  }, [productList, searchText, selectedCategory]); // Dependencies: list, search text, category

    // --- Renders each item (No changes needed) ---
    const renderStockItem = ({ item }: { item: Product }) => (
        <View style={styles.itemRow}>
        <Text style={[styles.columnText, styles.productNameCol]} numberOfLines={2}>
            {item.productName}
        </Text>
        <Text style={[styles.columnText, styles.stockCol]}>{item.stockQuantity}</Text>
        <View style={styles.statusCol}>
            <StockStatusBadge stock={item.stockQuantity} />
        </View>
        </View>
    );

    // --- Render Header for the list (No changes needed) ---
    const ListHeader = () => (
        <View style={styles.listHeaderRow}>
        <Text style={[styles.headerText, styles.productNameCol]}>Product Name</Text>
        <Text style={[styles.headerText, styles.stockCol]}>Stock</Text>
        <Text style={[styles.headerText, styles.statusColHeader]}>Status</Text>
        </View>
    );

  return (
    <SafeAreaView style={styles.container}>
      {/* --- Header (No changes needed) --- */}
      <View style={styles.header}>
            <Text style={styles.headerTitle}>Stock Status</Text>
            <TouchableOpacity style={styles.headerButton}>
            <Icon name="account-circle" size={30} color={PRIMARY_AMBER} />
            </TouchableOpacity>
        </View>

        {/* --- ADDED: Filter Controls --- */}
        <View style={styles.filterContainer}>
             {/* Search Input */}
            <View style={styles.searchContainer}>
                <Ionicons name="search" size={20} color={LIGHT_TEXT_COLOR} style={styles.searchIcon} />
                <TextInput
                    style={styles.searchInput}
                    placeholder="Search by name..."
                    value={searchText}
                    onChangeText={setSearchText}
                    placeholderTextColor={LIGHT_TEXT_COLOR}
                />
            </View>
            {/* Category Picker */}
            <View style={styles.pickerWrapper}>
                 <RNPickerSelect
                    items={categories}
                    onValueChange={(value) => setSelectedCategory(value)}
                    value={selectedCategory}
                    style={pickerSelectStyles}
                    placeholder={{ label: "Select a Category...", value: null }} // Use placeholder prop
                    useNativeAndroidPickerStyle={false}
                    Icon={() => (
                        <Ionicons name="chevron-down" size={20} color={LIGHT_TEXT_COLOR} style={styles.pickerIcon} />
                    )}
                />
            </View>
        </View>
        {/* --- END: Filter Controls --- */}


      {isLoading ? (
        <ActivityIndicator size="large" color={PRIMARY_AMBER} style={{ marginTop: 50 }} />
      ) : (
        <FlatList
          data={filteredProductList} // --- Use filtered list ---
          renderItem={renderStockItem}
          keyExtractor={(item) => item.id}
          ListHeaderComponent={ListHeader}
          contentContainerStyle={styles.listContent}
          ItemSeparatorComponent={() => <View style={styles.separator} />}
          ListEmptyComponent={ // Show message if list is empty after filtering
              <View style={styles.emptyListContainer}>
                  <Text style={styles.emptyListText}>No products found matching your criteria.</Text>
              </View>
          }
        />
      )}
    </SafeAreaView>
  );
}

// --- Stylesheet ---
const styles = StyleSheet.create({
  // ... (keep existing container, header, list, itemRow, column, status styles)
  
    // --- ADDED: Filter Styles ---
    filterContainer: {
        paddingHorizontal: 16,
        paddingTop: 10,
        paddingBottom: 5,
        backgroundColor: CARD_BG, // Match header bg
        borderBottomWidth: 1,
        borderBottomColor: DETAIL_BORDER_COLOR,
    },
    searchContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: LIGHT_BG, // Lighter background for input
        borderRadius: 8,
        borderWidth: 1,
        borderColor: DETAIL_BORDER_COLOR,
        paddingHorizontal: 10,
        marginBottom: 10,
    },
    searchIcon: {
        marginRight: 8,
    },
    searchInput: {
        flex: 1,
        paddingVertical: Platform.OS === 'ios' ? 10 : 8,
        fontSize: 15,
        color: TEXT_COLOR,
    },
     pickerWrapper: {
        backgroundColor: LIGHT_BG,
        borderRadius: 8,
        borderWidth: 1,
        borderColor: DETAIL_BORDER_COLOR,
        height: 44, // Consistent height
        justifyContent: 'center',
    },
    pickerIcon: {
        position: 'absolute',
        right: 12,
        top: 12,
    },
    // --- END: Filter Styles ---

    // --- ADDED: Empty List Style ---
    emptyListContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: 40,
    },
    emptyListText: {
        fontSize: 16,
        color: LIGHT_TEXT_COLOR,
        textAlign: 'center',
    },
     // --- Styles from previous code ---
      container: {
        flex: 1,
        backgroundColor: LIGHT_BG,
      },
      // --- Header ---
      header: {
        // marginTop: 23, // Removed extra margin if using SafeAreaView
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 16,
        paddingVertical: Platform.OS === 'ios' ? 12 : 16,
        backgroundColor: CARD_BG,
        borderBottomWidth: 1,
        borderBottomColor: DETAIL_BORDER_COLOR,
      },
      headerButton: {
        width: 30,
        alignItems: 'center',
      },
      headerTitle: {
        fontSize: 24,
        fontWeight: '700',
        color: '#000',
      },
      // --- List ---
      listContent: {
        paddingBottom: 10, // Added padding at the bottom
      },
      listHeaderRow: {
        flexDirection: 'row',
        backgroundColor: '#EAEAEA', // Light grey header background
        paddingVertical: 10,
        paddingHorizontal: 16,
        borderBottomWidth: 1,
        borderBottomColor: DETAIL_BORDER_COLOR,
      },
      headerText: {
        fontSize: 14,
        fontWeight: 'bold',
        color: TEXT_COLOR,
      },
      itemRow: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: CARD_BG,
        paddingVertical: 12,
        paddingHorizontal: 16,
      },
      columnText: {
        fontSize: 14,
        color: TEXT_COLOR,
      },
      productNameCol: {
        flex: 3, // Takes up more space
        marginRight: 8,
      },
      stockCol: {
        flex: 1,
        textAlign: 'right', // Align stock number to the right
        marginRight: 8,
      },
      statusCol: {
        flex: 1.5, // Slightly wider for the badge
        alignItems: 'center', // Center the badge horizontally
      },
      statusColHeader: { // Style for the header text
        flex: 1.5,
        textAlign: 'center',
      },
      separator: {
        height: 1,
        backgroundColor: DETAIL_BORDER_COLOR,
        marginHorizontal: 16, // Indent separator slightly
      },
      // --- Status Badge ---
      statusBadge: {
        paddingHorizontal: 8,
        paddingVertical: 4,
        borderRadius: 12, // Make it pill-shaped
        minWidth: 70, // Ensure minimum width
        alignItems: 'center',
      },
      statusText: {
        color: '#FFFFFF', // White text
        fontSize: 12,
        fontWeight: 'bold',
      },

});


// --- ADDED: Specific styles for RNPickerSelect ---
const pickerSelectStyles = StyleSheet.create({
    inputIOS: {
        fontSize: 15,
        paddingVertical: 12,
        paddingHorizontal: 10,
        color: TEXT_COLOR,
        height: 44,
        paddingRight: 30, // to ensure the text is never behind the icon
    },
    inputAndroid: {
        fontSize: 15,
        paddingHorizontal: 10,
        paddingVertical: 11, // Adjust vertical padding for Android
        color: TEXT_COLOR,
        height: 44,
        paddingRight: 30, // to ensure the text is never behind the icon
    },
    placeholder: {
      color: LIGHT_TEXT_COLOR,
    },
    iconContainer: { // Required for custom icon positioning
        top: 0,
        bottom: 0,
        right: 12,
        justifyContent: 'center',
    },
});