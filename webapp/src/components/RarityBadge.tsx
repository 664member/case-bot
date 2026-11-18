import { Rarity } from "@/lib/types";

const colorMap: Record<Rarity, string> = {
  Common: "text-gray-400 border-gray-500",
  Rare: "text-blue-400 border-blue-500",
  Epic: "text-purple-400 border-purple-500",
  Legendary: "text-amber-400 border-amber-500",
};

export function RarityBadge({ rarity }: { rarity: Rarity }) {
  return (
    <span className={`text-xs px-2 py-0.5 border rounded ${colorMap[rarity]}`}>
      {rarity}
    </span>
  );
}