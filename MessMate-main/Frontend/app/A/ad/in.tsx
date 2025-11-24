import React, { useState } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Modal,
  KeyboardAvoidingView,
  Platform,
} from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import { MotiView, MotiText } from "moti";
import { Ionicons } from "@expo/vector-icons";
import axios from "axios";

// ✅ Alert Modal
function AlertModal({ visible, type, title, message, onClose }: any) {
  const getIcon = () => {
    switch (type) {
      case "success": return "checkmark-circle";
      case "error": return "close-circle";
      default: return "alert-circle";
    }
  };

  return (
    <Modal transparent visible={visible} animationType="fade">
      <View style={styles.modalOverlay}>
        <MotiView
          from={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ type: "timing", duration: 300 }}
          style={styles.alertCard}
        >
          <Ionicons
            name={getIcon()}
            size={56}
            color={type === "success" ? "#34C759" : "#FF3B30"}
            style={{ marginBottom: 10 }}
          />
          <MotiText style={styles.alertTitle}>{title}</MotiText>
          <Text style={styles.alertMessage}>{message}</Text>
          <TouchableOpacity onPress={onClose} style={{ width: "100%", marginTop: 15 }}>
            <LinearGradient colors={["#FF7E5F", "#FF4500"]} style={styles.alertButton}>
              <Text style={styles.alertButtonText}>OK</Text>
            </LinearGradient>
          </TouchableOpacity>
        </MotiView>
      </View>
    </Modal>
  );
}

const InviteStudent: React.FC = () => {
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");

  const [alertVisible, setAlertVisible] = useState(false);
  const [alertType, setAlertType] = useState("success");
  const [alertTitle, setAlertTitle] = useState("");
  const [alertMessage, setAlertMessage] = useState("");

  const showAlert = (type: string, title: string, message: string) => {
    setAlertType(type);
    setAlertTitle(title);
    setAlertMessage(message);
    setAlertVisible(true);
  };

  const handleInvite = async () => {
    if (!fullName || !email) {
      showAlert("error", "Missing Info", "Please fill in all fields");
      return;
    }

    try {
      const res = await axios.post("http://10.246.134.45:5000/api/admin/invite-student", {
        full_name: fullName,
        email,
      });
      showAlert("success", "Invitation Sent!", res.data.message || "Student invited successfully");
      setFullName("");
      setEmail("");
    } catch (error: any) {
      if (error.response && error.response.status === 409) {
        showAlert("error", "Duplicate Email", error.response.data.message);
      } else if (error.response && error.response.data && error.response.data.message) {
        showAlert("error", "Error", error.response.data.message);
      } else {
        showAlert("error", "Error", "Failed to send invitation");
      }
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === "ios" ? "padding" : "height"}
      style={{ flex: 1 }}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContainer}
        showsVerticalScrollIndicator={false}
      >
        <MotiView
          from={{ opacity: 0, translateY: 40 }}
          animate={{ opacity: 1, translateY: 0 }}
          transition={{ type: "timing", duration: 600 }}
          style={styles.card}
        >
          <Ionicons name="person-add" size={60} color="#FF4500" style={{ marginBottom: 15 }} />
          <Text style={styles.title}>Invite a Student 🎓</Text>
          <Text style={styles.subtitle}>Send an invitation to join MessMate</Text>

          <View style={styles.inputWrapper}>
            <Ionicons name="person-outline" size={18} color="#FF7E5F" />
            <TextInput
              style={styles.input}
              placeholder="Full Name"
              placeholderTextColor="#999"
              value={fullName}
              onChangeText={setFullName}
            />
          </View>

          <View style={styles.inputWrapper}>
            <Ionicons name="mail-outline" size={18} color="#FF7E5F" />
            <TextInput
              style={styles.input}
              placeholder="Email Address"
              placeholderTextColor="#999"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
            />
          </View>

          <TouchableOpacity onPress={handleInvite} style={{ marginTop: 10, width: "100%" }}>
            <LinearGradient colors={["#FF7E5F", "#FF4500"]} style={styles.button}>
              <Ionicons name="send" size={18} color="#fff" />
              <Text style={styles.buttonText}>Send Invitation</Text>
            </LinearGradient>
          </TouchableOpacity>
        </MotiView>
      </ScrollView>

      <AlertModal
        visible={alertVisible}
        type={alertType}
        title={alertTitle}
        message={alertMessage}
        onClose={() => setAlertVisible(false)}
      />
    </KeyboardAvoidingView>
  );
};

export default InviteStudent;

const styles = StyleSheet.create({
  scrollContainer: {
    flexGrow: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 20,
  },
  card: {
    width: "100%",
    backgroundColor: "rgba(255,255,255,0.95)",
    borderRadius: 18,
    padding: 25,
    shadowColor: "#000",
    shadowOpacity: 0.15,
    shadowOffset: { width: 0, height: 5 },
    shadowRadius: 12,
    elevation: 8,
    alignItems: "center",
  },
  title: { fontSize: 24, fontWeight: "700", color: "#333", marginBottom: 4 },
  subtitle: { fontSize: 14, color: "#666", textAlign: "center", marginBottom: 25 },
  inputWrapper: {
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#ddd",
    borderRadius: 10,
    paddingHorizontal: 12,
    marginBottom: 15,
    width: "100%",
    backgroundColor: "#fff",
  },
  input: {
    flex: 1,
    paddingVertical: 10,
    paddingHorizontal: 8,
    fontSize: 14,
    color: "#333",
  },
  button: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    width: "100%",
    paddingVertical: 15,
    borderRadius: 10,
    gap: 8,
    shadowColor: "#FF4500",
    shadowOpacity: 0.4,
    shadowRadius: 10,
  },
  buttonText: { color: "#fff", fontSize: 16, fontWeight: "600" },
  modalOverlay: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "rgba(0,0,0,0.35)",
  },
  alertCard: {
    width: "80%",
    backgroundColor: "#fff",
    borderRadius: 18,
    padding: 20,
    alignItems: "center",
    shadowColor: "#000",
    shadowOpacity: 0.25,
    shadowOffset: { width: 0, height: 2 },
    shadowRadius: 8,
    elevation: 10,
  },
  alertTitle: { fontSize: 18, fontWeight: "700", color: "#333", marginBottom: 6 },
  alertMessage: { fontSize: 14, color: "#666", textAlign: "center" },
  alertButton: { padding: 12, borderRadius: 10, alignItems: "center", width: "100%" },
  alertButtonText: { color: "#fff", fontWeight: "bold", fontSize: 16 },
});
