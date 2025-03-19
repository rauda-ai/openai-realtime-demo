// Environment configuration for the application

// Default to localhost:8081 for development but use environment variable if set
export const WEBSOCKET_SERVER_URL = 
  typeof window !== 'undefined' && (window as any).__NEXT_DATA__?.props?.pageProps?.websocketServerUrl || 
  process.env.NEXT_PUBLIC_WEBSOCKET_SERVER_URL || 
  'http://localhost:8081';

// For WebSocket connections, use wss:// protocol for https and ws:// for http
export const getWebSocketURL = () => {
  if (!WEBSOCKET_SERVER_URL) return 'ws://localhost:8081';
  
  // Replace http:// with ws:// and https:// with wss://
  return WEBSOCKET_SERVER_URL.replace(/^http/, 'ws');
};