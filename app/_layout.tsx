import { Stack } from "expo-router";
import { darkTheme, lightTheme } from "./constants/theme";
import { useColorScheme } from "./hooks/use-color-scheme.web";
import { ThemeProvider } from "./providers/theme-provider";

export default function RootLayout() {
  const colorScheme = useColorScheme();

  return (
  <ThemeProvider value={colorScheme === 'dark' ? darkTheme : lightTheme}>
  <Stack screenOptions={{ headerShown: false }} />
  </ThemeProvider>
  );
}
