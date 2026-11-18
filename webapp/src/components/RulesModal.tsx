"use client";
import { useEffect, useState } from "react";

const simpleHash = (s: string): string => {
  let h = 0;
  for (let i = 0; i < s.length; i++) {
    h = (h << 5) - h + s.charCodeAt(i);
    h |= 0;
  }
  return h.toString(36);
};

export function RulesModal() {
  const [show, setShow] = useState(false);
  const [text, setText] = useState("");

  useEffect(() => {
    if (typeof window === "undefined") return;
    fetch("/api/webapp/rules")
      .then((r) => r.json())
      .then((data) => {
        if (!data.enabled || !data.text) return;
        const stored = localStorage.getItem("rules_accepted_hash");
        const currentHash = simpleHash(data.text);
        if (stored === currentHash) return;
        setText(data.text);
        setShow(true);
      })
      .catch(() => {});
  }, []);

  if (!show) return null;

  const accept = () => {
    localStorage.setItem("rules_accepted_hash", simpleHash(text));
    setShow(false);
  };

  return (
    <div className="fixed inset-0 bg-black/85 flex items-center justify-center z-[100] p-4">
      <div className="bg-[#131824] rounded-2xl p-6 max-w-md w-full border border-zinc-800 max-h-[85vh] flex flex-col">
        <h2 className="text-xl font-bold mb-4">📜 Правила</h2>
        <div className="text-sm whitespace-pre-wrap overflow-y-auto flex-1 mb-4 text-zinc-300">
          {text}
        </div>
        <button
          onClick={accept}
          className="w-full bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg py-3 font-bold active:scale-95 transition-transform"
        >
          Принимаю
        </button>
      </div>
    </div>
  );
}