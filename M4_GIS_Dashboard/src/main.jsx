import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './index.css';        // Global reset: html/body/root full-screen layout
import './styles/index.css'; // GIS design tokens + MapLibre GL CSS

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
