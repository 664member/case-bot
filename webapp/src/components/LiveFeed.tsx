"use client";
import { ApiDrop } from "@/lib/api";

const rarityBorder: Record<string, string> = {
  Consumer: "border-zinc-500/60",
  Industrial: "border-sky-500/60",
  "Mil-Spec": "border-blue-500/60",
  Restricted: "border-purple-500/60",
  Classified: "border-pink-500/60",
  Covert: "border-red-500/60",
  "Rare Special": "border-amber-400/70",
  Contraband: "border-orange-500/70",
  Common: "border-zinc-500/60",
  Rare: "border-blue-500/60",
  Epic: "border-purple-500/60",
  Legendary: "border-amber-400/70",
};

export function LiveFeed({ drops }: { drops: ApiDrop[] }) {
  // Дублируем ленту, чтобы прокрутка была бесконечной (без "рывка")
  const items = drops.length > 0 ? [...drops, ...drops] : [];

  return (
    <div className="bg-[#131824] rounded-lg px-2 py-2 overflow-hidden">
      <div className="text-[10px] text-zinc-500 mb-1 px-1">📡 Последние дропы</div>

      {drops.length === 0 ? (
        <div className="text-zinc-500 text-xs px-1">Пока пусто</div>
      ) : (
        <div className="relative overflow-hidden">
          <div className="flex gap-2 animate-marquee w-max">
            {items.map((d, i) => (
              <div
                key={`${d.id}-${i}`}
                className={`shrink-0 w-16 h-16 rounded border ${rarityBorder[d.rarity] || rarityBorder.Common} flex items-center justify-center overflow-hidden bg-[#0a0e17]`}
                title={`@${d.username} — ${d.itemName}`}
              >
                {d.image_url ? (
                  <img
                    src={d.image_url}
                    alt={d.itemName}
                    className="w-full h-full object-contain p-1"
                  />
                ) : (
                  <div className="text-lg opacity-30">?</div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}