import { MapLibreViewer } from '../../components/map/MapLibreViewer.jsx';
import { WarningPriorityQueue } from '../../components/warningQueue/WarningPriorityQueue.jsx';

export function Dashboard() {
  return (
    <div className="w-full h-full relative overflow-hidden flex flex-col">
      {/* Primary GIS Map Container occupying ~75-80% of workspace */}
      <div className="flex-1 w-full h-full relative">
        <MapLibreViewer />

        {/* Floating Warning Priority Queue (Left Side) */}
        <div className="absolute top-3 left-3 z-20 pointer-events-auto">
          <WarningPriorityQueue />
        </div>
      </div>
    </div>
  );
}
