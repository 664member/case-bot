import { getInitData } from "./telegram";

export interface ApiCaseItem {
  id: number;
  name: string;
  rarity: string;
  chance: number;
  pointValue: number;
  image_url?: string | null;
}

export interface ApiCase {
  id: number;
  name: string;
  price: number;
  image_url?: string | null;
  items: ApiCaseItem[];
}

export interface ApiProfile {
  user_id: number;
  username: string | null;
  first_name: string | null;
  balance: number;
  streak: number;
  season_name: string;
}

export interface ApiDrop {
  id: number;
  username: string;
  itemName: string;
  rarity: string;
  caseName: string;
  rolledAt: number;
  image_url?: string | null;
}

export interface ApiLeaderboardEntry {
  userId: number;
  username: string;
  score: number;
  rank: number;
}

export interface ApiDailyBonus {
  reward: number;
  streak: number;
  balance_after: number;
  next_available_at: number;
}

export interface ApiReferral {
  link: string;
  invited_count: number;
  earned_points: number;
}

export interface ApiOpenCaseResult {
  item_id: number;
  item_name: string;
  rarity: string;
  point_value: number;
  image_url?: string | null;
  float_value?: number;
  quality?: string;
  is_stattrak?: boolean;
  final_price?: number;
  balance_after: number;
  drop_id: number;
}

export interface ApiTasks {
  referral: {
    link: string | null;
    invited_count: number;
    earned_points: number;
    points_per_invite: number;
  };
  subscription: {
    channel_link: string;
    points: number;
    subscribed: boolean;
    awarded: boolean;
  };
}

export interface ApiRules {
  enabled: boolean;
  text: string;
}

export interface ApiInventoryItem {
  id: number;
  name: string;
  rarity: string;
  image_url?: string | null;
  quality?: string | null;
  is_stattrak?: boolean;
  sell_price?: number | null;
  rolled_at: number;
}

export interface ApiTournamentEntry {
  userId: number;
  username: string;
  score: number;
  rank: number;
}

export interface ApiTournament {
  id: number;
  name: string;
  starts_at: number;
  ends_at: number;
  top_n: number;
  nickname_max_length?: number;
  leaderboard_labels?: Record<string, string>;
  entries: ApiTournamentEntry[];
}

export class SubscriptionError extends Error {
  constructor() {
    super("Subscription required");
    this.name = "SubscriptionError";
  }
}

async function post<T>(path: string, body: object): Promise<T> {
  const res = await fetch(path, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (res.status === 403) {
    const err = await res.json().catch(() => ({}));
    if (err.detail === "Banned") throw new Error("Banned");
    throw new SubscriptionError();
  }
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.detail || `HTTP ${res.status}`);
  }
  return res.json();
}

async function get<T>(path: string): Promise<T> {
  const res = await fetch(path);
  if (res.status === 403) {
    const err = await res.json().catch(() => ({}));
    if (err.detail === "Banned") throw new Error("Banned");
    throw new SubscriptionError();
  }
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

export function imageUrl(path: string | null | undefined): string | null {
  if (!path) return null;
  if (path.startsWith("http://") || path.startsWith("https://")) {
    // старая запись — оставляем как есть
    return path;
  }
  // относительный путь — используем как есть (Next.js проксирует /static/* на бэкенд)
  return path;
}

export const api = {
  getProfile: () => post<ApiProfile>("/api/webapp/profile", { initData: getInitData() }),
  getCases: () => get<{ cases: ApiCase[] }>("/api/webapp/cases").then((r) => r.cases),
  getFeed: (limit = 20) =>
    get<{ drops: ApiDrop[] }>(`/api/webapp/feed?limit=${limit}`).then((r) => r.drops),
  getLeaderboard: (limit = 10) =>
    get<{ entries: ApiLeaderboardEntry[] }>(`/api/webapp/leaderboard?limit=${limit}`).then(
      (r) => r.entries
    ),
  openCase: (case_id: number) =>
    post<ApiOpenCaseResult>("/api/webapp/open-case", { initData: getInitData(), case_id }),
  claimDaily: () => post<ApiDailyBonus>("/api/webapp/daily-bonus", { initData: getInitData() }),
  getReferral: () => post<ApiReferral>("/api/webapp/referral", { initData: getInitData() }),
  getInventory: () =>
    post<{ items: ApiInventoryItem[] }>("/api/webapp/inventory", { initData: getInitData() }).then(
      (r) => r.items
    ),
  sellItem: (drop_id: number) =>
    post<{ ok: boolean; price: number; new_balance: number }>("/api/webapp/sell-item", {
      initData: getInitData(),
      drop_id,
    }),
  getTournament: () =>
    get<{ tournaments: ApiTournament[] }>("/api/webapp/tournament").then((r) => r.tournaments),
  
  getTasks: () =>
    post<ApiTasks>("/api/webapp/tasks", { initData: getInitData() }),
  claimSubscription: () =>
    post<{ awarded: boolean; points: number }>("/api/webapp/claim-subscription", {
      initData: getInitData(),
    }),
  getRules: () => get<ApiRules>("/api/webapp/rules"),
};