import React, { createContext, ReactNode, useContext } from "react";
import { lightTheme, useAppTheme } from "../theme";

type Theme = typeof lightTheme;

const ThemeContext = createContext<Theme>(lightTheme);

export const ThemeProvider = ({ children }: { children: ReactNode }) => {
  const theme = useAppTheme();
  return <ThemeContext.Provider value={theme}>{children}</ThemeContext.Provider>;
};

export const useTheme = () => useContext(ThemeContext);
