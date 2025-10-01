// app/theme.ts

import { Platform, useColorScheme } from "react-native";

//
// Colors
//
const palette = {
  blue: {
    50: "#eff6ff",
    100: "#dbeafe",
    200: "#bfdbfe",
    300: "#93c5fd",
    400: "#60a5fa",
    500: "#3b82f6", // primary
    600: "#2563eb",
    700: "#1d4ed8",
    800: "#1e40af",
    900: "#1e3a8a",
  },
  orange: {
    50: "#fff7ed",
    100: "#ffedd5",
    200: "#fed7aa",
    300: "#fdba74",
    400: "#fb923c",
    500: "#f97316", // accent
    600: "#ea580c",
    700: "#c2410c",
    800: "#9a3412",
    900: "#7c2d12",
  },
  gray: {
    50: "#f9fafb",
    100: "#f3f4f6",
    200: "#e5e7eb",
    300: "#d1d5db",
    400: "#9ca3af",
    500: "#6b7280",
    600: "#4b5563",
    700: "#374151",
    800: "#1f2937",
    900: "#111827",
  },
  white: "#ffffff",
  black: "#000000",
};

//
// Light & dark themes
//
export const lightTheme = {
  colors: {
    background: palette.gray[50],
    surface: palette.white,
    primary: palette.blue[500],
    primaryText: palette.white,
    secondary: palette.orange[500],
    secondaryText: palette.white,
    text: palette.gray[900],
    mutedText: palette.gray[400],
    border: palette.gray[200],
  },
  typography: {
    fontFamily: Platform.select({
      ios: "System",
      android: "Roboto",
      web: "system-ui, sans-serif",
    }),
    h1: { fontSize: 32, fontWeight: "700", lineHeight: 40 },
    h2: { fontSize: 24, fontWeight: "600", lineHeight: 32 },
    body: { fontSize: 16, fontWeight: "400", lineHeight: 24 },
    small: { fontSize: 14, fontWeight: "400", lineHeight: 20 },
  },
  spacing: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
  },
  radii: {
    sm: 6,
    md: 12,
    lg: 24,
    pill: 999,
  },
  shadows: {
    sm: { shadowColor: palette.black, shadowOpacity: 0.1, shadowRadius: 2 },
    md: { shadowColor: palette.black, shadowOpacity: 0.15, shadowRadius: 6 },
    lg: { shadowColor: palette.black, shadowOpacity: 0.2, shadowRadius: 12 },
  },
};

export const darkTheme = {
  ...lightTheme,
  colors: {
    background: palette.gray[900],
    surface: palette.gray[800],
    primary: palette.blue[400],
    primaryText: palette.black,
    secondary: palette.orange[400],
    secondaryText: palette.black,
    text: palette.gray[50],
    mutedText: palette.gray[300],
    border: palette.gray[700],
  },
};

export const useAppTheme = () => {
    const scheme = useColorScheme();
    return scheme === "dark" ? darkTheme : lightTheme;
}