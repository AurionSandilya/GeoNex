/**
 * Authentication Service for SIH 2026 GIS Platform
 * Communicates with FastAPI /api/v1/auth endpoints
 */

import { apiFetch, apiFormPost } from '../apiClient.js';

export const authService = {
  /**
   * Log in user using OAuth2 password flow (form-urlencoded)
   * FastAPI OAuth2PasswordRequestForm expects 'username' (which is the email) and 'password'.
   */
  async login(email, password) {
    const data = await apiFormPost('/auth/login', {
      username: email,
      password: password,
    });
    if (data.access_token) {
      localStorage.setItem('token', data.access_token);
      if (data.user) {
        localStorage.setItem('user', JSON.stringify(data.user));
      }
    }
    return data;
  },

  /**
   * Register a new citizen / field user
   */
  async register(userData) {
    return await apiFetch('/auth/register', {
      method: 'POST',
      body: JSON.stringify(userData),
    });
  },

  /**
   * Get current authenticated user profile
   */
  async getMe() {
    return await apiFetch('/auth/me');
  },

  /**
   * Log out and clear saved credentials
   */
  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  }
};
