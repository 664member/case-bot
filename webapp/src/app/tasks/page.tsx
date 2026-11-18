"use client";
import { useEffect, useState } from "react";
import { api, ApiTasks } from "@/lib/api";
import { haptic } from "@/lib/telegram";

export default function TasksPage() {
  const [tasks, setTasks] = useState<ApiTasks | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [copied, setCopied] = useState(false);
  const [claiming, setClaiming] = useState(false);

  const load = async () => {
    try {
      setTasks(await api.getTasks());
    } catch (e: any) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const copyLink = async () => {
    if (!tasks?.referral.link) return;
    try {
      await navigator.clipboard.writeText(tasks.referral.link);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      alert(tasks.referral.link);
    }
  };

  const shareLink = () => {
    if (!tasks?.referral.link) return;
    const url = `https://t.me/share/url?url=${encodeURIComponent(tasks.referral.link)}&text=${encodeURIComponent("Залетай в кейс-бота!")}`;
    (window as any).Telegram?.WebApp?.openTelegramLink?.(url) || window.open(url, "_blank");
  };

  const claimSub = async () => {
    setClaiming(true);
    try {
      const res = await api.claimSubscription();
      haptic("success");
      alert(`+${res.points} 🪙`);
      await load();
    } catch (e: any) {
      haptic("error");
      alert(e.message);
    } finally {
      setClaiming(false);
    }
  };

  if (loading) return <main className="min-h-screen p-4 pb-32 text-zinc-500">Загрузка...</main>;
  if (error) return <main className="min-h-screen p-4 pb-32 text-red-400">Ошибка: {error}</main>;
  if (!tasks) return null;

  return (
    <main className="min-h-screen p-4 pb-32 flex flex-col gap-4">
      <h1 className="text-2xl font-bold">✅ Задания</h1>

      <div className="bg-[#131824] rounded-lg p-4 flex flex-col gap-3">
        <div className="flex justify-between items-start gap-2">
          <div className="min-w-0">
            <div className="font-bold">👥 Пригласи друга</div>
            <div className="text-xs text-zinc-400">За каждого друга после его активности</div>
          </div>
          <div className="text-emerald-400 font-bold text-sm shrink-0">
            +{tasks.referral.points_per_invite} 🪙
          </div>
        </div>
        <div className="text-xs text-zinc-400">
          Приглашено: {tasks.referral.invited_count} · Заработано: {tasks.referral.earned_points} 🪙
        </div>
        {tasks.referral.link && (
          <>
            <div className="bg-black/40 rounded px-2 py-2 text-xs break-all text-zinc-300">
              {tasks.referral.link}
            </div>
            <div className="flex gap-2">
              <button
                onClick={copyLink}
                className="flex-1 bg-zinc-800 rounded-lg py-2 text-sm active:scale-95 transition-transform"
              >
                {copied ? "✅ Скопировано" : "📋 Копировать"}
              </button>
              <button
                onClick={shareLink}
                className="flex-1 bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg py-2 text-sm font-bold active:scale-95 transition-transform"
              >
                📤 Поделиться
              </button>
            </div>
          </>
        )}
      </div>

      <div className="bg-[#131824] rounded-lg p-4 flex flex-col gap-3">
        <div className="flex justify-between items-start gap-2">
          <div className="min-w-0">
            <div className="font-bold">📢 Подпишись на канал</div>
            <div className="text-xs text-zinc-400">Разовая награда</div>
          </div>
          <div className="text-emerald-400 font-bold text-sm shrink-0">
            +{tasks.subscription.points} 🪙
          </div>
        </div>
        {tasks.subscription.awarded ? (
          <div className="text-sm text-emerald-400">✅ Выполнено</div>
        ) : tasks.subscription.subscribed ? (
          <button
            onClick={claimSub}
            disabled={claiming}
            className="w-full bg-gradient-to-r from-emerald-600 to-teal-600 rounded-lg py-2 font-bold active:scale-95 transition-transform disabled:opacity-50"
          >
            {claiming ? "..." : `Забрать ${tasks.subscription.points} 🪙`}
          </button>
        ) : (
          <a
            href={tasks.subscription.channel_link}
            target="_blank"
            rel="noopener noreferrer"
            className="block w-full text-center bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg py-2 font-bold"
          >
            📢 Подписаться
          </a>
        )}
      </div>
    </main>
  );
}