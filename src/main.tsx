import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { initializeGoogleAnalytics } from "./analytics";
import App from "./App";
import "./index.css";

initializeGoogleAnalytics();

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);