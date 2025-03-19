// Environment configuration for the application
import getConfig from 'next/config';

// Get static config values from next.config.mjs
// These were set at build time
const { publicRuntimeConfig, serverRuntimeConfig } = getConfig() || { 
  publicRuntimeConfig: {}, 
  serverRuntimeConfig: {} 
};

// First try the build-time config from next.config.mjs,
// then try the window.__NEXT_DATA__ from server-side props,
// then try environment variables in case they were set after build,
// finally fall back to a default value
export const WEBSOCKET_SERVER_URL = 
  // Build-time config
  publicRuntimeConfig?.WEBSOCKET_SERVER_URL ||
  // Server-side props
  (typeof window !== 'undefined' && (window as any).__NEXT_DATA__?.props?.pageProps?.websocketServerUrl) || 
  // Runtime env var
  (typeof window !== 'undefined' ? process.env.NEXT_PUBLIC_WEBSOCKET_SERVER_URL : process.env.WEBSOCKET_SERVER_URL) || 
  // Default
  'http://localhost:8081';

// For WebSocket connections, use wss:// protocol for https and ws:// for http
export const getWebSocketURL = () => {
  if (!WEBSOCKET_SERVER_URL) return 'ws://localhost:8081';
  
  // Replace http:// with ws:// and https:// with wss://
  return WEBSOCKET_SERVER_URL.replace(/^http/, 'ws');
};