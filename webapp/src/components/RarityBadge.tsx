import { Rarity } from "@/lib/types";

const colorMap: Record<string, string> = {
  Consumer: "text-gray-400 border-gray-500",
  Industrial: "text-sky-400 border-sky-500",
  "Mil-Spec": "text-blue-400 border-blue-500",
  Restricted: "text-purple-400 border-purple-500",
  Classified: "text-pink-400 border-pink-500",
  Covert: "text-red-400 border-red-500",
  "Rare Special": "text-amber-400 border-amber-500",
  Contraband: "text-orange-400 border-orange-500",
  // Старые значения (на всякий случай)
  Common: "text-gray-400 border-gray-500",
  Rare: "text-blue-400 border-blue-500",
  Epic: "text-purple-400 border-purple-500",
  Legendary: "text-amber-400 border-amber-500",
};

export function RarityBadge({ rarity }: { rarity: string }) {
  return (
    <span className={`text-xs px-2 py-0.5 border rounded ${colorMap[rarity] || colorMap.Consumer}`}>
      {rarity}
    </span>
  );
}