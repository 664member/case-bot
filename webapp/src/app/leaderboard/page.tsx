"use client";
import { useEffect, useState } from "react";
import { api, ApiTournament } from "@/lib/api";
import { initTelegram } from "@/lib/telegram";

function truncate(s: string, max: number): string {
  if (!s) return s;
  if (s.length <= max) return s;
  return s.slice(0, Math.max(1, max - 1)) + "…";
}

function formatTimeLeft(endsAt: number): string {
  const diff = endsAt - Date.now();
  if (diff <= 0) return "завершён";
  const totalSec = Math.floor(diff / 1000);
  const days = Math.floor(totalSec / 86400);
  const hours = Math.floor((totalSec % 86400) / 3600);
  const minutes = Math.floor((totalSec % 3600) / 60);
  const seconds = totalSec % 60;
  if (days > 0) return `${days}д ${hours}ч`;
  if (hours > 0) return `${hours}ч ${minutes}м`;
  if (minutes > 0) return `${minutes}м ${seconds}с`;
  return `${seconds}с`;
}

export default function LeaderboardPage() {
  const [tournaments, setTournaments] = useState<ApiTournament[]>([]);
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [, setTick] = useState(0);

  useEffect(() => {
    initTelegram();
    (async () => {
      try {
        const list = await api.getTournament();
        setTournaments(list);
        if (list.length > 0) setSelectedId(list[0].id);
      } catch (e: any) {
        setError(e.message);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  useEffect(() => {
    const id = setInterval(() => setTick((t) => t + 1), 1000);
    return () => clearInterval(id);
  }, []);

  const selected = tournaments.find((t) => t.id === selectedId) || null;

  return (
    <main className="min-h-screen p-4 pb-32">
      <h1 className="text-2xl font-bold mb-4">🏆 Турниры</h1>

      {loading && <div className="text-zinc-500 text-sm">Загрузка...</div>}
      {error && <div className="text-red-400 text-sm mb-2">Ошибка: {error}</div>}

      {!loading && tournaments.length === 0 && (
        <div className="bg-[#131824] rounded-lg p-4 text-zinc-500 text-sm">
          Сейчас нет активных турниров. Загляни позже.
        </div>
      )}

      {tournaments.length > 1 && (
        <div className="flex gap-2 overflow-x-auto mb-4 pb-1">
          {tournaments.map((t) => (
            <button
              key={t.id}
              onClick={() => setSelectedId(t.id)}
              className={`shrink-0 px-3 py-1.5 rounded-lg text-sm ${
                t.id === selectedId ? "bg-purple-600 text-white" : "bg-[#131824] text-zinc-400"
              }`}
            >
              {t.name}
            </button>
          ))}
        </div>
      )}

      {selected && (
        <div className="flex flex-col gap-3">
          <div className="bg-[#131824] rounded-lg p-4">
            <div className="flex justify-between items-start mb-1">
              <h2 className="font-bold text-lg">{selected.name}</h2>
              <span className="text-xs text-zinc-400">⏱ {formatTimeLeft(selected.ends_at)}</span>
            </div>
            <div className="text-xs text-zinc-500">
              Награды: топ {selected.top_n} · Участников: {selected.entries.length}
            </div>
          </div>

          <div className="bg-[#131824] rounded-lg divide-y divide-zinc-800">
            {selected.entries.length === 0 && (
              <div className="p-4 text-zinc-500 text-sm">Пока никто не набрал очков.</div>
            )}
            {selected.entries.map((e) => {
              const maxLen = selected.nickname_max_length || 15;
              const uname = truncate(e.username, maxLen);
              const label = selected.leaderboard_labels?.[String(e.rank)] || "";
              const medal =
                e.rank === 1 ? "🥇" : e.rank === 2 ? "🥈" : e.rank === 3 ? "🥉" : `${e.rank}.`;
              const isTop = e.rank <= selected.top_n;
              return (
                <div
                  key={e.userId}
                  className={`flex justify-between items-center p-3 ${isTop ? "" : "opacity-60"}`}
                >
                  <span className="flex items-center gap-2 min-w-0">
                    <span className="w-8 text-center shrink-0">{medal}</span>
                    {label && (
                      <span className="text-xs font-bold text-emerald-400 shrink-0">{label}</span>
                    )}
                    <span className="truncate">@{uname}</span>
                  </span>
                  <span
                    className={`font-bold shrink-0 ${isTop ? "text-amber-400" : "text-zinc-400"}`}
                  >
                    {e.score} 🪙
                  </span>
                </div>
              );
            })}
          </div>
        </div>
      )}
    </main>
  );
}