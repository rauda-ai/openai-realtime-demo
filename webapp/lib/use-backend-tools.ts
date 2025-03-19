import { useState, useEffect } from "react";

// Custom hook to fetch backend tools repeatedly
export function useBackendTools(url: string, intervalMs: number) {
  const [tools, setTools] = useState<any[]>([]);

  useEffect(() => {
    // Don't try to fetch if URL is empty
    if (!url) return;
    
    let isMounted = true;

    const fetchTools = () => {
      fetch(url)
        .then((res) => res.json())
        .then((data) => {
          if (isMounted && Array.isArray(data)) setTools(data);
        })
        .catch((error) => {
          // On failure, we just let it retry after interval
          console.error("Error fetching backend tools:", error);
        });
    };

    fetchTools();
    const intervalId = setInterval(fetchTools, intervalMs);

    return () => {
      isMounted = false;
      clearInterval(intervalId);
    };
  }, [url, intervalMs]);

  return tools;
}
