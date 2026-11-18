"use client";
import { ApiCaseItem } from "@/lib/api";

const rarityLineColor: Record<string, string> = {
  Consumer: "bg-zinc-400",
  Industrial: "bg-sky-400",
  "Mil-Spec": "bg-blue-500",
  Restricted: "bg-purple-500",
  Classified: "bg-pink-500",
  Covert: "bg-red-500",
  "Rare Special": "bg-amber-400",
  Contraband: "bg-orange-500",
  Common: "bg-zinc-400",
  Rare: "bg-blue-500",
  Epic: "bg-purple-500",
  Legendary: "bg-amber-400",
};

export function DropCard({ item }: { item: ApiCaseItem }) {
  const lineColor = rarityLineColor[item.rarity] || rarityLineColor.Consumer;
  const parts = item.name.split(/\s*\|\s*|\s+/);
  const weapon = parts[0] || item.name;
  const skin = parts.slice(1).join(" ") || "";

  return (
    <div className="bg-[#131824] border border-zinc-800/80 rounded-lg overflow-hidden flex flex-col relative">
      <div className="relative h-32 flex items-center justify-center p-2">
        {item.image_url ? (
          <img src={item.image_url} alt={item.name} className="w-full h-full object-contain drop-shadow-[0_5px_10px_rgba(0,0,0,0.5)]" />
        ) : (
          <div className="text-4xl opacity-20">?</div>
        )}
      </div>

      <div className="px-3 pb-3 mt-auto relative">
        <div className="absolute top-0 right-3 text-[9px] text-zinc-500 font-mono">{item.chance}%</div>
        <div className="text-[10px] text-zinc-400 uppercase tracking-wider truncate pr-10">{weapon}</div>
        <div className="text-sm font-bold text-zinc-100 truncate mb-1">{skin || weapon}</div>
        <div className="text-amber-400 font-bold text-sm">{item.pointValue} 🪙</div>
      </div>

      <div className={`h-1 w-full ${lineColor}`} />
    </div>
  );
}