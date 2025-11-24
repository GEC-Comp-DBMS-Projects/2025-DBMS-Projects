// import React, { useState } from 'react';
// import {
//     View,
//     Text,
//     TextInput,
//     TouchableOpacity,
//     StyleSheet,
//     ScrollView,
//     SafeAreaView,
//     Platform,
// } from 'react-native';
// import { Ionicons } from '@expo/vector-icons';
// import {router} from "expo-router"

// //import RNPickerSelect from 'react-native-picker-select';



// const PRIMARY_AMBER = '#FFBF00';
// const BACKGROUND_LIGHT = '#F7F7F7';
// const BORDER_COLOR = '#E0E0E0';
// const INPUT_BG = '#FFFFFF';


// const categories = [
//     'Accessories',
//     'Groceries',
//     'Electronics',
//     'Snacks',
//     'Beverages',
// ];

// export default function AddProductScreen() {
//     const [productName, setProductName] = useState('');
//     const [price, setPrice] = useState('');
//     const [stock, setStock] = useState('');
//     const [barcode, setBarcode] = useState('');
//     const [description, setDescription] = useState('A timeless accessory for the modern individual.');
//     const [aisleLocation, setAisleLocation] = useState('');
//     const [category, setCategory] = useState(categories[0]); 
//     const handleAddProduct = () => {
       
//         console.log('Adding Product:', { productName, price, stock, category });
//     };

//     const handleBack = () => {
//         router.back();
//         console.log('Go back');
//     };

//     const handleImageUpload = () => {
        
//         console.log('Tapping to upload image...');
//     };

    
//     const pickerItems = categories.map(cat => ({ label: cat, value: cat }));

//     return (
//         <SafeAreaView style={styles.safeArea}>
//             <View style={styles.header}>
//                 <TouchableOpacity onPress={handleBack} style={styles.backButton}>
//                     <Ionicons name="arrow-back" size={24} color="#000" />
//                 </TouchableOpacity>
//                 <Text style={styles.headerTitle}>Add Product</Text>
//                 <View style={styles.placeholder} />
//             </View>

//             <ScrollView contentContainerStyle={styles.scrollContent}>

                
//                 <View style={styles.inputGroup}>
//                     <Text style={styles.label}>Product Name</Text>
//                     <TextInput
//                         style={styles.input}
//                         onChangeText={setProductName}
//                         value={productName}
//                         placeholder="Enter product name"
//                     />
//                 </View>

               
//                 <View style={styles.row}>
//                     <View style={styles.halfInputGroup}>
//                         <Text style={styles.label}>Price</Text>
//                         <View style={styles.priceInputContainer}>
//                             <Text style={styles.priceCurrency}>Rs</Text>
//                             <TextInput
//                                 style={styles.priceInput}
//                                 onChangeText={setPrice}
//                                 value={price}
//                                 keyboardType="numeric"
//                                 placeholder="0"
//                             />
//                         </View>
//                     </View>

                    
//                     <View style={styles.halfInputGroup}>
//                         <Text style={styles.label}>Category</Text>
//                         <View style={styles.inputStyleWrapper}>
//                             {/* <RNPickerSelect
//                                 items={pickerItems}
//                                 onValueChange={(value) => setCategory(value)}
//                                 value={category}
                                
                                
                                
                               
                               
//                                 placeholder={{ label: 'Select Category', value: null }}
//                             /> */}
//                         </View>
//                     </View>
//                 </View>

                
//                 <View style={styles.row}>
//                     <View style={styles.halfInputGroup}>
//                         <Text style={styles.label}>Stock Quantity</Text>
//                         <TextInput
//                             style={styles.input}
//                             onChangeText={setStock}
//                             value={stock}
//                             keyboardType="numeric"
//                             placeholder="0"
//                         />
//                     </View>

