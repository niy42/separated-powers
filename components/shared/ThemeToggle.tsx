import React from 'react';
import { PiToggleLeftFill, PiToggleRightFill } from "react-icons/pi";
import { MoonIcon, SunIcon } from '@heroicons/react/24/solid'; // Use any icons you prefer
import { useTheme } from '@/context/ThemeContext';  // Import the theme context

const ThemeToggle = ({ currentTheme, setTheme }: any) => {
    const isDarkMode = currentTheme === 'dark';

    const handleToggle = () => {
        setTheme(isDarkMode ? 'light' : 'dark');
        console.log(`Theme toggled to: ${isDarkMode ? 'light' : 'dark'}`);  // Log the theme toggle
    };

    return (
        <button
            onClick={handleToggle}
            className={`flex items-center justify-center p-2 rounded-full transition-colors duration-300 cursor-pointer
        ${isDarkMode ? 'bg-gray-700 text-yellow-300 hover:bg-gray-600' : 'bg-yellow-300 text-gray-700 hover:bg-yellow-200'}`}
            aria-label="Toggle theme"
        >
            {isDarkMode ? <PiToggleRightFill className="h-6 w-6" /> : <PiToggleLeftFill className="h-6 w-6" />}
        </button>
    );
};

export default ThemeToggle;
