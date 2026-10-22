import { useEffect, useRef, useState } from "react";
import {
  ArrowDown,
  ArrowRight,
  BookOpen,
  Braces,
  Check,
  Copy,
  Cpu,
  Flame,
  Menu,
  Play,
  ShieldCheck,
  Sparkles,
  Terminal,
  X,
} from "lucide-react";
import { souls, stages } from "./generated/public-content";

type Pyodide = {
  runPythonAsync(code: string): Promise<unknown>;
  setStdout(options: { batched: (message: string) => void }): void;
  setStderr(options: { batched: (message: string) => void }): void;
};

declare global {
  interface Window {
    loadPyodide?: (options: { indexURL: string }) => Promise<Pyodide>;
  }
}

const PYODIDE_VERSION = "314.0.7";
const PYODIDE_URL = `https://cdn.jsdelivr.net/pyodide/v${PYODIDE_VERSION}/full/`;
const PYODIDE_LOAD_TIMEOUT_MS = 15_000;

const defaultCode = `# This runs entirely in your browser.
signals = {
    "voice": 0.92,
    "procedure": 0.81,
    "context": 0.76,
    "tools": 0.64,
}

weighted = sum(signals.values()) / len(signals)
print(f"Soul coherence: {weighted:.0%}")
print("Signal map:")
for layer, strength in signals.items():
    print(f"  {layer:<10} {'█' * round(strength * 10)}")`;