//                     <View style={styles.halfInputGroup}>
//                         <Text style={styles.label}>Barcode</Text>
//                         <TextInput
//                             style={styles.input}
//                             onChangeText={setBarcode}
//                             value={barcode}
//                             placeholder=""
//                         />
//                     </View>
//                 </View>

                
//                 <View style={styles.inputGroup}>
//                     <Text style={styles.label}>Description (Optional)</Text>
//                     <TextInput
//                         style={[styles.input, styles.textArea]}
//                         onChangeText={setDescription}
//                         value={description}
//                         placeholder="Product description..."
//                         multiline={true}
//                     />
//                 </View>

                
//                 <View style={styles.inputGroup}>
//                     <Text style={styles.label}>Product Image</Text>
//                     <TouchableOpacity
//                         style={styles.uploadBox}
//                         onPress={handleImageUpload}
//                     >
//                         <Ionicons name="cloud-upload-outline" size={32} color="#999" />
//                         <Text style={styles.uploadTextTitle}>upload_file</Text>
//                         <Text style={styles.uploadTextSubtitle}>Tap to upload an image</Text>
//                     </TouchableOpacity>
//                 </View>

//                 {/* Aisle Location */}
//                 <View style={styles.inputGroup}>
//                     <Text style={styles.label}>Aisle Location</Text>
//                     <TextInput
//                         style={styles.input}
//                         onChangeText={setAisleLocation}
//                         value={aisleLocation}
//                         placeholder="Aisle A, Shelf 5"
//                     />
//                 </View>

//             </ScrollView>

            
//             <View style={styles.bottomButtonContainer}>
//                 <TouchableOpacity
//                     style={styles.addButton}
//                     onPress={handleAddProduct}
//                     disabled={!productName || !price || !stock}
//                 >
//                     <Text style={styles.addButtonText}>Add Product</Text>
//                 </TouchableOpacity>
//             </View>
//         </SafeAreaView>
//     );
// }


// const styles = StyleSheet.create({
//     safeArea: {
//         flex: 1,
//         backgroundColor: BACKGROUND_LIGHT,
//     },
//     header: {
//         flexDirection: 'row',
//         alignItems: 'center',
//         justifyContent: 'space-between',
//         paddingHorizontal: 16,
//         paddingVertical: Platform.OS === 'ios' ? 12 : 16,
//         backgroundColor: INPUT_BG,
//         borderBottomWidth: 1,
//         borderBottomColor: BORDER_COLOR,
//     },
//     backButton: {
//         width: 30,
//     },
//     headerTitle: {
//         fontSize: 18,
//         fontWeight: '700',
//         color: '#000',
//     },
//     placeholder: {
//         width: 30,
//     },
//     scrollContent: {
//         padding: 16,
//         paddingBottom: 100,
//     },
//     label: {
//         fontSize: 14,
//         fontWeight: '600',
//         color: '#000',
//         marginBottom: 6,
//     },
//     inputGroup: {
//         marginBottom: 20,
//     },
//     row: {
//         flexDirection: 'row',
//         justifyContent: 'space-between',
//         marginBottom: 20,
//     },
//     halfInputGroup: {
//         width: '48%',
//     },
  
//     input: {
//         backgroundColor: INPUT_BG, 
//         borderRadius: 8,
//         borderWidth: 1,
//         borderColor: BORDER_COLOR,
//         paddingHorizontal: 16,
//         paddingVertical: 12,
//         fontSize: 16,
//         color: '#333',
//         shadowColor: "#000",
//         shadowOffset: { width: 0, height: 4 },
//         shadowOpacity: 0.15,
//         shadowRadius: 4,
//         elevation: 4,
//     },
//     priceInputContainer: {
//         flexDirection: 'row',
//         alignItems: 'center',
//         backgroundColor: INPUT_BG,
//         borderRadius: 8,
//         borderWidth: 1,
//         borderColor: BORDER_COLOR,
//         paddingHorizontal: 12,
//         shadowColor: "#000",
//         shadowOffset: { width: 0, height: 4 },
//         shadowOpacity: 0.15,
//         shadowRadius: 4,
//         elevation: 4,
//     },
//     priceCurrency: {
//         fontSize: 16,
//         color: '#666',
//         marginRight: 4,
//     },
//     priceInput: {
//         flex: 1,
//         paddingVertical: 12,
//         fontSize: 16,
//         color: '#333',
//     },

    
//     inputStyleWrapper: {
//         backgroundColor: INPUT_BG,
//         borderRadius: 8,
//         borderWidth: 1,
//         borderColor: BORDER_COLOR,
//         height: 48,
//         justifyContent: 'center',
        
        
//         shadowColor: "#000",
//         shadowOffset: { width: 0, height: 4 },
//         shadowOpacity: 0.15,
//         shadowRadius: 4,
//         elevation: 4,
//     },
    
  

