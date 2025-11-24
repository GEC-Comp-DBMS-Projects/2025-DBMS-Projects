import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  FlatList,
  StyleSheet,
  Modal,
  TextInput,
  ScrollView,
} from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import { MotiView, MotiText } from "moti";
import { Ionicons } from "@expo/vector-icons";
import axios from "axios";

type Announcement = { id: number; title: string; content: string };

const API_URL = "http://10.246.134.45:5000";

// ✅ Reusable Alert Modal
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
            color={type === "success" ? "#34C759" : type === "error" ? "#FF3B30" : "#FF9500"}
            style={{ marginBottom: 10 }}
          />
          <MotiText
            from={{ opacity: 0, translateY: 10 }}
            animate={{ opacity: 1, translateY: 0 }}
            transition={{ delay: 150 }}
            style={styles.alertTitle}
          >
            {title}
          </MotiText>
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

const Announcements: React.FC = () => {
  const [announcements, setAnnouncements] = useState<Announcement[]>([]);
  const [modalVisible, setModalVisible] = useState(false);
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [editingId, setEditingId] = useState<number | null>(null);

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

  useEffect(() => {
    fetchAnnouncements();
  }, []);

  const fetchAnnouncements = async () => {
    try {
      const res = await axios.get(`${API_URL}/announcements`);
      setAnnouncements(res.data);
    } catch (err) {
      console.log(err);
    }
  };

  const handleSave = async () => {
    if (!title || !content) {
      showAlert("error", "Missing Info", "Enter title and content");
      return;
    }
    try {
      if (editingId !== null) {
        await axios.put(`${API_URL}/announcements/${editingId}`, { title, content });
        showAlert("success", "Updated!", "Announcement updated successfully");
      } else {
        await axios.post(`${API_URL}/announcements`, { title, content });
        showAlert("success", "Created!", "Announcement created successfully");
      }
      fetchAnnouncements();
      setModalVisible(false);
      setTitle("");
      setContent("");
      setEditingId(null);
    } catch (err) {
      showAlert("error", "Error", "Failed to save announcement");
    }
  };

  const handleDelete = async (id: number) => {
    try {
      await axios.delete(`${API_URL}/announcements/${id}`);
      fetchAnnouncements();
      showAlert("success", "Deleted!", "Announcement removed");
    } catch (err) {
      showAlert("error", "Error", "Failed to delete");
    }
  };

  return (
    <View style={{ flex: 1 }}>
      
      <TouchableOpacity
        onPress={() => setModalVisible(true)}
        style={{ marginBottom: 15 }}
      >
        <LinearGradient colors={["#FF7E5F", "#FF4500"]} style={styles.addButton}>
          <Ionicons name="add-circle-outline" size={20} color="#fff" />
          <Text style={styles.addButtonText}>Add Announcement</Text>
        </LinearGradient>
      </TouchableOpacity>

      <FlatList
        data={announcements}
        keyExtractor={(item) => item.id.toString()}
        contentContainerStyle={{ paddingBottom: 20 }}
        showsVerticalScrollIndicator={false}
        renderItem={({ item }) => (
          <MotiView
            from={{ opacity: 0, translateY: 20 }}
            animate={{ opacity: 1, translateY: 0 }}
            transition={{ type: "timing", duration: 400 }}
            style={styles.card}
          >
            <Text style={styles.cardTitle}>{item.title}</Text>
            <Text style={styles.cardContent}>{item.content}</Text>
            <View style={styles.row}>
              <TouchableOpacity
                onPress={() => {
                  setTitle(item.title);
                  setContent(item.content);
                  setEditingId(item.id);
                  setModalVisible(true);
                }}
                style={styles.editButton}
              >
                <Ionicons name="pencil" size={16} color="#333" />
                <Text style={styles.editText}>Edit</Text>
              </TouchableOpacity>
              <TouchableOpacity onPress={() => handleDelete(item.id)} style={styles.deleteButton}>
                <Ionicons name="trash" size={16} color="#fff" />
                <Text style={styles.deleteText}>Delete</Text>
              </TouchableOpacity>
            </View>
          </MotiView>
        )}
      />

      {/* Modal for Add/Edit */}
      <Modal transparent visible={modalVisible} animationType="fade">
        <View style={styles.modalOverlay}>
          <MotiView
            from={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ type: "timing", duration: 300 }}
            style={styles.modalCard}
          >
            <Text style={styles.modalTitle}>
              {editingId ? "Edit" : "Add"} Announcement
            </Text>
            <TextInput
              style={styles.input}
              placeholder="Title"
              placeholderTextColor="#999"
              value={title}
              onChangeText={setTitle}
            />
            <TextInput
              style={[styles.input, { height: 100 }]}
              placeholder="Content"
              placeholderTextColor="#999"
              multiline
              value={content}
              onChangeText={setContent}
            />
            <TouchableOpacity onPress={handleSave} style={{ width: "100%" }}>
              <LinearGradient colors={["#FF7E5F", "#FF4500"]} style={styles.saveButton}>
                <Text style={styles.saveButtonText}>Save</Text>
              </LinearGradient>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => setModalVisible(false)} style={{ marginTop: 10 }}>
              <Text style={styles.cancelText}>Cancel</Text>
            </TouchableOpacity>
          </MotiView>
        </View>
      </Modal>

      <AlertModal
        visible={alertVisible}
        type={alertType}
        title={alertTitle}
        message={alertMessage}
        onClose={() => setAlertVisible(false)}
      />
    </View>
  );
};

export default Announcements;

const styles = StyleSheet.create({
  addButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 12,
    borderRadius: 10,
    gap: 8,
  },
  addButtonText: { color: "#fff", fontWeight: "600", fontSize: 16 },
  card: {
    backgroundColor: "rgba(255,255,255,0.95)",
    padding: 15,
    borderRadius: 18,
    marginBottom: 12,
    shadowColor: "#000",
    shadowOpacity: 0.15,
    shadowOffset: { width: 0, height: 5 },
    shadowRadius: 12,
    elevation: 8,
  },
  cardTitle: { fontSize: 17, fontWeight: "700", marginBottom: 5, color: "#333" },
  cardContent: { fontSize: 14, color: "#666" },
  row: { flexDirection: "row", justifyContent: "flex-end", marginTop: 10, gap: 12 },
  editButton: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    padding: 8,
    borderRadius: 8,
    backgroundColor: "#FFD580",
  },
  editText: { color: "#333", fontWeight: "600" },
  deleteButton: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    padding: 8,
    borderRadius: 8,
    backgroundColor: "#FF6B6B",
  },
  deleteText: { color: "#fff", fontWeight: "600" },
  modalOverlay: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "rgba(0,0,0,0.35)",
  },
  modalCard: {
    width: "85%",
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
  modalTitle: { fontSize: 18, fontWeight: "700", marginBottom: 15, color: "#FF4500" },
  input: {
    width: "100%",
    borderWidth: 1,
    borderColor: "#ddd",
    borderRadius: 10,
    padding: 12,
    marginBottom: 12,
    fontSize: 14,
  },
  saveButton: { width: "100%", padding: 14, borderRadius: 12, alignItems: "center" },
  saveButtonText: { color: "#fff", fontWeight: "700" },
  cancelText: { color: "#FF4500", fontWeight: "600" },
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
