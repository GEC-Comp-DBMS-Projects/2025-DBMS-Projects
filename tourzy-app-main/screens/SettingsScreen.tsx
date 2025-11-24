import React, { useState } from 'react';
import {
  StyleSheet,
  SafeAreaView,
  ScrollView,
  View,
  Text,
  TouchableOpacity,
  Switch,
  Image,
  ImageBackground
} from 'react-native';
import FeatherIcon from 'react-native-vector-icons/Feather';
import Navbar from '../components/Navbar';
import { useNavigation } from '@react-navigation/core';
import { signOut } from 'firebase/auth';
import { auth } from '../firebase'; // Ensure you're importing auth from your firebase config

export default function Example() {
    const navigation = useNavigation();
    const [form, setForm] = useState({
        emailNotifications: true,
        pushNotifications: false,
    });

    // Function to handle logout
    const handleLogout = async () => {
        try {
            await signOut(auth);
            navigation.navigate('SignIn'); // Navigate to the SignIn screen after logout
        } catch (error) {
            console.error("Logout Error: ", error);
        }
    };

    return (
        <SafeAreaView style={{ flex: 1, backgroundColor: '#f8f8f8' }}>
            <ImageBackground
                source={require('../assets/mountainBack.jpg')}
                style={{ flex: 1, height: 900, width: 450, padding: 30 }}
            >
                <View style={styles.header}>
                    <View >
                        <TouchableOpacity
                            onPress={() => navigation.navigate('Menu')}
                            style={({ pressed }) => [{ opacity: pressed ? 0.6 : 1 }]}
                        >
                            <FeatherIcon
                                color="#000"
                                name="arrow-left"
                                size={24} />
                        </TouchableOpacity>
                    </View>

                    <Text numberOfLines={1} style={styles.headerTitle}>
                        Settings
                    </Text>

                    
                </View>

                <ScrollView contentContainerStyle={styles.content}>
                    <View style={[styles.section, { paddingTop: 4 }]}>
                        <Text style={styles.sectionTitle}>Account</Text>

                        <View style={styles.sectionBody}>
                            <TouchableOpacity
                                onPress={() => {
                                    // handle onPress
                                }}
                                style={styles.profile}>
                                <Image
                                    alt=""
                                    source={require('../assets/adventurer.png')}
                                    style={styles.profileAvatar} />

                                <View style={styles.profileBody}>
                                    <Text style={styles.profileName}>shaun</Text>

                                    <Text style={styles.profileHandle}>shaun.com</Text>
                                </View>

                                <FeatherIcon
                                    color="#bcbcbc"
                                    name="chevron-right"
                                    size={22} />
                            </TouchableOpacity>
                        </View>
                    </View>

                    <View style={styles.section}>
                        <Text style={styles.sectionTitle}>Preferences</Text>

                        <View style={styles.sectionBody}>
                            <View style={[styles.rowWrapper, styles.rowFirst]}>
                                <TouchableOpacity
                                    onPress={() => {
                                        // handle onPress
                                    }}
                                    style={styles.row}>
                                    <Text style={styles.rowLabel}>Language</Text>

                                    <View style={styles.rowSpacer} />

                                    <Text style={styles.rowValue}>English</Text>

                                    <FeatherIcon
                                        color="#bcbcbc"
                                        name="chevron-right"
                                        size={19} />
                                </TouchableOpacity>
                            </View>

                            <View style={styles.rowWrapper}>
                                <TouchableOpacity
                                    onPress={() => {
                                        // handle onPress
                                    }}
                                    style={styles.row}>
                                    <Text style={styles.rowLabel}>Location</Text>

                                    <View style={styles.rowSpacer} />

                                    <Text style={styles.rowValue}>Los Angeles, CA</Text>

                                    <FeatherIcon
                                        color="#bcbcbc"
                                        name="chevron-right"
                                        size={19} />
                                </TouchableOpacity>
                            </View>

                            <View style={styles.rowWrapper}>
                                <View style={styles.row}>
                                    <Text style={styles.rowLabel}>Email Notifications</Text>

                                    <View style={styles.rowSpacer} />

                                    <Switch
                                        onValueChange={emailNotifications =>
                                            setForm({ ...form, emailNotifications })
                                        }
                                        style={{ transform: [{ scaleX: 0.95 }, { scaleY: 0.95 }] }}
                                        value={form.emailNotifications} />
                                </View>
                            </View>

                            <View style={[styles.rowWrapper, styles.rowLast]}>
                                <View style={styles.row}>
                                    <Text style={styles.rowLabel}>Push Notifications</Text>

                                    <View style={styles.rowSpacer} />

                                    <Switch
                                        onValueChange={pushNotifications =>
                                            setForm({ ...form, pushNotifications })
                                        }
                                        style={{ transform: [{ scaleX: 0.95 }, { scaleY: 0.95 }] }}
                                        value={form.pushNotifications} />
                                </View>
                            </View>
                        </View>
                    </View>

                    <View style={styles.section}>
                        <Text style={styles.sectionTitle}>Resources</Text>

                        <View style={styles.sectionBody}>
                            <View style={[styles.rowWrapper, styles.rowFirst]}>
                                <TouchableOpacity
                                    onPress={() => {
                                        // handle onPress
                                    }}
                                    style={styles.row}>
                                    <Text style={styles.rowLabel}>Contact Us</Text>

                                    <View style={styles.rowSpacer} />

                                    <FeatherIcon
                                        color="#bcbcbc"
                                        name="chevron-right"
                                        size={19} />
                                </TouchableOpacity>
                            </View>

                            <View style={styles.rowWrapper}>
                                <TouchableOpacity
                                    onPress={() => {
                                        // handle onPress
                                    }}
                                    style={styles.row}>
                                    <Text style={styles.rowLabel}>Report Bug</Text>

                                    <View style={styles.rowSpacer} />

                                    <FeatherIcon
                                        color="#bcbcbc"
                                        name="chevron-right"
                                        size={19} />
                                </TouchableOpacity>
                            </View>

                            <View style={styles.rowWrapper}>
                                <TouchableOpacity
                                    onPress={() => {
                                        // handle onPress
                                    }}
                                    style={styles.row}>
                                    <Text style={styles.rowLabel}>Rate in App Store</Text>

                                    <View style={styles.rowSpacer} />

                                    <FeatherIcon
                                        color="#bcbcbc"
                                        name="chevron-right"
                                        size={19} />
                                </TouchableOpacity>
                            </View>

                            <View style={[styles.rowWrapper, styles.rowLast]}>
                                <TouchableOpacity
                                    onPress={() => {
                                        // handle onPress
                                    }}
                                    style={styles.row}>
                                    <Text style={styles.rowLabel}>Terms and Privacy</Text>

                                    <View style={styles.rowSpacer} />

                                    <FeatherIcon
                                        color="#bcbcbc"
                                        name="chevron-right"
                                        size={19} />
                                </TouchableOpacity>
                            </View>
                        </View>
                    </View>

                    <View style={styles.section}>
                        <View style={styles.sectionBody}>
                            <View
                                style={[
                                    styles.rowWrapper,
                                    styles.rowFirst,
                                    styles.rowLast,
                                    { alignItems: 'center' },
                                ]}>
                                <TouchableOpacity onPress={handleLogout}>
                                    <Text style={styles.logout}>Logout</Text>
                                </TouchableOpacity>
                            </View>
                        </View>
                    </View>
                </ScrollView>
                <View style={{ bottom: -30, left: -20}}>
                    <Navbar />
                </View>
            </ImageBackground>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
  /** Header */
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: '100%',
    paddingHorizontal: 16,
  },
 
  headerTitle: {
    fontSize: 29,
    left:-35,
    fontWeight: '600',
    color: '#000',
    flexGrow: 1,
    flexShrink: 1,
    flexBasis: 0,
    textAlign: 'center',
  },
  /** Content */
  content: {
    paddingHorizontal: 16,
  },
  /** Section */
  section: {
    paddingVertical: 0, // Set padding to 0 to remove gap
    marginBottom: 25, 
    backgroundColor:'#ECE8E8',
    borderRadius:20,
    left:-20,
    top:5,
     
  },
  sectionTitle: {
    margin: 8,
    marginLeft: 12,
    fontSize: 15,
    fontWeight: '700',
    color: 'black',
  },
  sectionBody: {
    paddingHorizontal: 12,
    paddingVertical: 4,
  },
  /** Row */
  rowWrapper: {
    paddingVertical: 8,
    marginBottom: 0, // Ensure no bottom margin
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  rowLabel: {
    fontSize: 18,
    fontWeight: '600',
    color: 'black',
  },
  rowValue: {
    fontSize: 18,
    fontWeight: '400',
    color: '#a8a8a8',
  },
  rowSpacer: {
    flexGrow: 1,
  },
  rowFirst: {
    borderTopWidth: 1,
    borderTopColor: 'black',
  },
  rowLast: {
    borderBottomWidth: 1,
    borderBottomColor: '#e5e5e5',
  },
  /** Profile */
  profile: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 8,
  },
  profileAvatar: {
    width: 36,
    height: 36,
    borderRadius: 18,
  },
  profileBody: {
    flexGrow: 1,
    flexShrink: 1,
    marginLeft: 8,
  },
  profileName: {
    fontSize: 18,
    fontWeight: '600',
    color:'black',
  },
  profileHandle: {
    fontSize: 14,
    color: 'black',
  },
  /** Logout */
  logout: {
    fontSize: 18,
    fontWeight: '500',
    color: '#e70000',
  },
});
