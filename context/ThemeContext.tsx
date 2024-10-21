// ThemeContext.tsx
'use client';

import React, {
    createContext,
    useState,
    ReactNode,
    useContext,
    useEffect,
    SetStateAction,
    Dispatch
} from 'react';

interface ThemeContextProps {
    theme: string;
    setTheme: Dispatch<SetStateAction<string>>;
    address: string,
    setAddress: Dispatch<SetStateAction<string>>
}

const ThemeContext = createContext<ThemeContextProps>({
    theme: 'dark',
    setTheme: () => { },
    address: "",
    setAddress: () => {},
});

const ThemeProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
    const [theme, setTheme] = useState<string>('light');
    const [address, setAddress] = useState<string>("")

    useEffect(() => {
        const savedTheme = localStorage.getItem('theme') || 'dark';
        setTheme(savedTheme);
    }, []);

    useEffect(() => {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('theme', theme);
    }, [theme]);


    return (
        <ThemeContext.Provider value={{
            theme,
            setTheme,
            address,
            setAddress
        }}>
            {children}
        </ThemeContext.Provider>
    );
};

const useTheme = () => {
    const context = useContext(ThemeContext);
    if (!context) {
        throw new Error('useTheme must be used within a ThemeProvider');
    }
    return context;
};

export { ThemeProvider, useTheme };
