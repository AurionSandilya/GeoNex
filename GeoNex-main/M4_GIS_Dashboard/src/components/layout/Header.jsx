import React, { useEffect, useState } from 'react';
import { MountainSnow, ChevronRight, RotateCcw, WifiOff } from 'lucide-react';
import { useRegion } from '../../app/providers/RegionContext.jsx';
import { useDashboardSocket } from '../../hooks/useDashboardSocket.js';
import { DEFAULT_REGION, DEFAULT_STATE, DEFAULT_DISTRICT } from '../../app/config/regions.js';

function useLiveClock() {
  const [time, setTime] = useState(() => {
    return new Date().toLocaleTimeString('en-IN', {
      hour: '2-digit', minute: '2-digit', second: '2-digit',
      timeZone: 'Asia/Kolkata', hour12: false
    });
  });

  useEffect(() => {
    const id = setInterval(() => {
      setTime(new Date().toLocaleTimeString('en-IN', {
        hour: '2-digit', minute: '2-digit', second: '2-digit',
        timeZone: 'Asia/Kolkata', hour12: false
      }));
    }, 1000);
    return () => clearInterval(id);
  }, []);

  return time;
}

export function Header() {
  const clock = useLiveClock();
  const { isConnected, statusText } = useDashboardSocket();
  const {
    selectedRegion,
    setSelectedRegion,
    selectedState,
    setSelectedState,
    selectedDistrict,
    setSelectedDistrict,
    selectedSubdivision,
    setSelectedSubdivision
  } = useRegion();

  const handleStateChange = (e) => {
    const stateId = e.target.value;
    const foundState = selectedRegion?.states?.find(s => s.id === stateId);
    if (foundState) {
      setSelectedState(foundState);
      if (foundState.districts && foundState.districts.length > 0) {
        setSelectedDistrict(foundState.districts[0]);
      } else {
        setSelectedDistrict({ id: 'none', name: 'No Districts', areas: [] });
      }
      setSelectedSubdivision(null);
    }
  };

  const handleDistrictChange = (e) => {
    const distId = e.target.value;
    const foundDist = selectedState.districts?.find(d => d.id === distId);
    if (foundDist) {
      setSelectedDistrict(foundDist);
      setSelectedSubdivision(null);
    }
  };

  const handleSubdivisionChange = (e) => {
    const areaId = e.target.value;
    if (!areaId) {
      setSelectedSubdivision(null);
      return;
    }
    const foundArea = selectedDistrict.areas?.find(a => a.id === areaId);
    setSelectedSubdivision(foundArea || null);
  };

  const handleReset = () => {
    setSelectedRegion(DEFAULT_REGION);
    setSelectedState(DEFAULT_STATE);
    setSelectedDistrict(DEFAULT_DISTRICT);
    setSelectedSubdivision(null);
  };

  const hasAreas = selectedDistrict?.areas && selectedDistrict.areas.length > 0;
  const isCustomSelection = selectedState?.id !== DEFAULT_STATE.id || selectedDistrict?.id !== DEFAULT_DISTRICT.id || selectedSubdivision !== null;

  return (
    <header className="h-12 bg-white border-b border-slate-200/90 px-4 flex items-center justify-between z-30 shrink-0 select-none shadow-2xs">
      {/* Left: Clean Brand */}
      <div className="flex items-center gap-3 shrink-0">
        <div className="w-7 h-7 rounded-lg bg-sky-600 text-white flex items-center justify-center shadow-xs">
          <MountainSnow className="w-4 h-4" aria-hidden="true" />
        </div>
        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-900 text-sm tracking-tight">NER-LEWS</span>
          <span className="h-3.5 w-px bg-slate-200"></span>
          <span className="text-xs text-slate-500 font-medium">Early Warning System</span>
        </div>
      </div>

      {/* Center: Integrated Clean Breadcrumb Selector */}
      <div className="hidden md:flex items-center bg-slate-50 border border-slate-200/90 rounded-lg px-2 py-1 text-xs">
        {/* State */}
        <select
          value={selectedState?.id || ''}
          onChange={handleStateChange}
          className="bg-transparent text-slate-700 hover:text-slate-900 font-medium outline-none cursor-pointer pr-1 py-0.5"
          aria-label="Select State"
        >
          {selectedRegion?.states?.map(state => (
            <option key={state.id} value={state.id}>
              {state.name}
            </option>
          ))}
        </select>

        <ChevronRight className="w-3.5 h-3.5 text-slate-400 shrink-0 mx-1" aria-hidden="true" />

        {/* District */}
        <select
          value={selectedDistrict?.id || ''}
          onChange={handleDistrictChange}
          className="bg-transparent text-slate-900 font-semibold outline-none cursor-pointer pr-1 py-0.5"
          aria-label="Select District"
        >
          {selectedState?.districts && selectedState.districts.length > 0 ? (
            selectedState.districts.map(dist => (
              <option key={dist.id} value={dist.id}>
                {dist.name}
              </option>
            ))
          ) : (
            <option value="none">No Districts</option>
          )}
        </select>

        {/* Sector / Sub-division */}
        {hasAreas && (
          <>
            <ChevronRight className="w-3.5 h-3.5 text-slate-400 shrink-0 mx-1" aria-hidden="true" />
            <select
              value={selectedSubdivision?.id || ''}
              onChange={handleSubdivisionChange}
              className="bg-transparent text-slate-600 hover:text-slate-900 font-medium outline-none cursor-pointer max-w-[130px] truncate py-0.5"
              aria-label="Select Sector"
            >
              <option value="">All Sectors</option>
              {selectedDistrict.areas.map(area => (
                <option key={area.id} value={area.id}>
                  {area.name}
                </option>
              ))}
            </select>
          </>
        )}

        {/* Reset button if filtered */}
        {isCustomSelection && (
          <button
            onClick={handleReset}
            className="ml-1.5 p-1 text-slate-400 hover:text-slate-700 rounded transition-colors cursor-pointer"
            title="Reset to default (Papum Pare)"
            aria-label="Reset selection"
          >
            <RotateCcw className="w-3 h-3" />
          </button>
        )}
      </div>

      {/* Right: Telemetry & User */}
      <div className="flex items-center gap-3 shrink-0">
        {/* Live WebSocket Feed */}
        <div className={`flex items-center gap-1.5 text-xs px-2.5 py-0.5 rounded-full font-medium border ${isConnected
            ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
            : 'bg-amber-50 text-amber-800 border-amber-200'
          }`}>
          {isConnected ? (
            <>
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
              <span className="font-semibold text-[11px] tracking-wide">LIVE</span>
            </>
          ) : (
            <>
              <WifiOff className="w-3 h-3 text-amber-600" aria-hidden="true" />
              <span className="text-[11px]">{statusText}</span>
            </>
          )}
        </div>

        {/* Live IST Clock */}
        <div className="hidden sm:block text-xs font-mono text-slate-500">
          {clock} <span className="text-[10px] text-slate-400">IST</span>
        </div>

        <span className="hidden sm:block h-3.5 w-px bg-slate-200"></span>

        {/* User Info */}
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded-full bg-slate-800 text-white flex items-center justify-center font-bold text-[10px]">
            OP
          </div>
          <span className="hidden lg:inline text-xs font-medium text-slate-700">
            DDMO Yupia
          </span>
        </div>
      </div>
    </header>
  );
}
