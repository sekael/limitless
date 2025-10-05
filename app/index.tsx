import { ImageBackground } from "expo-image";
import { Stack } from "expo-router";
import { Text } from "react-native";
import { useTheme } from "./providers/ThemeProvider";
import { styles } from "./styles/index.styles";

export default function Index() {
  const theme = useTheme().theme; 
  return (
    <>
    <Stack.Screen options={{ title: "limitless", headerShown: false }}/>
    <ImageBackground
    source={require("../assets/images/background.jpg")}
    style={styles.background}
    contentFit="cover">
    <Text style={[styles.title, { color: theme.colors.primaryText}]}>Hello there!</Text>
    <Text style={[styles.subtitle, {color: theme.colors.mutedText }]}>More is coming soon, maybe ... when I find time!</Text>
    </ImageBackground>
    </>
  );
}
