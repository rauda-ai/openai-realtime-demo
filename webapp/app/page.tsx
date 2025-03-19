import CallInterface from "@/components/call-interface";

export default function Page() {
  // This will be available on the client side via __NEXT_DATA__ 
  // and accessed by our config module
  const websocketServerUrl = process.env.NEXT_PUBLIC_WEBSOCKET_SERVER_URL || "http://localhost:8081";
  
  return <CallInterface websocketServerUrl={websocketServerUrl} />;
}
