import { Stack } from "expo-router";
import { Platform } from "react-native";
import { ThemePicker } from "./components/ThemePicker";
import { ThemeProvider } from "./providers/ThemeProvider";

export default function RootLayout() {
  const isWeb = Platform.OS === "web";
  return (
  <ThemeProvider>
  <Stack screenOptions={{ headerShown: false }} />
  { isWeb && <ThemePicker/>}
  </ThemeProvider>
  );
}
