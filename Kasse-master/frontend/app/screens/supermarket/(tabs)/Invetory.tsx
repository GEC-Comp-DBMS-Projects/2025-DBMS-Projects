// 



import React, { useEffect, useState, useMemo } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Platform,
  Image,
  Alert,
  FlatList,
  ScrollView, // --- Added ScrollView for the details
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useAdminContext } from '../context/adminContext';
import { collection, doc, onSnapshot,deleteDoc } from 'firebase/firestore';
import { db } from '@/firebase';

// --- Constants (same as yours) ---
const PRIMARY_AMBER = '#FFBF00';
const CARD_BG = '#FFFFFF';
const LIGHT_BG = '#F7F7F7';
const DETAIL_BORDER_COLOR = '#E0E0E0';
const TEXT_COLOR = '#333';
const LIGHT_TEXT_COLOR = '#666';

// --- New ---
// Calculate the height for 3 items
const ITEM_HEIGHT = 65; // (60 for image + 24 for padding)
const SEPARATOR_HEIGHT = 5;
const LIST_HEIGHT = (ITEM_HEIGHT * 3) + (SEPARATOR_HEIGHT * 2); // 252 + 24 = 276

// Define a type for our product for better state management
type Product = {
  id: string;
  productName: string;
  stockQuantity: number;
  productImgUrl: string;
  price: number;
  category: string;
  aisleLocation: string;
  barcode: string;
};

