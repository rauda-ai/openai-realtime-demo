import { useState, useEffect } from "react";

// Custom hook to fetch backend tools repeatedly
export function useBackendTools(url: string, intervalMs: number) {
  const [tools, setTools] = useState<any[]>([]);
  const [errorCount, setErrorCount] = useState(0);

  useEffect(() => {
    // Don't try to fetch if URL is empty
    if (!url) return;
    
    let isMounted = true;

    // Implement exponential backoff for failures
    const getBackoffTime = (errorCount: number): number => {
      // Start with intervalMs, then increase based on error count
      // Cap at max 2 minutes (120000ms)
      return Math.min(intervalMs * Math.pow(2, errorCount), 120000);
    };

    const fetchTools = () => {
      // Skip fetch if we've had too many consecutive errors
      // but still allow for recovery after backoff
      if (errorCount > 5) {
        setErrorCount(prev => prev - 1);
        return;
      }

      fetch(url, { signal: AbortSignal.timeout(5000) }) // Add timeout to prevent long-hanging requests
        .then((res) => {
          if (!res.ok) throw new Error(`Error ${res.status}: ${res.statusText}`);
          return res.json();
        })
        .then((data) => {
          if (isMounted && Array.isArray(data)) {
            setTools(data);
            // Reset error count on success
            if (errorCount > 0) setErrorCount(0);
          }
        })
        .catch((error) => {
          // Only log actual errors, not aborted requests
          if (error.name !== 'AbortError') {
            console.error("Error fetching backend tools:", error);
            if (isMounted) setErrorCount(prev => prev + 1);
          }
        });
    };

    fetchTools();
    
    // Use dynamic interval based on error state
    const intervalId = setInterval(fetchTools, 
      errorCount > 0 ? getBackoffTime(errorCount) : intervalMs
    );

    return () => {
      isMounted = false;
      clearInterval(intervalId);
    };
  }, [url, intervalMs, errorCount]);

  return tools;
}
