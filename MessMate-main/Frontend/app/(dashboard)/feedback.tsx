import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  TextInput,
  FlatList,
  RefreshControl,
  Modal,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { MessageSquare, Star, Send } from "lucide-react-native";
import { LinearGradient } from "expo-linear-gradient";
import AsyncStorage from "@react-native-async-storage/async-storage";

const categories = [
  { id: "general", label: "General", color: ["#FF7E5F", "#FF4500"] },
  { id: "food", label: "Food Quality", color: ["#FF9A8B", "#FF6A00"] },
  { id: "cleanliness", label: "Cleanliness", color: ["#F59E0B", "#D97706"] },
  { id: "staff", label: "Staff Behavior", color: ["#FF7E5F", "#FF4500"] },
  { id: "facilities", label: "Facilities", color: ["#EF4444", "#DC2626"] },
];

// Reusable feedback card (like TransactionCard)
const FeedbackCard = ({ item }) => (
  <View style={styles.feedbackCard}>
    <View style={styles.feedbackHeader}>
      <LinearGradient
        colors={["#FF7E5F", "#FF4500"]}
        style={styles.categoryIcon}
      >
        <MessageSquare size={18} color="#fff" />
      </LinearGradient>
      <View style={{ flex: 1, marginLeft: 12 }}>
        <Text style={styles.feedbackCategory}>{item.category}</Text>
        <View style={styles.starRow}>
          {[1, 2, 3, 4, 5].map((s) => (
            <Star
              key={s}
              size={14}
              color={s <= item.stars ? "#F59E0B" : "#D1D5DB"}
              fill={s <= item.stars ? "#F59E0B" : "none"}
            />
          ))}
        </View>
      </View>
      <Text
        style={[
          styles.statusText,
          item.status === "Reviewed" ? styles.statusReviewed : styles.statusPending,
        ]}
      >
        {item.status}
      </Text>
    </View>
    <Text style={styles.feedbackComment}>{item.comment}</Text>
    <Text style={styles.feedbackDate}>
      {new Date(item.created_at).toLocaleString()}
    </Text>
  </View>
);

