import { useEffect, useState, useRef, useCallback } from 'react';

/**
 * Custom hook for real-time WebSocket connection to /ws/dashboard.
 * Handles connection, disconnection, auto-reconnection, and incoming event broadcasts.
 */
export function useDashboardSocket(onEventReceived) {
  const [isConnected, setIsConnected] = useState(false);
  const [statusText, setStatusText] = useState('CONNECTING');
  const [lastMessageTime, setLastMessageTime] = useState(null);

  const socketRef = useRef(null);
  const reconnectTimeoutRef = useRef(null);
  const isMountedRef = useRef(true);
  const onEventReceivedRef = useRef(onEventReceived);
  const connectRef = useRef(null);

  // Keep callback ref updated without triggering reconnects
  useEffect(() => {
    onEventReceivedRef.current = onEventReceived;
  }, [onEventReceived]);

  const connect = useCallback(() => {
    if (!isMountedRef.current) return;

    let wsUrl;
    if (import.meta.env.VITE_WS_BASE_URL) {
      wsUrl = `${import.meta.env.VITE_WS_BASE_URL}/ws/dashboard`;
    } else if (typeof window !== 'undefined') {
      const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
      wsUrl = `${protocol}//${window.location.host}/ws/dashboard`;
    } else {
      wsUrl = 'ws://localhost:8000/ws/dashboard';
    }

    try {
      const ws = new WebSocket(wsUrl);
      socketRef.current = ws;

      ws.onopen = () => {
        if (!isMountedRef.current) return;
        setIsConnected(true);
        setStatusText('LIVE');
      };

      ws.onmessage = (event) => {
        if (!isMountedRef.current) return;
        try {
          const data = JSON.parse(event.data);
          setLastMessageTime(new Date());
          onEventReceivedRef.current?.(data);
        } catch {
          console.warn('[useDashboardSocket] Non-JSON payload received:', event.data);
        }
      };

      ws.onerror = () => {
        if (!isMountedRef.current) return;
        console.warn('[useDashboardSocket] WebSocket connection error');
        setStatusText('RECONNECTING');
      };

      ws.onclose = () => {
        if (!isMountedRef.current) return;
        setIsConnected(false);
        setStatusText('DISCONNECTED');
        reconnectTimeoutRef.current = setTimeout(() => {
          if (isMountedRef.current) {
            connectRef.current?.();
          }
        }, 5000);
      };
    } catch {
      if (!isMountedRef.current) return;
      setIsConnected(false);
      setStatusText('OFFLINE');
    }
  }, []);

  useEffect(() => {
    connectRef.current = connect;
  }, [connect]);

  useEffect(() => {
    isMountedRef.current = true;
    connect();

    return () => {
      isMountedRef.current = false;
      if (reconnectTimeoutRef.current) clearTimeout(reconnectTimeoutRef.current);
      if (socketRef.current) socketRef.current.close();
    };
  }, [connect]);

  return {
    isConnected,
    statusText,
    lastMessageTime,
  };
}
