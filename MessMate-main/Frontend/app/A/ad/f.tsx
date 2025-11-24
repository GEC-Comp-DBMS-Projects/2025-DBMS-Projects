import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Modal,
} from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import { MotiView, MotiText } from "moti";
import { Ionicons } from "@expo/vector-icons";

type FeedbackItem = {
  feedback_id: number;
  user: string;
  category: string;
  stars: number;
  comment: string;
  status: "Pending" | "Reviewed";
};

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

const Feedback: React.FC = () => {
  const [feedback, setFeedback] = useState<FeedbackItem[]>([]);
  const [loading, setLoading] = useState(true);

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

  const fetchFeedback = async () => {
    try {
      setLoading(true);
      const response = await fetch("http://10.246.134.45:5000/feedback/getPendingFeedback", {
        method: "GET",
        headers: { "Content-Type": "application/json" },
      });
      const data = await response.json();
      if (data.feedback) {
        setFeedback(data.feedback);
      }
    } catch (err) {
      console.error("Error fetching feedback:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFeedback();
  }, []);

  const markAsReviewed = async (id: number) => {
    try {
      setFeedback((prev) =>
        prev.map((f) => (f.feedback_id === id ? { ...f, status: "Reviewed" } : f))
      );
      await fetch(`http://10.246.134.45:5000/feedback/updateStatus/${id}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status: "Reviewed" }),
      });
      showAlert("success", "Reviewed!", "Feedback marked as reviewed");
    } catch (err) {
      console.error("Error updating feedback status:", err);
      showAlert("error", "Error", "Failed to update status");
    }
  };

  if (loading) {
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
        <ActivityIndicator size="large" color="#FF4500" />
        <Text style={{ marginTop: 10, color: "#666" }}>Loading feedback...</Text>
      </View>
    );
  }

  return (
    <View style={{ flex: 1 }}>
      <FlatList
        data={feedback}
        keyExtractor={(item) => item.feedback_id.toString()}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={
          <View style={{ padding: 20, alignItems: "center" }}>
            <Ionicons name="chatbubbles-outline" size={60} color="#ccc" />
            <Text style={{ marginTop: 10, color: "#999" }}>No pending feedback</Text>
          </View>
        }
        renderItem={({ item, index }) => (
          <MotiView
            from={{ opacity: 0, translateY: 20 }}
            animate={{ opacity: 1, translateY: 0 }}
            transition={{ type: "timing", duration: 400, delay: index * 50 }}
            style={styles.card}
          >
            <View style={styles.cardHeader}>
              <Text style={styles.cardTitle}>
                {item.user} - {item.category}
              </Text>
              <View style={styles.ratingRow}>
                <Ionicons name="star" size={16} color="#FFD700" />
                <Text style={styles.ratingText}>{item.stars}</Text>
              </View>
            </View>
            <Text style={styles.comment}>{item.comment}</Text>
            {item.status === "Pending" && (
              <TouchableOpacity onPress={() => markAsReviewed(item.feedback_id)}>
                <LinearGradient colors={["#FF7E5F", "#FF4500"]} style={styles.reviewButton}>
                  <Ionicons name="checkmark-done" size={18} color="#fff" />
                  <Text style={styles.reviewButtonText}>Mark as Reviewed</Text>
                </LinearGradient>
              </TouchableOpacity>
            )}
            <Text style={styles.status}>Status: {item.status}</Text>
          </MotiView>
        )}
      />

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

export default Feedback;

const styles = StyleSheet.create({
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
  cardHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 8,
  },
  cardTitle: { fontSize: 16, fontWeight: "700", color: "#333", flex: 1 },
  ratingRow: { flexDirection: "row", alignItems: "center", gap: 4 },
  ratingText: { fontSize: 14, fontWeight: "600", color: "#333" },
  comment: { fontSize: 14, color: "#666", marginBottom: 10 },
  reviewButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 10,
    borderRadius: 10,
    gap: 6,
    marginTop: 8,
  },
  reviewButtonText: { color: "#fff", fontWeight: "600", fontSize: 14 },
  status: { fontSize: 12, color: "#999", marginTop: 8, fontWeight: "500" },
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