export default function FeedbackScreen() {
  const [selectedCategory, setSelectedCategory] = useState("general");
  const [rating, setRating] = useState(0);
  const [feedback, setFeedback] = useState("");
  const [recentFeedback, setRecentFeedback] = useState([]);
  const [refreshing, setRefreshing] = useState(false);

  const fetchRecentFeedback = async () => {
    try {
      const token = await AsyncStorage.getItem("token");
      const res = await fetch("http://10.246.134.45:5000/feedback/getUserFeedback", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      if (res.ok) setRecentFeedback(data.feedback);
    } catch (err) {
      console.error(err);
    } finally {
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchRecentFeedback();
    const interval = setInterval(fetchRecentFeedback, 10000);
    return () => clearInterval(interval);
  }, []);

  const handleSubmitFeedback = async () => {
    if (!feedback.trim() || rating === 0) return;
    try {
      const token = await AsyncStorage.getItem("token");
      const response = await fetch(
        "http://10.246.134.45:5000/feedback/submitFeedback",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({
            category: categories.find((c) => c.id === selectedCategory).label,
            stars: rating,
            comment: feedback,
          }),
        }
      );

      if (response.ok) {
        setFeedback("");
        setRating(0);
        setSelectedCategory("general");
        fetchRecentFeedback();
      }
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <FlatList
        data={recentFeedback}
        keyExtractor={(item) => item.feedback_id.toString()}
        renderItem={({ item }) => <FeedbackCard item={item} />}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={() => {
              setRefreshing(true);
              fetchRecentFeedback();
            }}
          />
        }
        ListHeaderComponent={
          <>
            {/* Header */}
            <View style={styles.header}>
              <LinearGradient colors={["#FF7E5F", "#FF4500"]} style={styles.headerIcon}>
                <MessageSquare size={24} color="#fff" />
              </LinearGradient>
              <Text style={styles.headerTitle}>Mess Feedback Portal</Text>
            </View>

            {/* Feedback Form */}
            <View style={styles.formCard}>
              <Text style={styles.formTitle}>Share Your Feedback</Text>

              {/* Category Selector */}
              <View style={styles.categoryContainer}>
                {categories.map((c) => (
                  <TouchableOpacity
                    key={c.id}
                    onPress={() => setSelectedCategory(c.id)}
                    style={[
                      styles.categoryButton,
                      selectedCategory === c.id && {
                        backgroundColor: c.color[1],
                        borderColor: c.color[1],
                      },
                    ]}
                  >
                    <Text
                      style={[
                        styles.categoryText,
                        selectedCategory === c.id && { color: "#fff" },
                      ]}
                    >
                      {c.label}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>

              {/* Rating */}
              <View style={styles.ratingContainer}>
                {[1, 2, 3, 4, 5].map((s) => (
                  <TouchableOpacity
                    key={s}
                    onPress={() => setRating(s)}
                    style={{ marginRight: 8 }}
                  >
                    <Star
                      size={32}
                      color={s <= rating ? "#F59E0B" : "#D1D5DB"}
                      fill={s <= rating ? "#F59E0B" : "none"}
                    />
                  </TouchableOpacity>
                ))}
              </View>

              {/* Text Input */}
              <TextInput
                placeholder="Write your feedback..."
                value={feedback}
                onChangeText={setFeedback}
                multiline
                style={styles.textInput}
              />

              {/* Submit Button */}
              <TouchableOpacity
                style={[
                  styles.submitButton,
                  (!feedback.trim() || rating === 0) && { opacity: 0.6 },
                ]}
                onPress={handleSubmitFeedback}
                disabled={!feedback.trim() || rating === 0}
              >
                <Send size={18} color="#fff" />
                <Text style={styles.submitText}>Submit Feedback</Text>
              </TouchableOpacity>
            </View>

            {/* Section Header */}
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Your Recent Feedback</Text>
            </View>
          </>
        }
        ListEmptyComponent={
          <Text style={styles.emptyText}>No feedback yet</Text>
        }
        contentContainerStyle={{ paddingBottom: 40 }}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#F9FAFB" },
  header: { flexDirection: "row", alignItems: "center", padding: 24, paddingBottom: 16 },
  headerIcon: { width: 50, height: 50, borderRadius: 12, justifyContent: "center", alignItems: "center" },
  headerTitle: { fontSize: 24, fontWeight: "bold", color: "#111827", marginLeft: 12 },

  formCard: { backgroundColor: "#FFF", borderRadius: 16, padding: 20, marginHorizontal: 24, marginBottom: 24, elevation: 2 },
  formTitle: { fontSize: 18, fontWeight: "600", color: "#111827", marginBottom: 12 },
  categoryContainer: { flexDirection: "row", flexWrap: "wrap", marginBottom: 12 },
  categoryButton: { paddingHorizontal: 16, paddingVertical: 8, borderRadius: 20, borderWidth: 1, borderColor: "#E5E7EB", marginRight: 8, marginBottom: 8 },
  categoryText: { fontSize: 12, fontWeight: "600", color: "#6B7280" },
  ratingContainer: { flexDirection: "row", marginBottom: 12 },
  textInput: { borderWidth: 1, borderColor: "#E5E7EB", borderRadius: 12, padding: 16, fontSize: 14, backgroundColor: "#F9FAFB", textAlignVertical: "top", color: "#111827", marginBottom: 16 },
  submitButton: { backgroundColor: "#FF4500", borderRadius: 12, paddingVertical: 14, flexDirection: "row", alignItems: "center", justifyContent: "center" },
  submitText: { color: "#fff", fontWeight: "600", marginLeft: 8 },

  section: { paddingHorizontal: 24, paddingTop: 0 },
  sectionTitle: { fontSize: 18, fontWeight: "600", color: "#111827", marginBottom: 16 },

  feedbackCard: { backgroundColor: "#FFF", borderRadius: 16, padding: 16, marginHorizontal: 24, marginBottom: 12, elevation: 2 },
  feedbackHeader: { flexDirection: "row", alignItems: "center", marginBottom: 8 },
  feedbackCategory: { fontSize: 14, fontWeight: "600", color: "#111827" },
  starRow: { flexDirection: "row", marginTop: 4 },
  feedbackComment: { fontSize: 14, color: "#374151", marginBottom: 8, lineHeight: 20 },
  feedbackDate: { fontSize: 12, color: "#6B7280" },
  categoryIcon: { width: 36, height: 36, borderRadius: 12, justifyContent: "center", alignItems: "center" },
  statusText: { fontSize: 12, fontWeight: "600" },
  statusReviewed: { color: "#FF4500" },
  statusPending: { color: "#F59E0B" },
  emptyText: { textAlign: "center", color: "#6B7280", marginTop: 8 },
});
