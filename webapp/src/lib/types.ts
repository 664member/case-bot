export type Rarity = "Common" | "Rare" | "Epic" | "Legendary" | "Consumer" | "Industrial" | "Mil-Spec" | "Restricted" | "Classified" | "Covert" | "Rare Special" | "Contraband";

export interface CaseItem {
  id: string;
  name: string;
  rarity: Rarity;
  chance: number;
  pointValue: number;
  image_url?: string | null;
}

export interface Case {
  id: string;
  name: string;
  price: number;       // стоимость открытия в очках
  items: CaseItem[];
}

export interface Drop {
  id: string;
  userId: number;
  username: string;
  itemName: string;
  rarity: Rarity;
  caseName: string;
  rolledAt: number;    // timestamp
}

export interface LeaderboardEntry {
  userId: number;
  username: string;
  score: number;
  rank: number;
}

export interface UserProfile {
  id: number;
  username: string;
  firstName: string;
  balance: number;
  streak: number;
  seasonName: string;
}