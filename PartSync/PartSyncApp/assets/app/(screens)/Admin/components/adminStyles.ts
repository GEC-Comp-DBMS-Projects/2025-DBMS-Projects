import { StyleSheet } from "react-native";

export const styles = (theme: any) =>
  StyleSheet.create({
    content: {
      flex: 1,
      padding: 16,
      backgroundColor: theme.background,
    },
    subheading: {
      color: theme.text,
      fontSize: 18,
      fontWeight: "600",
      marginVertical: 8,
    },
    searchInput: {
      backgroundColor: theme.cardBackground,
      padding: 8,
      borderRadius: 8,
      color: theme.text,
      marginBottom: 10,
      borderWidth: 1,
      borderColor: theme.border,
    },
    chip: {
      paddingHorizontal: 12,
      paddingVertical: 6,
      backgroundColor: theme.cardBackground,
      borderRadius: 20,
      marginRight: 8,
      marginBottom: 8,
    },
    chipText: {
      color: theme.text,
      fontWeight: "500",
    },
    card: {
      backgroundColor: theme.cardBackground,
      padding: 12,
      borderRadius: 10,
      marginBottom: 10,
    },
    cardText: {
      color: theme.text,
      fontSize: 14,
      marginVertical: 2,
    },
    image: {
      width: "100%",
      height: 150,
      borderRadius: 10,
      marginBottom: 8,
    },
    input: {
      backgroundColor: theme.cardBackground,
      padding: 8,
      borderRadius: 8,
      marginBottom: 8,
      color: theme.text,
      borderWidth: 1,
      borderColor: theme.border,
    },
    toggleRow: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center",
      marginVertical: 6,
    },
    toggleLabel: {
      color: theme.text,
      fontSize: 14,
    },
    submit: {
      backgroundColor: theme.primary,
      padding: 12,
      borderRadius: 10,
      alignItems: "center",
      marginVertical: 10,
    },
    submitText: {
      color: "#fff",
      fontWeight: "600",
      fontSize: 16,
    },
    modalContainer: {
      flex: 1,
      backgroundColor: "rgba(0,0,0,0.5)",
      justifyContent: "center",
      padding: 16,
    },
    modalContent: {
      backgroundColor: theme.background,
      borderRadius: 10,
      padding: 16,
      maxHeight: "80%",
    },
  });
