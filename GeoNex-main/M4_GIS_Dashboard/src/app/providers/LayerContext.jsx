import React, { createContext, useContext, useState } from 'react';

const LayerContext = createContext(null);

export function LayerProvider({ children }) {
  // Layer visibility toggles
  const [layers, setLayers] = useState({
    riskZones: true,
    activeWarnings: true,
    fieldReports: true,
    roadNetwork: true,
    infrastructure: true,
    villages: true,
    environmentalGrid: false,
    emergencyPriorities: true,
  });

  // Layer opacity controls
  const [opacity, setOpacity] = useState({
    riskZones: 0.6,
    roadNetwork: 0.8,
    environmentalGrid: 0.5,
  });

  // Basemap selection (osm-standard, osm-topo, osm-satellite, osm-dark, osm-light)
  const [activeBasemap, setActiveBasemap] = useState('osm-standard');

  const toggleLayer = (layerKey) => {
    setLayers(prev => ({ ...prev, [layerKey]: !prev[layerKey] }));
  };

  const updateOpacity = (layerKey, value) => {
    setOpacity(prev => ({ ...prev, [layerKey]: value }));
  };

  return (
    <LayerContext.Provider
      value={{
        layers,
        toggleLayer,
        opacity,
        updateOpacity,
        activeBasemap,
        setActiveBasemap,
      }}
    >
      {children}
    </LayerContext.Provider>
  );
}

export function useLayers() {
  const context = useContext(LayerContext);
  if (!context) {
    throw new Error('useLayers must be used within a LayerProvider');
  }
  return context;
}
