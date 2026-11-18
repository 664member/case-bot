"use client";
import { Case } from "@/lib/types";
import { RarityBadge } from "./RarityBadge";

export function CaseCard({ c, onOpen }: { c: Case; onOpen: (c: Case) => void }) {
  return (
    <div className="bg-[#17171F] rounded-lg p-4 flex flex-col gap-2">
      <div className="flex justify-between items-center">
        <h3 className="font-bold">{c.name}</h3>
        <span className="text-amber-400 text-sm">{c.price} очков</span>
      </div>
      <div className="flex flex-wrap gap-1">
        {c.items.map((it) => (
          <div key={it.id} className="text-[10px] flex items-center gap-1">
            <RarityBadge rarity={it.rarity} />
            <span className="text-zinc-400">{it.chance}%</span>
          </div>
        ))}
      </div>
      <button
        onClick={() => onOpen(c)}
        className="bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg py-2 text-sm font-bold active:scale-95 transition-transform"
      >
        Открыть
      </button>
    </div>
  );
}