import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { authService } from '../../services/auth/authService.js';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    try {
      const stored = localStorage.getItem('user');
      return stored ? JSON.parse(stored) : null;
    } catch {
      return null;
    }
  });
  const [token, setToken] = useState(() => localStorage.getItem('token') || null);
  const [loading, setLoading] = useState(true);

  // Validate token with backend on initial load if present
  useEffect(() => {
    async function validateSession() {
      if (token) {
        try {
          const userData = await authService.getMe();
          setUser(userData);
          localStorage.setItem('user', JSON.stringify(userData));
        } catch {
          // Token is expired or backend unreachable
          // Keep local session if backend is temporarily offline
          console.warn('[AuthContext] Could not validate token with backend');
        }
      }
      setLoading(false);
    }
    validateSession();
  }, [token]);

  const login = useCallback(async (email, password) => {
    const res = await authService.login(email, password);
    setToken(res.access_token);
    if (res.user) {
      setUser(res.user);
    }
    return res;
  }, []);

  const register = useCallback(async (userData) => {
    return await authService.register(userData);
  }, []);

  const logout = useCallback(() => {
    authService.logout();
    setToken(null);
    setUser(null);
  }, []);

  const value = {
    user,
    token,
    loading,
    isAuthenticated: Boolean(token),
    login,
    register,
    logout,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
