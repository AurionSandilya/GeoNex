import React, { createContext, useContext, useState } from 'react';

const SelectionContext = createContext(null);

export function SelectionProvider({ children }) {
  const [selectedFeature, setSelectedFeature] = useState(null);
  const [mapViewState, setMapViewState] = useState({
    center: [93.65, 27.20],
    zoom: 10,
    pitch: 0,
    bearing: 0
  });

  const selectFeature = (feature, options = {}) => {
    setSelectedFeature(feature);
    if (feature && feature.coordinates) {
      setMapViewState(prev => ({
        ...prev,
        center: feature.coordinates,
        zoom: options.zoom || 13,
        timestamp: Date.now()
      }));
    }
  };

  const clearSelection = () => {
    setSelectedFeature(null);
  };

  return (
    <SelectionContext.Provider
      value={{
        selectedFeature,
        selectFeature,
        clearSelection,
        mapViewState,
        setMapViewState,
      }}
    >
      {children}
    </SelectionContext.Provider>
  );
}

export function useSelection() {
  const context = useContext(SelectionContext);
  if (!context) {
    throw new Error('useSelection must be used within a SelectionProvider');
  }
  return context;
}
