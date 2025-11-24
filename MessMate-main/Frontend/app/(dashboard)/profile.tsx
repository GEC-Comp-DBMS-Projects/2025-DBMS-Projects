import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  Image,
} from 'react-native';
import { User, LogOut, Mail } from 'lucide-react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useNavigation } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';

const API_BASE_URL = "http://10.246.134.45:5000";

type RootStackParamList = {
  Login: undefined;
  Profile: undefined;
  Dashboard: undefined;
  ChoiceScreen: undefined;
};

type ProfileScreenNavigationProp = NativeStackNavigationProp<
  RootStackParamList,
  'Profile'
>;

export default function ProfileScreen() {
  const navigation = useNavigation<ProfileScreenNavigationProp>();
  const [userInfo, setUserInfo] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const token = await AsyncStorage.getItem("token");
        if (!token) {
          navigation.reset({ index: 0, routes: [{ name: "ChoiceScreen" }] });
          return;
        }

        const res = await fetch(`${API_BASE_URL}/profile`, {
          method: "GET",
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        });

        const data = await res.json();
        if (res.ok && data.user) setUserInfo(data.user);
        else console.error("Error fetching profile:", data.error);
      } catch (err) {
        console.error("Fetch failed:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchProfile();
  }, []);

  const handleLogout = async () => {
    try {
      await AsyncStorage.removeItem("token");
      navigation.reset({
        index: 0,
        routes: [{ name: "ChoiceScreen" }],
      });
    } catch (err) {
      console.error("Logout failed:", err);
    }
  };

  const getInitials = (name: string) => {
    return name
      ?.split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase();
  };

  if (loading)
    return (
      <SafeAreaView style={styles.container}>
        <ActivityIndicator size="large" color="#FF4500" style={{ marginTop: 50 }} />
      </SafeAreaView>
    );

  if (!userInfo)
    return (
      <SafeAreaView style={styles.container}>
        <Text style={{ textAlign: "center", marginTop: 50 }}>
          Failed to load profile
        </Text>
      </SafeAreaView>
    );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>

        {/* Header */}
        <View style={styles.header}>
          <LinearGradient
            colors={['#FF7E5F', '#FF4500']}
            style={styles.headerIcon}
          >
            <User size={24} color="#fff" />
          </LinearGradient>
          <Text style={styles.headerTitle}>Profile</Text>
        </View>

        {/* Profile Card */}
        <View style={styles.profileCard}>
          <View style={styles.avatarContainer}>
            {userInfo?.avatar_url ? (
              <Image source={{ uri: userInfo.avatar_url }} style={styles.avatar} />
            ) : (
              <View style={styles.avatarFallback}>
                <Text style={styles.avatarInitials}>
                  {getInitials(userInfo?.full_name || "U")}
                </Text>
              </View>
            )}
          </View>

          <View style={styles.profileInfo}>
            <Text style={styles.profileName}>{userInfo.full_name}</Text>
            <Text style={styles.profileId}>Student ID: {userInfo.id}</Text>
            <Text style={styles.profileJoinDate}>
              Member since{" "}
              {userInfo.join_date
                ? new Date(userInfo.join_date).toLocaleDateString()
                : "N/A"}
            </Text>
          </View>
        </View>

        {/* Contact Info */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Contact Information</Text>
          <View style={styles.contactCard}>
            <ContactItem
              icon={Mail}
              label="Email"
              value={userInfo.email}
              colors={['#10B981', '#34D399']}
            />
          </View>
        </View>

        {/* Logout */}
        <View style={styles.section}>
          <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
            <LogOut size={20} color="#EF4444" />
            <Text style={styles.logoutText}>Sign Out</Text>
          </TouchableOpacity>
        </View>

      </ScrollView>
    </SafeAreaView>
  );
}

interface ContactItemProps {
  icon: React.ComponentType<any>;
  label: string;
  value: string;
  colors: string[];
}

function ContactItem({ icon: Icon, label, value, colors }: ContactItemProps) {
  return (
    <View style={styles.contactItem}>
      <LinearGradient colors={colors} style={styles.contactIcon}>
        <Icon size={16} color="#fff" />
      </LinearGradient>
      <View style={styles.contactInfo}>
        <Text style={styles.contactLabel}>{label}</Text>
        <Text style={styles.contactValue}>{value}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F9FAFB' },

  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 24,
  },
  headerIcon: {
    width: 50,
    height: 50,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 26,
    fontWeight: '700',
    marginLeft: 12,
    color: '#111827',
  },

  profileCard: {
    backgroundColor: "#fff",
    borderRadius: 20,
    padding: 24,
    marginHorizontal: 24,
    marginTop: 16,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.1,
    shadowRadius: 12,
    elevation: 4,
  },

  avatarContainer: { marginBottom: 16 },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    borderWidth: 2,
    borderColor: "#FF7E5F",
  },
  avatarFallback: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: "#FF7E5F",
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: '#fff',
  },
  avatarInitials: { color: "#fff", fontSize: 32, fontWeight: "bold" },

  profileInfo: { alignItems: "center" },
  profileName: { fontSize: 22, fontWeight: "700", color: "#111827" },
  profileId: { fontSize: 14, color: "#6B7280", marginTop: 2 },
  profileJoinDate: { fontSize: 12, color: "#9CA3AF", marginTop: 2 },

  section: { paddingHorizontal: 24, paddingTop: 24 },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#111827",
    marginBottom: 12,
  },

  contactCard: {
    backgroundColor: "#fff",
    borderRadius: 16,
    padding: 16,
    shadowColor: "#000",
    shadowOpacity: 0.05,
    shadowOffset: { width: 0, height: 4 },
    shadowRadius: 8,
    elevation: 2,
  },
  contactItem: { flexDirection: "row", alignItems: "center", paddingVertical: 12 },
  contactIcon: {
    width: 36,
    height: 36,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
  contactInfo: { flex: 1, marginLeft: 12 },
  contactLabel: { fontSize: 12, color: "#6B7280", marginBottom: 2 },
  contactValue: { fontSize: 14, fontWeight: "500", color: "#111827" },

  logoutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#FEE2E2',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.05,
    shadowRadius: 8,
    elevation: 2,
    marginBottom: 40,
  },
  logoutText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#EF4444',
    marginLeft: 8,
  },
});
