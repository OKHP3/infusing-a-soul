const measurementId = "G-VJ1BKXS27H";

type Gtag = (...args: unknown[]) => void;

declare global {
  interface Window {
    dataLayer?: IArguments[];
    gtag?: Gtag;
  }
}

export function initializeGoogleAnalytics(): () => void {
  if (!measurementId) return () => {};
  if (!/^G-[A-Z0-9]{6,}$/i.test(measurementId)) {
    console.error("Google Analytics is disabled: VITE_GA_MEASUREMENT_ID is not a valid GA4 Measurement ID.");
    return () => {};
  }

  window.dataLayer = window.dataLayer ?? [];
  window.gtag = function gtag(...args: unknown[]) {
    window.dataLayer?.push(arguments);
  };

  const script = document.createElement("script");
  script.async = true;
  script.src = `https://www.googletagmanager.com/gtag/js?id=${encodeURIComponent(measurementId)}`;
  script.dataset.googleAnalytics = "true";
  document.head.appendChild(script);

  window.gtag("js", new Date());
  window.gtag("config", measurementId, { send_page_view: false });

  const sendPageView = () => {
    window.gtag?.("event", "page_view", {
      page_title: document.title,
      page_location: window.location.href,
      page_path: `${window.location.pathname}${window.location.hash}`,
    });
  };

  window.addEventListener("hashchange", sendPageView);
  sendPageView();

  return () => {
    window.removeEventListener("hashchange", sendPageView);
    script.remove();
    delete window.gtag;
  };
}