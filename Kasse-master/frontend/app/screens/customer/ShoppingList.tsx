

import React, { useState, useEffect } from "react"; // Added useEffect
import {
  
  View,
  Text,
  TextInput,
  TouchableOpacity,
  FlatList,
  StyleSheet,
  ActivityIndicator, // Added
} from "react-native";
import Fuse from "fuse.js";
import { collectionGroup, getDocs,collection} from 'firebase/firestore'; // Import Firestore functions
import {db} from '../../../firebase'

type SearchableProduct = {
  id: string;
  name: string;
  supermarkets: string[];
};

// Define the structure for items in the actual shopping list
type ShoppingListItem = {
  name: string;
  supermarkets: string[]; // Can be empty if added manually
};


export default function ShoppingListScreen() {
  const [item, setItem] = useState<string>(""); // Input text is still a string
  const [list, setList] = useState<ShoppingListItem[]>([]); // List now holds ShoppingListItem objects
  const [results, setResults] = useState<SearchableProduct[]>([]); // Results are SearchableProduct objects
  const [fuseInstance, setFuseInstance] = useState<Fuse<SearchableProduct> | null>(null); // Type Fuse instance
  const [isLoading, setIsLoading] = useState(true);


  useEffect(() => {
    const fetchData = async () => {
      setIsLoading(true);
      const tempProductMap : any = {}; // Temporary map { productName: [supermarketName1, ...] }
      const supermarketNames : any= {}; // Temporary map { supermarketId: supermarketName }

      try {
        // 1. Fetch all supermarket names first (optional, but good for display)
        // Adjust 'supermarket' if your collection name is different
        const smSnapshot = await getDocs(collection(db, 'supermarket'));
        smSnapshot.forEach(doc => {
            supermarketNames[doc.id] = doc.data().sname || 'Unknown Supermarket';
        });

        // 2. Fetch all products using collectionGroup
        const productsSnapshot = await getDocs(collectionGroup(db, 'products'));

        productsSnapshot.forEach(productDoc => {
          const productData = productDoc.data();
          const productName = productData.productName;

          // Get supermarket ID from the product's path
          // Path is like: supermarket/{smId}/products/{prodId}
          const pathSegments = productDoc.ref.path.split('/');
          const supermarketId = pathSegments[1]; // The second segment is the supermarket ID
          const supermarketName = supermarketNames[supermarketId] || 'Unknown Supermarket';

          if (productName && supermarketName) {
            if (!tempProductMap[productName]) {
              tempProductMap[productName] = [];
            }
            // Avoid adding duplicate supermarket names for the same product
            if (!tempProductMap[productName].includes(supermarketName)) {
               tempProductMap[productName].push(supermarketName);
            }
          }
        });

        // 3. Prepare data for Fuse.js
        const searchableProducts = Object.keys(tempProductMap).map((name, i) => ({
          id: i.toString(), // Simple ID for Fuse results
          name,
          supermarkets: tempProductMap[name],
        }));

        // 4. Initialize Fuse.js
        const fuse = new Fuse(searchableProducts, {
          keys: ["name"],
          threshold: 0.4,
        });
        setFuseInstance(fuse); // Store the Fuse instance in state

      } catch (error) {
        console.error("Error fetching data from Firestore:", error);
        // Handle error (e.g., show an error message)
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []); // Run only once on mount


const handleInput = (text: string) => {
    setItem(text);
    if (fuseInstance && text.trim().length > 0) {
      // Fuse search results are { item: SearchableProduct, refIndex: number, score: number }
      const found = fuseInstance.search(text).map(res => res.item); // Extract the 'item'
      setResults(found.slice(0, 5));
    } else {
      setResults([]);
    }
  };

 

  const addItem = (productData: SearchableProduct | string) => {
    let newItem: ShoppingListItem;

    if (typeof productData === 'string') {
      // Manual add - create item with empty supermarkets array
      const text = productData.trim();
      if (text.length === 0) return; // Don't add empty strings
      
      // Prevent adding duplicates
      if (list.some(listItem => listItem.name.toLowerCase() === text.toLowerCase())) {
         console.log(`${text} is already in the list.`);
         return; 
      }
      
      newItem = { name: text, supermarkets: [] }; // No supermarket info known
    } else {
      // Add from suggestion - use data from the suggestion object
      
      // Prevent adding duplicates
       if (list.some(listItem => listItem.name.toLowerCase() === productData.name.toLowerCase())) {
         console.log(`${productData.name} is already in the list.`);
         setItem(""); // Clear input even if duplicate
         setResults([]);
         return; 
      }
      
      newItem = { name: productData.name, supermarkets: productData.supermarkets };
    }

    setList((prevList) => [...prevList, newItem]);
    setItem(""); // Clear input
    setResults([]); // Clear suggestions
  };

  const removeItem = (index:any) => {
    setList((prev:any) => prev.filter((_:any, idx:any) => idx !== index));
  };

  const renderItem = ({ item: product, index }: { item: ShoppingListItem, index: number }) => (
    <View style={styles.listItem}>
      <View style={styles.itemDetails}>
         {/* Display Product Name */}
         <Text style={styles.itemText}>{product.name}</Text>
         {/* Display Supermarkets if available */}
         {product.supermarkets.length > 0 && (
           <Text style={styles.supermarketText}>
             Available at: {product.supermarkets.join(", ")}
           </Text>
         )}
      </View>
      <TouchableOpacity
        style={styles.removeBtn}
        onPress={() => removeItem(index)}
      >
        <Text style={styles.btnText}>Remove</Text>
      </TouchableOpacity>
    </View>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.title}>🛒 Shopping List</Text>
      {/* --- Show Loading Indicator --- */}
      {isLoading ? (
        <ActivityIndicator size="large" color="#4CAF50" style={{ marginTop: 20 }}/>
      ) :(
      <>
      <View style={styles.inputRow}>
        <TextInput
          style={styles.input}
          placeholder="Add item..."
          value={item}
          onChangeText={handleInput}
        />
        <TouchableOpacity style={styles.addBtn} onPress={() => addItem(item)}>
          <Text style={styles.btnText}>Add</Text>
        </TouchableOpacity>
      </View>

      
      {/* // Suggestions */}
            {results.length > 0 && (
              <View style={styles.suggestionBox}>
                {results.map((prod) => ( // prod is a SearchableProduct
                  <TouchableOpacity
                    key={prod.id}
                    style={styles.suggestion}
                    onPress={() => addItem(prod)} // <-- Pass the whole object
                  >
                    <Text>
                      {prod.name} {" - "}
                      <Text style={{ fontStyle: "italic", color: "#555" }}>
                        {prod.supermarkets.join(", ")}
                      </Text>
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>
            )}

      {/* Shopping list */}
      <FlatList
        data={list}
        keyExtractor={(_, idx) => idx.toString()}
        renderItem={renderItem}
        style={styles.list}
      />
      </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 24, backgroundColor: "#fff" },
  title: { fontSize: 32, fontWeight: "bold", alignSelf: "center", marginVertical: 24 },
  inputRow: { flexDirection: "row", alignItems: "center", marginBottom: 10 },
  input: { flex: 1, borderWidth: 1, borderRadius: 6, borderColor: "#ccc", padding: 10, fontSize: 18, marginRight: 8 },
  addBtn: { backgroundColor: "#4CAF50", paddingHorizontal: 18, paddingVertical: 10, borderRadius: 6 },
  removeBtn: { backgroundColor: "#e74c3c", paddingHorizontal: 15, paddingVertical: 7, borderRadius: 6, marginLeft: 8 },
  btnText: { color: "#fff", fontWeight: "bold" },
  list: { marginTop: 10 },
  suggestionBox: {
    backgroundColor: "#eee",
    marginBottom: 10,
    borderRadius: 6,
    paddingHorizontal: 10,
    paddingVertical: 6,
  },
  suggestion: {
    paddingVertical: 6,
    borderBottomWidth: 1,
    borderColor: "#ddd",
  },
  listItem: {
    flexDirection: "row",
    alignItems: "center", // Align items vertically in the center
    backgroundColor: "#f9f9f9",
    padding: 12,
    marginBottom: 8,
    borderRadius: 6,
    justifyContent: "space-between",
  },
  itemDetails: { // --- ADDED: Container for text ---
    flex: 1, // Allow text to take available space
    marginRight: 8, // Space before remove button
  },
  itemText: {
    fontSize: 18,
    color: '#333', // Darker text color
  },
  supermarketText: { // --- ADDED: Style for supermarket list ---
    fontSize: 12,
    color: "#555",
    fontStyle: "italic",
    marginTop: 2,
  },

});
