"use client";
import { useEffect, useState } from "react";
import { api, ApiInventoryItem, ApiProfile, ApiReferral } from "@/lib/api";
import { haptic } from "@/lib/telegram";

const rarityLine: Record<string, string> = {
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

export default function Profile() {
  const [p, setP] = useState<ApiProfile | null>(null);
  const [ref, setRef] = useState<ApiReferral | null>(null);
  const [items, setItems] = useState<ApiInventoryItem[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const [sellingId, setSellingId] = useState<number | null>(null);

  const loadAll = async () => {
    try {
      const [prof, inv] = await Promise.all([api.getProfile(), api.getInventory()]);
      setP(prof);
      setItems(inv);
    } catch (e: any) {
      setError(e.message);
    }
    api.getReferral().then(setRef).catch(() => {});
  };

  useEffect(() => {
    loadAll();
  }, []);

  const copyLink = async () => {
    if (!ref) return;
    try {
      await navigator.clipboard.writeText(ref.link);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      alert(ref.link);
    }
  };

  const shareLink = () => {
    if (!ref) return;
    const text = "Залетай в кейс-бота!";
    const url = `https://t.me/share/url?url=${encodeURIComponent(ref.link)}&text=${encodeURIComponent(text)}`;
    (window as any).Telegram?.WebApp?.openTelegramLink?.(url) || window.open(url, "_blank");
  };

  const sellItem = async (id: number) => {
    setSellingId(id);
    try {
      const res = await api.sellItem(id);
      haptic("success");
      setP((p) => (p ? { ...p, balance: res.new_balance } : p));
      setItems((arr) => arr.filter((it) => it.id !== id));
    } catch (e: any) {
      haptic("error");
      alert(e.message);
    } finally {
      setSellingId(null);
    }
  };

  return (
    <main className="min-h-screen p-4 flex flex-col gap-3 pb-24">
      <h1 className="text-2xl font-bold">👤 {p?.first_name ?? "Профиль"}</h1>
      {error && <div className="text-red-400 text-sm">Ошибка: {error}</div>}

      <div className="bg-[#131824] rounded-lg p-4 space-y-2 text-sm">
        <div>Username: @{p?.username ?? "—"}</div>
        <div>Баланс: <span className="text-amber-400">{p?.balance ?? "..."} 🪙</span></div>
        <div>Streak: {p?.streak ?? 0} дней</div>
        <div className="flex justify-between">
          <span className="text-zinc-400">Открыто кейсов:</span>
          <span className="text-amber-400 font-bold">{p?.total_cases_opened ?? 0}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-zinc-400">Любимый кейс:</span>
          <span className="text-zinc-100">{p?.favorite_case ?? "—"}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-zinc-400">Самый дорогой дроп:</span>
          <span className="text-amber-400 font-bold text-right">
            {p?.best_drop_name ?? "—"} {p?.best_drop_price ? `(${p.best_drop_price} 🪙)` : ""}
          </span>
        </div>
        
      </div>


      <h2 className="text-lg font-bold mt-2">🎒 Инвентарь ({items.length})</h2>
      {items.length === 0 && (
        <div className="bg-[#131824] rounded-lg p-4 text-zinc-500 text-sm">Пока пусто — открой кейс.</div>
      )}
      <div className="grid grid-cols-2 gap-3">
        {items.map((it) => {
          const line = rarityLine[it.rarity] || rarityLine.Consumer;
          return (
            <div key={it.id} className="bg-[#131824] border border-zinc-800/80 rounded-lg overflow-hidden flex flex-col">
              <div className="relative h-28 flex items-center justify-center p-2">
                {it.image_url ? (
                  <img src={it.image_url} alt={it.name} className="w-full h-full object-contain" />
                ) : (
                  <div className="text-3xl opacity-20">?</div>
                )}
                <div className="absolute top-1 right-2 text-[10px] text-zinc-400 font-mono">
                  {it.quality ?? ""}{it.is_stattrak ? " ★ST" : ""}
                </div>
              </div>
              <div className="px-2 pb-2 flex flex-col gap-1">
                <div className="text-xs font-bold text-zinc-100 truncate">{it.name}</div>
                <div className="text-[10px] text-zinc-500 uppercase">{it.rarity}</div>
                <button
                  onClick={() => sellItem(it.id)}
                  disabled={sellingId === it.id}
                  className="mt-1 w-full bg-amber-600 hover:bg-amber-500 rounded text-xs font-bold py-1 active:scale-95 transition-transform disabled:opacity-50"
                >
                  {sellingId === it.id ? "..." : `Продать за ${it.sell_price ?? 0} 🪙`}
                </button>
              </div>
              <div className={`h-1 w-full ${line}`} />
            </div>
          );
        })}
      </div>
    </main>
  );
}