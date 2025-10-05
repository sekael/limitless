import React, { createContext, ReactNode, useContext, useEffect, useState } from "react";
import { Appearance } from "react-native";
import { darkTheme, lightTheme } from "../theme";

type Theme = typeof lightTheme;
type ThemeMode = "light" | "dark";

interface ThemeContextValue {
  theme: Theme;
  mode: ThemeMode;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextValue>({
  theme: lightTheme,
  mode: "light",
  toggleTheme: () => {},
});

export const ThemeProvider = ({ children }: { children: ReactNode }) => {
  const [mode, setMode]= useState<ThemeMode>(
    Appearance.getColorScheme() as ThemeMode || "light"
  );

  // iOS/Android theme changes
  useEffect(() => {
    const listener = Appearance.addChangeListener(({ colorScheme }) => {
      if (colorScheme) setMode(colorScheme);
    });
    return () => listener.remove();
  }, []);

  // Handle web-browsers
  useEffect(() => {
    if (typeof(window) !== undefined && window.matchMedia) {
      const mql = window.matchMedia("(prefers-color-scheme: dark)");
      const handleChange = (e: MediaQueryListEvent) => 
        setMode(e.matches ? "dark" : "light");
      setMode(mql.matches ? "dark" : "light");
      mql.addEventListener("change", handleChange);
      return () => mql.removeEventListener("change", handleChange);
    }
  }, []);

  const toggleTheme = () => 
    setMode((prev) => (prev === "light" ? "dark": "light"));

  const theme = mode === "dark" ? darkTheme : lightTheme;


  return (
  <ThemeContext.Provider value={{ theme, mode, toggleTheme }}>
    {children}
  </ThemeContext.Provider>
  );
};

export const useTheme = () => useContext(ThemeContext);
