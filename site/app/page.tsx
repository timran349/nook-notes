import React from "react";

export default function Home() {
  const downloadUrl =
    "https://github.com/timran349/nook-notes/releases/download/v1.0.0/Nook-Notes.dmg";
  const githubUrl = "https://github.com/timran349/nook-notes";

  return (
    <main className="max-w-xl w-full text-center space-y-10">
      {/* Brand Header */}
      <header className="space-y-4">
        <div className="flex justify-center">
          <div className="w-18 h-18 bg-gradient-to-br from-[#2a2e37] to-[#1a1d24] rounded-2xl border border-white/10 shadow-2xl relative flex items-center justify-center p-4">
            <div className="w-10 h-10 border-2 border-white/20 rounded-lg relative">
              <div className="absolute top-0 right-0 w-3 h-3 bg-white/20 rounded-bl-sm clip-corner" />
            </div>
          </div>
        </div>

        <h1 className="text-3xl sm:text-4xl font-bold tracking-tight">
          Nook Notes
        </h1>
        <p className="text-base text-[var(--text-secondary)] font-normal">
          Small notes. Always within reach.
        </p>
      </header>

      {/* Hero Pitch & Download CTA */}
      <section className="space-y-6">
        <p className="text-lg leading-relaxed text-[var(--text-primary)] max-w-md mx-auto">
          A tiny sticky-notes app that lives quietly<br />
          in the bottom-left corner of your Mac.
        </p>

        <div className="flex flex-col items-center gap-3">
          <div className="flex items-center gap-3">
            <a
              href={downloadUrl}
              className="inline-flex items-center gap-2.5 bg-[var(--text-primary)] text-[var(--bg-color)] px-6 py-3 rounded-xl font-semibold text-sm hover:opacity-90 transition-all transform hover:-translate-y-0.5 shadow-lg"
            >
              <span>Download for Mac</span>
              <svg
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2.2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                <polyline points="7 10 12 15 17 10" />
                <line x1="12" y1="15" x2="12" y2="3" />
              </svg>
            </a>

            <a
              href={githubUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1.5 px-4 py-3 rounded-xl border border-[var(--card-border)] bg-[var(--card-bg)] text-sm font-medium text-[var(--text-secondary)] hover:text-[var(--text-primary)] transition-colors"
            >
              <span>GitHub ↗</span>
            </a>
          </div>

          <span className="text-xs text-[var(--text-secondary)]">
            macOS • Free & local-first • Universal (Apple Silicon & Intel)
          </span>
        </div>
      </section>

      {/* Product Highlights */}
      <section className="grid grid-cols-1 sm:grid-cols-3 gap-3 text-left">
        <div className="p-4 rounded-xl border border-[var(--card-border)] bg-[var(--card-bg)]">
          <h3 className="text-xs font-semibold text-[var(--text-primary)] mb-1">
            Always there
          </h3>
          <p className="text-xs text-[var(--text-secondary)] leading-relaxed">
            Lives permanently in the bottom-left corner across all desktop spaces.
          </p>
        </div>

        <div className="p-4 rounded-xl border border-[var(--card-border)] bg-[var(--card-bg)]">
          <h3 className="text-xs font-semibold text-[var(--text-primary)] mb-1">
            Instant notes
          </h3>
          <p className="text-xs text-[var(--text-secondary)] leading-relaxed">
            Hover to reveal, click to type. Auto-saves continuously with zero friction.
          </p>
        </div>

        <div className="p-4 rounded-xl border border-[var(--card-border)] bg-[var(--card-bg)]">
          <h3 className="text-xs font-semibold text-[var(--text-primary)] mb-1">
            Local first
          </h3>
          <p className="text-xs text-[var(--text-secondary)] leading-relaxed">
            100% private. Notes remain strictly on your Mac without cloud servers.
          </p>
        </div>
      </section>

      {/* Keyboard Shortcuts */}
      <section className="p-5 rounded-xl border border-[var(--card-border)] bg-[var(--card-bg)] text-left space-y-3">
        <h2 className="text-xs font-bold uppercase tracking-wider text-[var(--text-secondary)]">
          Keyboard Shortcuts
        </h2>
        <div className="space-y-2 text-xs">
          <div className="flex justify-between items-center">
            <code className="font-mono bg-white/10 border border-white/10 px-2 py-0.5 rounded text-[var(--text-primary)] font-semibold">
              ⌘ ⇧ Space
            </code>
            <span className="text-[var(--text-secondary)]">Open Nook anywhere</span>
          </div>
          <div className="flex justify-between items-center">
            <code className="font-mono bg-white/10 border border-white/10 px-2 py-0.5 rounded text-[var(--text-primary)] font-semibold">
              ⌘ N
            </code>
            <span className="text-[var(--text-secondary)]">New note</span>
          </div>
          <div className="flex justify-between items-center">
            <code className="font-mono bg-white/10 border border-white/10 px-2 py-0.5 rounded text-[var(--text-primary)] font-semibold">
              ⌘ F
            </code>
            <span className="text-[var(--text-secondary)]">Search notes</span>
          </div>
          <div className="flex justify-between items-center">
            <code className="font-mono bg-white/10 border border-white/10 px-2 py-0.5 rounded text-[var(--text-primary)] font-semibold">
              Esc
            </code>
            <span className="text-[var(--text-secondary)]">Close panel</span>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="pt-4 text-xs text-[var(--text-secondary)] opacity-70">
        Nook Notes is an independent macOS utility. Fully offline & local-first.
      </footer>
    </main>
  );
}