//     textArea: {
//         minHeight: 100,
//         textAlignVertical: 'top',
//     },
//     uploadBox: {
//         backgroundColor: INPUT_BG,
//         borderRadius: 8,
//         borderWidth: 2,
//         borderColor: BORDER_COLOR,
//         borderStyle: 'dashed',
//         alignItems: 'center',
//         justifyContent: 'center',
//         paddingVertical: 40,
//     },
//     uploadTextTitle: {
//         fontSize: 14,
//         fontWeight: '600',
//         color: '#333',
//         marginTop: 8,
//     },
//     uploadTextSubtitle: {
//         fontSize: 12,
//         color: '#999',
//     },
//     bottomButtonContainer: {
//         position: 'absolute',
//         bottom: 0,
//         left: 0,
//         right: 0,
//         padding: 16,
//         backgroundColor: INPUT_BG,
//         borderTopWidth: 1,
//         borderTopColor: BORDER_COLOR,
//     },
//     addButton: {
//         backgroundColor: PRIMARY_AMBER,
//         borderRadius: 8,
//         paddingVertical: 14,
//         alignItems: 'center',
//         shadowColor: '#000',
//         shadowOffset: { width: 0, height: 2 },
//         shadowOpacity: 0.2,
//         shadowRadius: 3,
//         elevation: 4,
//     },
//     addButtonText: {
//         fontSize: 18,
//         fontWeight: 'bold',
//         color: '#000',
//     },
// });


