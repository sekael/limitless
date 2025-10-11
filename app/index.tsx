import { ImageBackground } from "expo-image";
import { Stack } from "expo-router";
import { ThemedText } from "./components/themed-text";
import { styles } from "./styles/index.styles";

export default function Index() {

  return (
    <>
    <Stack.Screen options={{ title: "limitless", headerShown: false }}/>
    <ImageBackground
    source={require("../assets/images/background.jpg")}
    style={styles.background}
    contentFit="cover">
    <ThemedText type='title' textColor='primaryText'>Hello there!</ThemedText>
    <ThemedText type='subtitle' textColor='mutedText'>More is coming soon, maybe ... when I find time!</ThemedText>
    </ImageBackground>
    </>
  );
}
