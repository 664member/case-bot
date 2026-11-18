"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import { api, ApiCase, ApiDrop, ApiProfile } from "@/lib/api";
import { LiveFeed } from "@/components/LiveFeed";
import { initTelegram, haptic } from "@/lib/telegram";

export default function Home() {
  const [cases, setCases] = useState<ApiCase[]>([]);
  const [drops, setDrops] = useState<ApiDrop[]>([]);
  const [profile, setProfile] = useState<ApiProfile | null>(null);
  const [dailyAvailable, setDailyAvailable] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    initTelegram();
    (async () => {
      try {
        const [c, f] = await Promise.all([api.getCases(), api.getFeed(20)]);
        setCases(c);
        setDrops(f);
        try {
          setProfile(await api.getProfile());
        } catch (e) {
          console.warn("profile", e);
        }
      } catch (e: any) {
        setError(e.message);
      }
    })();

    const interval = setInterval(() => {
      api.getFeed(20).then(setDrops).catch(() => {});
    }, 2000); // каждые 2 секунд

    return () => clearInterval(interval);
  }, []);

  const claimDaily = async () => {
    try {
      const res = await api.claimDaily();
      setProfile((p) =>
        p ? { ...p, balance: res.balance_after, streak: res.streak } : p
      );
      setDailyAvailable(false);
      haptic("success");
      alert(`+${res.reward} 🪙 Streak: ${res.streak}`);
    } catch (e: any) {
      haptic("error");
      alert(e.message);
    }
  };

  return (
    <main className="min-h-screen p-4 pb-32 flex flex-col gap-4">
      <LiveFeed drops={drops} />

      <div className="flex justify-between text-sm">
        <span>💰 Баланс: <span className="text-amber-400">{profile?.balance ?? "..."} 🪙</span></span>
        <span>🔥 Streak: {profile?.streak ?? 0}</span>
      </div>

      <button
        onClick={claimDaily}
        disabled={!dailyAvailable}
        className="w-full bg-gradient-to-r from-emerald-600 to-teal-600 rounded-lg py-2 font-bold disabled:opacity-50 active:scale-95 transition-transform"
      >
        {dailyAvailable ? "🎁 Забрать ежедневный бонус" : "✅ Бонус получен"}
      </button>

      {error && <div className="text-red-400 text-sm">Ошибка: {error}</div>}

      <h2 className="text-lg font-bold">🎰 Кейсы</h2>
      <div className="grid grid-cols-2 gap-4">
        {cases.map((c) => {
          const glowClass = ["case-glow-0", "case-glow-1", "case-glow-2", "case-glow-3"][c.id % 4];
          return (
            <Link
              key={c.id}
              href={`/cases/${c.id}`}
              className="group flex flex-col items-center"
            >
              <div className="relative w-full aspect-square flex items-center justify-center">
                <div className={`absolute inset-0 rounded-full bg-purple-600/20 blur-3xl scale-75 group-hover:scale-100 transition-transform duration-500 ${glowClass}`} />
                {c.image_url ? (
                  <img
                    src={c.image_url}
                    alt={c.name}
                    className="relative w-full h-full object-contain drop-shadow-[0_0_20px_rgba(168,85,247,0.4)] group-hover:scale-105 transition-transform"
                  />
                ) : (
                  <div className="relative text-6xl">📦</div>
                )}
              </div>
              <div className="text-center mt-2">
                <div className="text-sm font-bold text-zinc-200">{c.name}</div>
                <div className="text-xs text-amber-400">{c.price} 🪙</div>
              </div>
            </Link>
          );
        })}
      </div>
    </main>
  );
}