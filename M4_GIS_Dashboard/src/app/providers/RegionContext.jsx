import { createContext, useContext, useState } from 'react';
import { DEFAULT_DISTRICT, DEFAULT_REGION, DEFAULT_STATE, NORTH_EAST_REGIONS } from '../config/regions.js';

const RegionContext = createContext(null);

export function RegionProvider({ children }) {
  const [selectedRegion, setSelectedRegion] = useState(DEFAULT_REGION);
  const [selectedState, setSelectedState] = useState(DEFAULT_STATE);
  const [selectedDistrict, setSelectedDistrict] = useState(DEFAULT_DISTRICT);
  const [selectedSubdivision, setSelectedSubdivision] = useState(null);

  const selectDistrictById = (districtId) => {
    for (const reg of NORTH_EAST_REGIONS) {
      for (const st of reg.states) {
        const dist = st.districts.find(d => d.id === districtId);
        if (dist) {
          setSelectedRegion(reg);
          setSelectedState(st);
          setSelectedDistrict(dist);
          setSelectedSubdivision(null);
          return dist;
        }
      }
    }
    return null;
  };

  const value = {
    regions: NORTH_EAST_REGIONS,
    selectedRegion,
    setSelectedRegion,
    selectedState,
    setSelectedState,
    selectedDistrict,
    setSelectedDistrict,
    selectedSubdivision,
    setSelectedSubdivision,
    selectDistrictById
  };

  return (
    <RegionContext.Provider value={value}>
      {children}
    </RegionContext.Provider>
  );
}

export function useRegion() {
  const context = useContext(RegionContext);
  if (!context) {
    throw new Error('useRegion must be used within a RegionProvider');
  }
  return context;
}
