import React, { createContext, ReactNode, useContext, useState } from "react";

type Theme = {
  background: string;
  card: string;
  textPrimary: string;
  textSecondary: string;
  inputBackground: string;
  accent: string;
  error: string;
  success: string;
  overlay: string;
};

type ThemeContextType = {
  isDark: boolean;
  theme: Theme;
  toggleTheme: () => void;
};

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

const lightTheme: Theme = {
  background: "#FFFFFF",
  card: "#F3F4F6",
  textPrimary: "#111827",
  textSecondary: "#6B7280",
  inputBackground: "#E5E7EB",
  accent: "#6366F1",
  error: "#DC2626",
  success: "#16A34A",
  overlay: "rgba(0,0,0,0.3)",
};

const darkTheme: Theme = {
  background: "#1E1E2E",
  card: "#313244",
  textPrimary: "#FFFFFF",
  textSecondary: "#A6ADC8",
  inputBackground: "#45475A",
  accent: "#CBA6F7",
  error: "#F38BA8",
  success: "#A6E3A1",
  overlay: "rgba(0,0,0,0.6)",
};

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [isDark, setIsDark] = useState(false);

  const toggleTheme = () => {
    setIsDark((prev) => !prev);
  };

  const theme = isDark ? darkTheme : lightTheme;

  return (
    <ThemeContext.Provider value={{ isDark, theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);

  if (!context) {
    throw new Error("useTheme must be used inside a ThemeProvider");
  }

  return context;
}