import React, { useState } from 'react';
import {
    View,
    Text,
    TextInput,
    TouchableOpacity,
    StyleSheet,
    ScrollView,
    SafeAreaView,
    Platform,
    Image,
    ActivityIndicator,
    Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { router, useLocalSearchParams } from "expo-router";
import * as ImagePicker from 'expo-image-picker';
import RNPickerSelect from 'react-native-picker-select';
import { db } from '@/firebase'; // Import your Firestore instance
import { doc, collection, addDoc, serverTimestamp } from 'firebase/firestore';
import { useAdminContext } from '../context/adminContext';

// --- Constants ---
const PRIMARY_AMBER = '#FFBF00';
const BACKGROUND_LIGHT = '#F7F7F7';
const BORDER_COLOR = '#E0E0E0';
const INPUT_BG = '#FFFFFF';
const BACKEND_UPLOAD_URL = 'https://kasse-backend.onrender.com/upload'; // Your backend

const categories = [
    { label: 'Accessories', value: 'Accessories' },
    { label: 'Groceries', value: 'Groceries' },
    { label: 'Electronics', value: 'Electronics' },
    { label: 'Snacks', value: 'Snacks' },
    { label: 'Beverages', value: 'Beverages' },
];

export default function AddProductScreen() {
    const [productName, setProductName] = useState('');
    const [price, setPrice] = useState('');
    const [stock, setStock] = useState('');
    const [barcode, setBarcode] = useState('');
    const [description, setDescription] = useState('A timeless accessory for the modern individual.');
    const [aisleLocation, setAisleLocation] = useState('');
    const [category, setCategory] = useState(categories[0].value);
    
    // This will now store the base64 data URI (e.g., "data:image/jpeg;base64,...")
    const [image, setImage] = useState<string | null>(null); 
    const [isUploading, setIsUploading] = useState(false);

    const { supermarketId } = useLocalSearchParams();
   console.log("From add product sid = ",supermarketId);

    const handleBack = () => {
        router.back();
    };

    // --- Updated Image Picker Function (to get base64) ---
    const handleImageUpload = async () => {
        // const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
        // if (status !== 'granted') {
        //     Alert.alert('Permission Denied', 'Sorry, we need camera roll permissions to upload images.');
        //     return;
        // }

        // let result = await ImagePicker.launchImageLibraryAsync({
        //     mediaTypes: ImagePicker.MediaTypeOptions.Images,
        //     allowsEditing: true,
        //     aspect: [1, 1],
        //     quality: 0.7, // Keep quality low to reduce base64 string size
        //     base64: true, // Request base64 data
        // });


        let result = await ImagePicker.launchImageLibraryAsync({
                mediaTypes: ['images'],
                allowsEditing: true,
                aspect: [1, 1],
                quality: 0.7,
                base64:true,
              });



        if (!result.canceled && result.assets && result.assets[0].base64) {
            const asset = result.assets[0];
            // Create the full data URI
            const mimeType = asset.mimeType || 'image/jpeg';
            const dataUri = `data:${mimeType};base64,${asset.base64}`;
            setImage(dataUri);
        }
    };

    // --- Updated Add Product Function (to use your backend) ---
    const handleAddProduct = async () => {
        if (!productName || !price || !stock || !category || !image || !supermarketId) {
            Alert.alert('Missing Fields', 'Please fill in all fields and add an image.');
            return;
        }

        setIsUploading(true);

        try {
            // 1. Upload Image to your backend
            console.log("Uploading image to backend...");
            const uploadResponse = await fetch(BACKEND_UPLOAD_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    image: image, // Send the base64 data URI
                }),
            });

            const uploadData = await uploadResponse.json();
            let finalImageUrl = null;

            if (uploadResponse.ok && uploadData.imageURL) {
                finalImageUrl = uploadData.imageURL;
                console.log("Image uploaded successfully:", finalImageUrl);
            } else {
                console.error("Backend image upload failed:", uploadData);
                throw new Error(uploadData.error || 'Backend image upload failed');
            }

            // 2. Get reference to the 'products' subcollection
            const storeDocRef = doc(db, 'supermarket', supermarketId as string);
            const productsCollectionRef = collection(storeDocRef, 'products');

            // 3. Prepare product data
            const productData = {
                productName,
                price: parseFloat(price),
                stockQuantity: parseInt(stock, 10),
                barcode,
                description,
                aisleLocation,
                category,
                productImgUrl: finalImageUrl, // Use the URL from your backend
                createdAt: new Date(),
            };

            // 4. Add new document to Firestore
            await addDoc(productsCollectionRef, productData);

            Alert.alert('Success', 'Product added successfully!');
            router.back();

        } catch (error) {
            console.error('Error adding product:', error);
            Alert.alert('Error', `Failed to add product. ${error instanceof Error ? error.message : ''}`);
        } finally {
            setIsUploading(false);
        }
    };

    return (
        <SafeAreaView style={styles.safeArea}>
            <View style={styles.header}>
                <TouchableOpacity onPress={handleBack} style={styles.backButton}>
                    <Ionicons name="arrow-back" size={24} color="#000" />
                </TouchableOpacity>
                <Text style={styles.headerTitle}>Add Product</Text>
                <View style={styles.placeholder} />
            </View>

            <ScrollView contentContainerStyle={styles.scrollContent}>
                
                {/* Product Name */}
                <View style={styles.inputGroup}>
                    <Text style={styles.label}>Product Name</Text>
                    <TextInput
                        style={styles.input}
                        onChangeText={setProductName}
                        value={productName}
                        placeholder="Enter product name"
                    />
                </View>

                {/* Price and Category Row */}
                <View style={styles.row}>
                    <View style={styles.halfInputGroup}>
                        <Text style={styles.label}>Price</Text>
                        <View style={styles.priceInputContainer}>
                            <Text style={styles.priceCurrency}>Rs</Text>
                            <TextInput
                                style={styles.priceInput}
                                onChangeText={setPrice}
                                value={price}
                                keyboardType="numeric"
                                placeholder="0"
                            />
                        </View>
                    </View>

                    {/* Category Picker */}
                    <View style={styles.halfInputGroup}>
                        <Text style={styles.label}>Category</Text>
                        <View style={styles.inputStyleWrapper}>
                            <RNPickerSelect
                                items={categories}
                                onValueChange={(value) => setCategory(value)}
                                value={category}
                                style={pickerSelectStyles}
                                placeholder={{}}
                                useNativeAndroidPickerStyle={false}
                                Icon={() => (
                                    <Ionicons name="chevron-down" size={20} color="#666" style={styles.pickerIcon} />
                                )}
                            />
                        </View>
                    </View>
                </View>

                {/* Stock and Barcode Row */}
                <View style={styles.row}>
                    <View style={styles.halfInputGroup}>
                        <Text style={styles.label}>Stock Quantity</Text>
                        <TextInput
                            style={styles.input}
                            onChangeText={setStock}
                            value={stock}
                            keyboardType="numeric"
                            placeholder="0"
                        />
                    </View>

                    <View style={styles.halfInputGroup}>
                        <Text style={styles.label}>Barcode (Optional)</Text>
                        <TextInput
                            style={styles.input}
                            onChangeText={setBarcode}
                            value={barcode}
                            placeholder="Scan or enter code"
                        />
                    </View>
                </View>

                {/* Description */}
                <View style={styles.inputGroup}>
                    <Text style={styles.label}>Description (Optional)</Text>
                    <TextInput
                        style={[styles.input, styles.textArea]}
                        onChangeText={setDescription}
                        value={description}
                        placeholder="Product description..."
                        multiline={true}
                    />
                </View>

                {/* Image Upload */}
                <View style={styles.inputGroup}>
                    <Text style={styles.label}>Product Image</Text>
                    <TouchableOpacity
                        style={styles.uploadBox}
                        onPress={handleImageUpload}
                    >
                        {/* The base64 data URI works directly in the Image source */}
                        {image ? (
                            <Image source={{ uri: image }} style={styles.previewImage} />
                        ) : (
                            <>
                                <Ionicons name="cloud-upload-outline" size={32} color="#999" />
                                <Text style={styles.uploadTextTitle}>Tap to upload image</Text>
                                <Text style={styles.uploadTextSubtitle}>1:1 ratio recommended</Text>
                            </>
                        )}
                    </TouchableOpacity>
                </View>

                {/* Aisle Location */}
                <View style={styles.inputGroup}>
                    <Text style={styles.label}>Aisle Location (Optional)</Text>
                    <TextInput
                        style={styles.input}
                        onChangeText={setAisleLocation}
                        value={aisleLocation}
                        placeholder="Aisle A, Shelf 5"
                    />
                </View>

            </ScrollView>

            {/* Bottom Button */}
            <View style={styles.bottomButtonContainer}>
                <TouchableOpacity
                    style={[styles.addButton, (isUploading || !productName || !price || !stock || !image) && styles.addButtonDisabled]}
                    onPress={handleAddProduct}
                    disabled={isUploading || !productName || !price || !stock || !image}
                >
                    {isUploading ? (
                        <ActivityIndicator size="small" color="#000" />
                    ) : (
                        <Text style={styles.addButtonText}>Add Product</Text>
                    )}
                </TouchableOpacity>
            </View>
        </SafeAreaView>
    );
}