function App() {
  const [menuOpen, setMenuOpen] = useState(false);
  const [code, setCode] = useState(defaultCode);
  const [output, setOutput] = useState("Python runtime standing by.");
  const [pyStatus, setPyStatus] = useState<"idle" | "loading" | "ready" | "running" | "error">("idle");
  const [copied, setCopied] = useState(false);
  const pyodide = useRef<Pyodide | null>(null);
  const pyodideLoad = useRef<Promise<Pyodide> | null>(null);
  const loadGeneration = useRef(0);
  const scriptCleanup = useRef<(() => void) | null>(null);
  const mounted = useRef(true);

  useEffect(() => {
    mounted.current = true;
    const reveal = new IntersectionObserver(
      (entries) => entries.forEach((entry) => entry.isIntersecting && entry.target.classList.add("is-visible")),
      { threshold: 0.12 },
    );
    document.querySelectorAll(".reveal").forEach((el) => reveal.observe(el));
    return () => {
      mounted.current = false;
      loadGeneration.current += 1;
      scriptCleanup.current?.();
      reveal.disconnect();
    };
  }, []);

  function loadPyodideScript() {
    if (window.loadPyodide) return Promise.resolve();
    return new Promise<void>((resolve, reject) => {
      const script = document.createElement("script");
      let settled = false;
      const finish = (error?: Error) => {
        if (settled) return;
        settled = true;
        window.clearTimeout(timer);
        script.onload = null;
        script.onerror = null;
        scriptCleanup.current = null;
        if (error) {
          script.remove();
          reject(error);
        } else {
          resolve();
        }
      };
      const timer = window.setTimeout(
        () => finish(new Error("Pyodide script loading timed out. Check your connection and retry.")),
        PYODIDE_LOAD_TIMEOUT_MS,
      );
      scriptCleanup.current = () =>
        finish(new Error("Pyodide script loading was cancelled. Retry when ready."));
      script.src = `${PYODIDE_URL}pyodide.js`;
      script.onload = () => finish();
      script.onerror = () => finish(new Error("Could not load Pyodide. Check your connection and retry."));
      document.head.appendChild(script);
    });
  }

  async function initializePython(generation: number) {
    await loadPyodideScript();
    if (!window.loadPyodide) throw new Error("Pyodide did not initialize. Please retry.");
    const initialization = window.loadPyodide({ indexURL: PYODIDE_URL });
    let timer = 0;
    const timeout = new Promise<never>((_, reject) => {
      timer = window.setTimeout(
        () => reject(new Error("Pyodide initialization timed out. Check your connection and retry.")),
        PYODIDE_LOAD_TIMEOUT_MS,
      );
    });
    try {
      const runtime = await Promise.race([initialization, timeout]);
      if (generation !== loadGeneration.current) {
        throw new Error("Pyodide loading was cancelled. Retry when ready.");
      }
      pyodide.current = runtime;
      return runtime;
    } finally {
      window.clearTimeout(timer);
    }
  }

  function loadPython() {
    if (pyodide.current) return Promise.resolve(pyodide.current);
    if (pyodideLoad.current) return pyodideLoad.current;
    const generation = ++loadGeneration.current;
    setPyStatus("loading");
    setOutput("Heating the Python runtime...");
    const pending = initializePython(generation)
      .then((runtime) => {
        if (mounted.current && generation === loadGeneration.current) setPyStatus("ready");
        return runtime;
      })
      .catch((error: unknown) => {
        if (generation === loadGeneration.current) loadGeneration.current += 1;
        throw error;
      })
      .finally(() => {
        if (pyodideLoad.current === pending) pyodideLoad.current = null;
      });
    pyodideLoad.current = pending;
    return pending;
  }

  async function runPython() {
    try {
      const runtime = await loadPython();
      setPyStatus("running");
      const lines: string[] = [];
      runtime.setStdout({ batched: (message) => lines.push(message) });
      runtime.setStderr({ batched: (message) => lines.push(message) });
      const result = await runtime.runPythonAsync(code);
      if (result !== undefined && result !== null) lines.push(String(result));
      setOutput(lines.join("\n") || "Execution complete.");
      setPyStatus("ready");
    } catch (error) {
      if (mounted.current) {
        setOutput(error instanceof Error ? error.message : "Python execution failed.");
        setPyStatus("error");
      }
    }
  }

  async function copyCode() {
    await navigator.clipboard.writeText(code);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1600);
  }

  return (
    <div className="app-shell">
      <header className="site-header">
        <a className="brand" href="#top" aria-label="Infusing a Soul home">
          <span className="brand-forge"><Flame size={19} strokeWidth={2.5} /></span>
          <span>INFUSING A SOUL</span>
          <i>P³</i>
        </a>
        <nav className={menuOpen ? "nav-links open" : "nav-links"} aria-label="Primary navigation">
          <a href="#method" onClick={() => setMenuOpen(false)}>The method</a>
          <a href="#souls" onClick={() => setMenuOpen(false)}>The crypt</a>
          <a href="#workbench" onClick={() => setMenuOpen(false)}>Workbench</a>
          <a className="nav-cta" href="https://github.com/OKHP3/infusing-a-soul">View source <ArrowRight size={15} /></a>
        </nav>
        <button className="menu-button" onClick={() => setMenuOpen(!menuOpen)} aria-label="Toggle navigation">
          {menuOpen ? <X /> : <Menu />}
        </button>
      </header>

      <main id="top">
        <section className="hero">
          <div className="hero-grid" aria-hidden="true" />
          <div className="hero-kicker"><span>FIELD NOTE 001</span> PERSONA ARCHITECTURE</div>
          <h1>
            Local AI is generic
            <span>until you give it a soul.</span>
          </h1>
          <p className="hero-copy">
            A practical architecture for turning a human corpus into a distinct, persistent AI identity that runs privately, locally, and on your terms.
          </p>
          <div className="hero-actions">
            <a className="button button-primary" href="#method">Enter the forge <ArrowDown size={17} /></a>
            <a className="button button-quiet" href="#workbench"><Terminal size={17} /> Open workbench</a>
          </div>
          <div className="hero-readout" aria-label="Project principles">
            <div><strong>PRIVATE</strong><span>Inference stays local</span></div>
            <div><strong>PERSISTENT</strong><span>Identity survives sessions</span></div>
            <div><strong>PORTABLE</strong><span>Files, not a subscription</span></div>
          </div>
        </section>

        <section className="manifesto">
          <div className="manifesto-mark"><Braces size={36} /></div>
          <p>“This is not prompt engineering.<br /><strong>It is persona architecture.</strong>”</p>
        </section>

        <section className="section" id="method">
          <div className="section-heading reveal">
            <div>
              <span className="eyebrow">THE METHOD / 04 STAGES</span>
              <h2>Build the identity.<br />Protect the signal.</h2>
            </div>
            <p>A lean boot layer, deep references on demand, and a clear boundary between who the agent is and what it can do.</p>
          </div>
          <div className="stage-grid">
            {stages.map((stage) => (
              <article className="stage-card reveal" key={stage.n}>
                <div className="stage-top"><span>{stage.n}</span><small>{stage.tag}</small></div>
                <h3>{stage.title}</h3>
                <p>{stage.body}</p>
                <div className="stage-line" />
              </article>
            ))}
          </div>
        </section>

        <section className="architecture section">
          <div className="arch-copy reveal">
            <span className="eyebrow">THREE-LAYER SYSTEM</span>
            <h2>One identity.<br />Clean separation.</h2>
            <p>Each layer has one job. That makes the system easier to reason about, safer to change, and far less likely to lose its voice as capabilities expand.</p>
            <ul>
              <li><ShieldCheck /> Compact boot context</li>
              <li><BookOpen /> Full references on demand</li>
              <li><Cpu /> Tooling kept out of personality</li>
            </ul>
          </div>
          <div className="layer-stack reveal" aria-label="Persona architecture layers">
            <div className="layer layer-soul"><span>01</span><div><small>IDENTITY</small><strong>SOUL.md</strong><p>Voice, temperament, values, boundaries</p></div><Sparkles /></div>
            <div className="layer layer-agents"><span>02</span><div><small>PROCEDURE</small><strong>AGENTS.md</strong><p>Operating rules, workflows, escalation</p></div><Braces /></div>
            <div className="layer layer-tools"><span>03</span><div><small>CAPABILITY</small><strong>TOOLS.md</strong><p>Services, endpoints, safety constraints</p></div><Terminal /></div>
          </div>
        </section>

        <section className="section" id="souls">
          <div className="section-heading reveal">
            <div><span className="eyebrow">THE CRYPT / CURRENT ROSTER</span><h2>Distinct by design.</h2></div>
            <p>Not skins over the same assistant. Each soul is built from a different corpus, voice model, and operational purpose.</p>
          </div>
          <div className="soul-list">
            {souls.map((soul, index) => (
              <article className="soul-row reveal" key={soul.name}>
                <span className="soul-index">0{index + 1}</span>
                <div className="soul-mark">{soul.mark}</div>
                <div className="soul-name"><h3>{soul.name}</h3><p>{soul.voice}</p></div>
                <span className={`status ${soul.state}`}>{soul.status}</span>
                <ArrowRight className="soul-arrow" />
              </article>
            ))}
          </div>
        </section>

        <section className="workbench section" id="workbench">
          <div className="workbench-intro reveal">
            <span className="eyebrow">PYTHON / IN-BROWSER LAB</span>
            <h2>Test the signal.</h2>
            <p>Python code runs in your browser through Pyodide and WebAssembly, not on this site's server. On first run, the browser downloads Pyodide runtime files from jsDelivr. Use only code you trust.</p>
            <div className="runtime-note"><Cpu /><span><strong>Powered by Pyodide</strong>Pyodide {PYODIDE_VERSION} runtime loads on first run.</span></div>
          </div>
          <div className="code-lab reveal">
            <div className="code-toolbar">
              <span><i /> soul_signal.py</span>
              <button onClick={copyCode}>{copied ? <Check /> : <Copy />} {copied ? "Copied" : "Copy"}</button>
            </div>
            <textarea value={code} onChange={(event) => setCode(event.target.value)} spellCheck={false} aria-label="Python code editor" />
            <div className="run-bar">
              <span className={`runtime-status ${pyStatus}`}><i /> {pyStatus === "idle" ? "Runtime cold" : pyStatus}</span>
              <button onClick={runPython} disabled={pyStatus === "loading" || pyStatus === "running"}>
                <Play fill="currentColor" /> {pyStatus === "loading" ? "Loading Python..." : pyStatus === "running" ? "Running..." : pyStatus === "error" ? "Retry Python" : "Run Python"}
              </button>
            </div>
            <pre className="output"><span>OUTPUT</span>{output}</pre>
          </div>
        </section>

        <section className="closing">
          <div className="closing-ring" aria-hidden="true" />
          <span className="eyebrow">THE PRINCIPLE</span>
          <h2>The model is the engine.<br /><em>The corpus is the soul.</em></h2>
          <p>Build privately. Preserve the voice. Own the result.</p>
          <a className="button button-primary" href="https://github.com/OKHP3/infusing-a-soul">Explore the repository <ArrowRight size={17} /></a>
        </section>
      </main>

      <footer>
        <div className="brand"><span className="brand-forge"><Flame size={18} /></span><span>OVERKILL HILL P³</span></div>
        <p>Precision · Protocol · Promptcraft</p>
        <p>Built locally. Kept deliberately.</p>
      </footer>
    </div>
  );
}

export default App;