import React, { useState, useEffect } from 'react'; // Added useEffect
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
import { doc, getDoc, updateDoc, serverTimestamp } from 'firebase/firestore'; // Import getDoc and updateDoc

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

export default function EditProductScreen() {
    // --- Form State ---
    const [productName, setProductName] = useState('');
    const [price, setPrice] = useState('');
    const [stock, setStock] = useState('');
    const [barcode, setBarcode] = useState('');
    const [description, setDescription] = useState('');
    const [aisleLocation, setAisleLocation] = useState('');
    const [category, setCategory] = useState(categories[0].value);
    
    // --- Image State ---
    const [newImage, setNewImage] = useState<string>(""); // New base64 image
    const [currentImageUrl, setCurrentImageUrl] = useState<string>(""); // Existing URL from DB

    // --- Loading State ---
    const [isLoading, setIsLoading] = useState(true); // For initial fetch
    const [isUpdating, setIsUpdating] = useState(false); // For update button

    // --- Get IDs from navigation ---
    const { supermarketId, productId } = useLocalSearchParams();

    // --- 1. Fetch Existing Product Data ---
    useEffect(() => {
        if (!productId || !supermarketId) {
            Alert.alert('Error', 'Missing product or supermarket ID.');
            router.back();
            return;
        }

        const fetchProductData = async () => {
            try {
                const productDocRef = doc(db, 'supermarket', supermarketId as string, 'products', productId as string);
                const productSnap = await getDoc(productDocRef);

                if (productSnap.exists()) {
                    const data = productSnap.data();
                    // Populate all state fields
                    setProductName(data.productName || '');
                    setPrice(data.price?.toString() || '0');
                    setStock(data.stockQuantity?.toString() || '0');
                    setBarcode(data.barcode || '');
                    setDescription(data.description || '');
                    setAisleLocation(data.aisleLocation || '');
                    setCategory(data.category || categories[0].value);
                    setCurrentImageUrl(data.productImgUrl || null);
                } else {
                    Alert.alert('Error', 'Product not found.');
                    router.back();
                }
            } catch (error) {
                console.error("Error fetching product:", error);
                Alert.alert('Error', 'Failed to load product data.');
            } finally {
                setIsLoading(false);
            }
        };

        fetchProductData();
    }, [productId, supermarketId]); // Re-run if IDs change

    const handleBack = () => {
        router.back();
    };

    // --- 2. Image Picker (Same as AddProduct) ---
    const handleImageUpload = async () => {
        let result = await ImagePicker.launchImageLibraryAsync({
            mediaTypes: ['images'],
            allowsEditing: true,
            aspect: [1, 1],
            quality: 0.7,
            base64: true,
        });

        if (!result.canceled && result.assets && result.assets[0].base64) {
            const asset = result.assets[0];
            const mimeType = asset.mimeType || 'image/jpeg';
            const dataUri = `data:${mimeType};base64,${asset.base64}`;
            setNewImage(dataUri); // Set the new image
        }
    };

    // --- 3. Update Product Function ---
    const handleUpdateProduct = async () => {
        if (!productName || !price || !stock || !category) {
            Alert.alert('Missing Fields', 'Please fill in all required fields.');
            return;
        }

        setIsUpdating(true);

        try {
            let finalImageUrl = currentImageUrl; // Default to the old image URL

            // 1. If a new image was picked, upload it
            if (newImage) {
                console.log("Uploading new image to backend...");
                const uploadResponse = await fetch(BACKEND_UPLOAD_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ image: newImage }),
                });

                const uploadData = await uploadResponse.json();
                if (uploadResponse.ok && uploadData.imageURL) {
                    finalImageUrl = uploadData.imageURL;
                } else {
                    throw new Error(uploadData.error || 'Backend image upload failed');
                }
            }

            // 2. Get reference to the specific product document
            const productDocRef = doc(db, 'supermarket', supermarketId as string, 'products', productId as string);

            // 3. Prepare updated data
            const productData = {
                productName,
                price: parseFloat(price),
                stockQuantity: parseInt(stock, 10),
                barcode,
                description,
                aisleLocation,
                category,
                productImgUrl: finalImageUrl,
                updatedAt: serverTimestamp(), // Add an 'updatedAt' timestamp
            };

            // 4. Update the document
            await updateDoc(productDocRef, productData);

            Alert.alert('Success', 'Product updated successfully!');
            router.back();

        } catch (error) {
            console.error('Error updating product:', error);
            Alert.alert('Error', `Failed to update product. ${error instanceof Error ? error.message : ''}`);
        } finally {
            setIsUpdating(false);
        }
    };

    // Show loading spinner while fetching data
    if (isLoading) {
        return (
            <SafeAreaView style={[styles.safeArea, { justifyContent: 'center', alignItems: 'center' }]}>
                <ActivityIndicator size="large" color={PRIMARY_AMBER} />
            </SafeAreaView>
        );
    }

    return (
        <SafeAreaView style={styles.safeArea}>
            <View style={styles.header}>
                <TouchableOpacity onPress={handleBack} style={styles.backButton}>
                    <Ionicons name="arrow-back" size={24} color="#000" />
                </TouchableOpacity>
                <Text style={styles.headerTitle}>Edit Product</Text>
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
                        {/* Show new image if picked, otherwise show current image */}
                        {(newImage || currentImageUrl) ? (
                            <Image source={{ uri: newImage || currentImageUrl }} style={styles.previewImage} />
                        ) : (
                            <>
                                <Ionicons name="cloud-upload-outline" size={32} color="#999" />
                                <Text style={styles.uploadTextTitle}>Tap to change image</Text>
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
                    style={[styles.addButton, isUpdating && styles.addButtonDisabled]}
                    onPress={handleUpdateProduct} // Call update function
                    disabled={isUpdating}
                >
                    {isUpdating ? (
                        <ActivityIndicator size="small" color="#000" />
                    ) : (
                        <Text style={styles.addButtonText}>Update Product</Text> // Change button text
                    )}
                </TouchableOpacity>
            </View>
        </SafeAreaView>
    );
}

// --- Styles (Identical to AddProductScreen) ---
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