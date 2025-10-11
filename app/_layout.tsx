import { Stack } from "expo-router";
import { darkTheme, lightTheme } from "./constants/theme";
import { useColorScheme } from "./hooks/use-color-scheme.web";
import { ThemeProvider } from "./providers/ThemeProvider";

export default function RootLayout() {
  const colorScheme = useColorScheme();

  return (
  <ThemeProvider value={colorScheme === 'dark' ? darkTheme : lightTheme}>
  <Stack screenOptions={{ headerShown: false }} />
  </ThemeProvider>
  );
}
