import React from 'react';
import { BrowserRouter } from 'react-router-dom';
import { AuthProvider } from './app/providers/AuthContext.jsx';
import { RegionProvider } from './app/providers/RegionContext.jsx';
import { LayerProvider } from './app/providers/LayerContext.jsx';
import { SelectionProvider } from './app/providers/SelectionContext.jsx';
import { Header } from './components/layout/Header.jsx';
import { Sidebar } from './components/layout/Sidebar.jsx';
import { MapStatusStrip } from './components/layout/MapStatusStrip.jsx';
import { AppRoutes } from './app/routes/AppRoutes.jsx';

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <RegionProvider>
          <LayerProvider>
            <SelectionProvider>
              <div className="w-screen h-screen flex flex-col overflow-hidden bg-slate-100 select-none">
                {/* Top Header Bar with integrated jurisdiction breadcrumbs */}
                <Header />

                {/* Main Workspace: Sidebar + Operational View */}
                <div className="flex-1 flex overflow-hidden relative">
                  <Sidebar />
                  <main className="flex-1 relative overflow-hidden bg-slate-50">
                    <AppRoutes />
                  </main>
                </div>

                {/* Bottom Operational Status Bar */}
                <MapStatusStrip />
              </div>
            </SelectionProvider>
          </LayerProvider>
        </RegionProvider>
      </AuthProvider>
    </BrowserRouter>
  );
}
