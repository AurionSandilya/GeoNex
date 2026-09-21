/**
 * Decoupled API Client for SIH 2026 GIS Platform
 * Handles HTTP requests, JWT authorization, and fail-safe fallback handling.
 */

const BASE_URL = import.meta.env.VITE_API_BASE_URL !== undefined 
  ? import.meta.env.VITE_API_BASE_URL 
  : '';
const API_PREFIX = '/api/v1';

/**
 * Clean path formatter ensuring /api/v1 prefix for API routes while allowing root paths
 */
function formatEndpoint(endpoint) {
  if (endpoint.startsWith('/api/v1')) {
    return endpoint;
  }
  if (endpoint === '/health' || endpoint === '/' || endpoint.startsWith('/health') || endpoint.startsWith('/ws')) {
    return endpoint;
  }
  return endpoint.startsWith('/') ? `${API_PREFIX}${endpoint}` : `${API_PREFIX}/${endpoint}`;
}

/**
 * Standard JSON API Fetch helper
 */
export async function apiFetch(endpoint, options = {}) {
  const token = localStorage.getItem('token');
  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...options.headers,
  };

  const path = formatEndpoint(endpoint);
  const fullUrl = BASE_URL ? `${BASE_URL}${path}` : path;

  try {
    const response = await fetch(fullUrl, {
      ...options,
      headers,
    });

    if (response.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
    }

    if (!response.ok) {
      const errData = await response.json().catch(() => ({}));
      throw new Error(errData.detail || `API Error ${response.status}: ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    console.warn(`[apiClient] Fetch to ${fullUrl} failed: ${error.message}. Returning fallback...`);
    throw error;
  }
}

/**
 * Form-urlencoded POST helper for FastAPI OAuth2PasswordRequestForm
 */
export async function apiFormPost(endpoint, formData) {
  const path = formatEndpoint(endpoint);
  const fullUrl = BASE_URL ? `${BASE_URL}${path}` : path;

  const body = new URLSearchParams(formData).toString();

  try {
    const response = await fetch(fullUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body,
    });

    if (response.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
    }

    if (!response.ok) {
      const errData = await response.json().catch(() => ({}));
      throw new Error(errData.detail || `Login Error ${response.status}: ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    console.warn(`[apiClient] Form POST to ${fullUrl} failed: ${error.message}`);
    throw error;
  }
}