export default function InventoryScreen() {
  const router = useRouter();
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [searchText, setSearchText] = useState('');
  const { AdminProfileData } = useAdminContext();
  const [productList, setProductList] = useState<Product[]>([]);

  // --- Real-time data fetching (no changes) ---
  useEffect(() => {
    if (!AdminProfileData?.supermarketId) {
      return;
    }
    const localStoreRef = doc(db, 'supermarket', AdminProfileData.supermarketId);
    const localProductRef = collection(localStoreRef, "products");

    const unsubscribe = onSnapshot(localProductRef, (snapshot) => {
      let dataList: Product[] = [];
      snapshot.forEach((doc) => {
        const data = doc.data();
        dataList.push({
          id: doc.id,
          ...data,
          productName: data.productName || 'No Name',
          stockQuantity: data.stockQuantity || 0,
          productImgUrl: data.productImgUrl || 'https://placehold.co/100x100',
          price: data.price || 0,
          category: data.category || 'N/A',
          aisleLocation: data.aisleLocation || 'N/A',
          barcode: data.barcode || 'N/A',
        } as Product);
      });

      setProductList(dataList);
      
      if (dataList.length > 0) {
        const currentSelectedId = selectedProduct?.id;
        const newSelected = dataList.find(p => p.id === currentSelectedId);
        setSelectedProduct(newSelected || dataList[0]);
      } else {
        setSelectedProduct(null);
      }
    });

    return () => {
      unsubscribe();
    };
  }, [AdminProfileData]);

  // --- Filtered list for search (no changes) ---
  const filteredProductList = useMemo(() => {
    if (!searchText) {
      return productList;
    }
    return productList.filter(product =>
      product.productName.toLowerCase().includes(searchText.toLowerCase())
    );
  }, [productList, searchText]);

  const handleProductSelect = (product: Product) => {
    setSelectedProduct(product);
  };

  const handleAddProduct = () => {
    if (AdminProfileData && AdminProfileData.supermarketId) {
      router.push({
        pathname: "/screens/supermarket/products/AddProducts",
        params: { supermarketId: AdminProfileData.supermarketId }
      });
    } else {
      console.log("No supermarket ID found");
    }
  };

  const handleEdit=()=>{
    router.navigate({
      pathname:'/screens/supermarket/products/EditProduct',
      params:{
        supermarketId: AdminProfileData?.supermarketId,
        productId: selectedProduct?.id // <-- Pass the product's ID
      }
    });
  }

  // --- This is the new, platform-aware function ---
  const handleDeleteProduct = () => {
    // 1. Check if a product is actually selected
    if (!selectedProduct || !AdminProfileData?.supermarketId) {
      Alert.alert("Error", "No product selected or missing store data.");
      return;
    }

    // Store product details to avoid state issues in callbacks
    const productToDelete = selectedProduct;
    const supermarketId = AdminProfileData.supermarketId;

    // 2. This is the actual deletion logic
    const performDelete = async () => {
      try {
        const productDocRef = doc(db, 'supermarket', supermarketId, 'products', productToDelete.id);
        await deleteDoc(productDocRef);
        // onSnapshot will auto-update the list
      } catch (error) {
        console.error("Error deleting product: ", error);
        Alert.alert("Error", "Failed to delete the product. Please try again.");
      }
    };

    // 3. Show the correct confirmation based on the platform
    if (Platform.OS === 'web') {
      // Use browser's window.confirm
      const confirmed = window.confirm(
        `Are you sure you want to delete "${productToDelete.productName}"? This action cannot be undone.`
      );
      if (confirmed) {
        performDelete();
      } else {
        console.log("Delete canceled");
      }
    } else {
      // Use native Alert.alert
      Alert.alert(
        "Delete Product?",
        `Are you sure you want to delete "${productToDelete.productName}"? This action cannot be undone.`,
        [
          {
            text: "Cancel",
            onPress: () => console.log("Delete canceled"),
            style: "cancel"
          },
          {
            text: "Delete",
            onPress: performDelete, // Call the deletion logic
            style: "destructive"
          }
        ]
      );
    }
  };

  // --- Helper to render details (no changes) ---
  const renderDetailRow = (label: string, value: string | number) => (
    <View style={styles.detailRow}>
      <Text style={styles.detailLabel}>{label} :</Text>
      <Text style={styles.detailValue}>{value}</Text>
    </View>
  );

  // --- Renders each item in the FlatList (no changes) ---
  const renderProductItem = ({ item }: { item: Product }) => (
    <TouchableOpacity
      style={[
        styles.productCard,
        selectedProduct?.id === item.id && styles.selectedCard,
      ]}
      onPress={() => handleProductSelect(item)}
    >
      <Image source={{ uri: item.productImgUrl }} style={styles.productImage} />
      <View style={styles.productInfo}>
        <Text style={styles.productName} numberOfLines={2}>{item.productName}</Text>
        <Text style={styles.productQty}>QTY : {item.stockQuantity}</Text>
      </View>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      {/* --- Header --- */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Inventory</Text>
        <TouchableOpacity style={styles.headerButton}>
          <Icon name="account-circle" size={30} color={PRIMARY_AMBER} />
        </TouchableOpacity>
      </View>

      {/* --- Search Bar --- */}
      <View style={styles.searchContainer}>
        <Ionicons name="search" size={20} color={LIGHT_TEXT_COLOR} style={styles.searchIcon} />
        <TextInput
          style={styles.searchInput}
          placeholder="Search products..."
          value={searchText}
          onChangeText={setSearchText}
        />
      </View>

      {/* --- Products List Header --- */}
      <View style={styles.listHeader}>
        <Text style={styles.listTitle}>Products List</Text>
        <TouchableOpacity
          style={styles.addProductButton}
          onPress={handleAddProduct}
        >
          <Ionicons name="add" size={18} color={CARD_BG} />
          <Text style={styles.addProductText}>Add Product</Text>
        </TouchableOpacity>
      </View>

      {/* --- Scrollable Product List (Fixed Height) --- */}
      <View style={styles.listContainer}>
        <FlatList
          data={filteredProductList}
          renderItem={renderProductItem}
          keyExtractor={(item) => item.id}
          ItemSeparatorComponent={() => <View style={{ height: SEPARATOR_HEIGHT }} />}
        />
      </View>
      
      {/* --- Details Section (in its own ScrollView) --- */}
      <ScrollView style={styles.detailsScroll}>
        <View style={styles.detailsContent}>
          <Text style={styles.listTitle}>Products Details</Text>
          
          {selectedProduct ? (
            <View style={styles.detailsBox}>
              <View style={styles.detailsTable}>
                {renderDetailRow('Selected Product', selectedProduct.productName)}
                {renderDetailRow('Price', `${selectedProduct.price} Rs`)}
                {renderDetailRow('Stock', selectedProduct.stockQuantity)}
                {renderDetailRow('Category', selectedProduct.category)}
                {renderDetailRow('Aisle location', selectedProduct.aisleLocation)}
                {renderDetailRow('Barcode', selectedProduct.barcode)}
              </View>

              {/* Edit/Delete Buttons */}
              <View style={styles.detailActions}>
                <TouchableOpacity
                  style={[styles.actionButton, styles.editButton]}
                  onPress={handleEdit}
                >
                  <Ionicons name="create-outline" size={20} color="#000" />
                  <Text style={styles.actionButtonText}>Edit</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={[styles.actionButton, styles.deleteButton]}
                  onPress={handleDeleteProduct}
                >
                  <Ionicons name="trash-outline" size={20} color="#DC2626" />
                  <Text style={[styles.actionButtonText, { color: '#DC2626' }]}>Delete</Text>
                </TouchableOpacity>
              </View>
            </View>
          ) : (
            <View style={styles.detailsBox}>
              <Text style={styles.detailValue}>Select a product to see details</Text>
            </View>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

// --- Stylesheet ---
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: LIGHT_BG,
  },
  // --- Header ---
  header: {
    marginTop: 23,
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
  // --- Search ---
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: CARD_BG,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: DETAIL_BORDER_COLOR,
    paddingHorizontal: 10,
    marginTop: 10, // Added margin
    marginBottom: 10, // Added margin
    marginHorizontal: 16, // Added margin
    ...Platform.select({
      ios: { shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.1, shadowRadius: 2 },
      android: { elevation: 2 },
    }),
  },
  searchIcon: {
    marginRight: 8,
  },
  searchInput: {
    flex: 1,
    paddingVertical: 10,
    fontSize: 16,
    color: TEXT_COLOR,
  },
  // --- List Header ---
  listHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
    paddingHorizontal: 16, // Added padding
  },
  listTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: TEXT_COLOR,
  },
  addProductButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#000',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
  },
  addProductText: {
    color: CARD_BG,
    fontWeight: '600',
    fontSize: 14,
    marginLeft: 4,
  },
  // --- Product List Container ---
  listContainer: {
    height: LIST_HEIGHT, // <-- Fixed height
    paddingHorizontal: 16, // Padding for the list
  },
  // --- Product Cards ---
  productCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: CARD_BG,
    borderRadius: 10,
    padding: 12,
    borderWidth: 1,
    borderColor: DETAIL_BORDER_COLOR,
    height: ITEM_HEIGHT, // <-- Fixed height for calculation
  },
  selectedCard: {
    borderColor: PRIMARY_AMBER,
    borderWidth: 2,
  },
  productImage: {
    width: 60,
    height: 60,
    borderRadius: 6,
    marginRight: 12,
    resizeMode: 'cover',
  },
  productInfo: {
    flex: 1,
    justifyContent: 'center',
  },
  productName: {
    fontSize: 15,
    fontWeight: '600',
    color: TEXT_COLOR,
  },
  productQty: {
    fontSize: 14,
    color: LIGHT_TEXT_COLOR,
    marginTop: 2,
  },
  // --- Details Section ---
  detailsScroll: {
    flex: 1, // Takes up remaining space
  },
  detailsContent: {
    padding: 16, // Padding for details content
    paddingBottom: 100, // Space for nav bar
  },
  detailsBox: {
    backgroundColor: CARD_BG,
    borderRadius: 10,
    padding: 16,
    borderWidth: 1,
    borderColor: DETAIL_BORDER_COLOR,
    marginTop: 3,
  },
  detailsTable: {
    borderWidth: 1,
    borderColor: DETAIL_BORDER_COLOR,
    borderRadius: 8,
    marginBottom: 10,
  },
  detailRow: {
    flexDirection: 'row',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderBottomWidth: 1,
    borderBottomColor: DETAIL_BORDER_COLOR,
  },
  detailLabel: {
    fontSize: 14,
    fontWeight: '500',
    color: LIGHT_TEXT_COLOR,
    width: 120,
  },
  detailValue: {
    flex: 1,
    fontSize: 14,
    fontWeight: '600',
    color: TEXT_COLOR,
  },
  detailActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 10,
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 10,
    borderRadius: 8,
    borderWidth: 1,
    width: '48%',
  },
  editButton: {
    borderColor: '#000',
    backgroundColor: CARD_BG,
  },
  deleteButton: {
    borderColor: '#DC2626',
    backgroundColor: CARD_BG,
  },
  actionButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000',
    marginLeft: 6,
  },
});