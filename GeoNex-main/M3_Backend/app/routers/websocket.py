"""
app/routers/websocket.py

WebSocket Manager and Router for real-time dashboard updates (Phase 26):
- Broadcasts high-risk alerts to M4 GIS Dashboard
- Broadcasts newly verified reports to connected clients
"""

from typing import List
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

router = APIRouter(prefix="/ws", tags=["Real-time WebSockets"])


class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast(self, message: dict):
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except Exception:
                pass


manager = ConnectionManager()


@router.websocket("/dashboard")
async def websocket_dashboard(websocket: WebSocket):
    """
    WebSocket endpoint for real-time GIS dashboard push updates.
    """
    await manager.connect(websocket)
    try:
        # Send initial connection confirmation
        await websocket.send_json({
            "event": "CONNECTED",
            "message": "Real-time landslide monitoring stream connected."
        })
        while True:
            # Keep connection open and listen for client pings
            data = await websocket.receive_text()
            await websocket.send_json({"event": "PONG", "received": data})
    except WebSocketDisconnect:
        manager.disconnect(websocket)