// --- Styles ---

const styles = StyleSheet.create({
    safeArea: {
        flex: 1,
        backgroundColor: BACKGROUND_LIGHT,
    },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 16,
        paddingVertical: Platform.OS === 'ios' ? 12 : 16,
        backgroundColor: INPUT_BG,
        borderBottomWidth: 1,
        borderBottomColor: BORDER_COLOR,
    },
    backButton: {
        width: 30,
    },
    headerTitle: {
        fontSize: 18,
        fontWeight: '700',
        color: '#000',
    },
    placeholder: {
        width: 30,
    },
    scrollContent: {
        padding: 16,
        paddingBottom: 100,
    },
    label: {
        fontSize: 14,
        fontWeight: '600',
        color: '#000',
        marginBottom: 6,
    },
    inputGroup: {
        marginBottom: 20,
    },
    row: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 20,
    },
    halfInputGroup: {
        width: '48%',
    },
    input: {
        backgroundColor: INPUT_BG,
        borderRadius: 8,
        borderWidth: 1,
        borderColor: BORDER_COLOR,
        paddingHorizontal: 16,
        paddingVertical: 12,
        fontSize: 16,
        color: '#333',
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.1,
        shadowRadius: 2,
        elevation: 2,
    },
    priceInputContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: INPUT_BG,
        borderRadius: 8,
        borderWidth: 1,
        borderColor: BORDER_COLOR,
        paddingHorizontal: 12,
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.1,
        shadowRadius: 2,
        elevation: 2,
    },
    priceCurrency: {
        fontSize: 16,
        color: '#666',
        marginRight: 4,
    },
    priceInput: {
        flex: 1,
        paddingVertical: 12,
        fontSize: 16,
        color: '#333',
    },
    inputStyleWrapper: {
        backgroundColor: INPUT_BG,
        borderRadius: 8,
        borderWidth: 1,
        borderColor: BORDER_COLOR,
        height: 48, // Match input height
        justifyContent: 'center',
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.1,
        shadowRadius: 2,
        elevation: 2,
    },
    pickerIcon: {
        position: 'absolute',
        right: 12,
        top: Platform.OS === 'ios' ? 14 : 14,
    },
    textArea: {
        minHeight: 100,
        textAlignVertical: 'top',
    },
    uploadBox: {
        backgroundColor: INPUT_BG,
        borderRadius: 8,
        borderWidth: 2,
        borderColor: BORDER_COLOR,
        borderStyle: 'dashed',
        alignItems: 'center',
        justifyContent: 'center',
        paddingVertical: 40,
        overflow: 'hidden',
    },
    uploadTextTitle: {
        fontSize: 14,
        fontWeight: '600',
        color: '#333',
        marginTop: 8,
    },
    uploadTextSubtitle: {
        fontSize: 12,
        color: '#999',
    },
    previewImage: {
        width: '100%',
        height: 200, 
        resizeMode: 'cover',
    },
    bottomButtonContainer: {
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        padding: 16,
        paddingBottom: Platform.OS === 'ios' ? 32 : 16,
        backgroundColor: INPUT_BG,
        borderTopWidth: 1,
        borderTopColor: BORDER_COLOR,
    },
    addButton: {
        backgroundColor: PRIMARY_AMBER,
        borderRadius: 8,
        paddingVertical: 14,
        alignItems: 'center',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.2,
        shadowRadius: 3,
        elevation: 4,
    },
    addButtonDisabled: {
        backgroundColor: '#E0E0E0',
        opacity: 0.7,
    },
    addButtonText: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#000',
    },
});

// Specific styles for RNPickerSelect
const pickerSelectStyles = StyleSheet.create({
    inputIOS: {
        fontSize: 16,
        paddingVertical: 12,
        paddingHorizontal: 16,
        color: '#333',
        height: 48,
    },
    inputAndroid: {
        fontSize: 16,
        paddingHorizontal: 16,
        paddingVertical: 12,
        color: '#333',
        height: 48,
    },
});