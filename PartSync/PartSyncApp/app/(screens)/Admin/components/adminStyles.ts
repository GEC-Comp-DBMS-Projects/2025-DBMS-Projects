import { StyleSheet } from "react-native";

export const styles = (theme: any) =>
  StyleSheet.create({
    content: {
      flex: 1,
      padding: 20,
      backgroundColor: theme.background,
    },

    subheading: {
      color: theme.textPrimary,
      fontSize: 22,
      fontWeight: "700",
      marginBottom: 14,
      letterSpacing: 0.5,
    },
    cardText: {
      color: theme.textSecondary,
      fontSize: 15,
      lineHeight: 22,
    },

    input: {
      backgroundColor: theme.inputBackground,
      borderColor: theme.inputBorder,
      borderWidth: 1,
      borderRadius: 12,
      paddingVertical: 12,
      paddingHorizontal: 14,
      color: theme.textPrimary,
      fontSize: 15,
      marginBottom: 14,
      shadowColor: theme.textPrimary,
      shadowOpacity: 0.05,
      shadowOffset: { width: 0, height: 2 },
      shadowRadius: 4,
    },
    searchInput: {
      backgroundColor: theme.cardBackground,
      paddingVertical: 10,
      paddingHorizontal: 12,
      borderRadius: 10,
      color: theme.textPrimary,
      marginBottom: 14,
      borderWidth: 1,
      borderColor: theme.border,
      fontSize: 15,
    },

    submit: {
      paddingVertical: 14,
      alignItems: "center",
      justifyContent: "center",
      borderRadius: 12,
      marginVertical: 10,
      shadowColor: theme.accent,
      shadowOpacity: 0.2,
      shadowRadius: 6,
      shadowOffset: { width: 0, height: 3 },
      elevation: 3,
    },
    submitText: {
      color: theme.accentText,
      fontWeight: "600",
      fontSize: 16,
      letterSpacing: 0.3,
    },

    card: {
      backgroundColor: theme.cardBackground,
      borderRadius: 14,
      padding: 16,
      marginBottom: 14,
      borderWidth: 1,
      borderColor: theme.border,
      shadowColor: theme.textPrimary,
      shadowOpacity: 0.08,
      shadowRadius: 6,
      shadowOffset: { width: 0, height: 2 },
      elevation: 2,
    },
    actionCard: {
      backgroundColor: theme.cardBackground,
      borderRadius: 14,
      paddingVertical: 16,
      paddingHorizontal: 18,
      borderWidth: 1.2,
      borderColor: theme.border,
      marginVertical: 8,
      shadowColor: theme.textPrimary,
      shadowOpacity: 0.08,
      shadowRadius: 6,
      shadowOffset: { width: 0, height: 3 },
      elevation: 2,
    },

    chip: {
      paddingHorizontal: 14,
      paddingVertical: 7,
      backgroundColor: theme.cardBackground,
      borderRadius: 20,
      marginRight: 10,
      marginBottom: 10,
      borderWidth: 1,
      borderColor: theme.border,
    },
    chipText: {
      color: theme.textPrimary,
      fontWeight: "500",
      fontSize: 14,
    },

    image: {
      width: "100%",
      height: 160,
      borderRadius: 12,
      marginBottom: 10,
    },

    toggleRow: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center",
      marginVertical: 10,
    },
    toggleLabel: {
      color: theme.textPrimary,
      fontSize: 15,
      fontWeight: "500",
    },

    modalContainer: {
      flex: 1,
      backgroundColor: "rgba(0,0,0,0.5)",
      justifyContent: "center",
      alignItems: "center",
      padding: 20,
    },
    modalContent: {
      backgroundColor: theme.cardBackground,
      borderRadius: 16,
      padding: 20,
      width: "100%",
      maxHeight: "85%",
      shadowColor: theme.textPrimary,
      shadowOpacity: 0.15,
      shadowRadius: 8,
      shadowOffset: { width: 0, height: 3 },
    },

    divider: {
      height: 1,
      backgroundColor: theme.border,
      marginVertical: 12,
      opacity: 0.5,
    },
  });
