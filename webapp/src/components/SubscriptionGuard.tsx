"use client";
import { useEffect, useState } from "react";
import { api, SubscriptionError } from "@/lib/api";

export function SubscriptionGuard({ children }: { children: React.ReactNode }) {
  const [needSub, setNeedSub] = useState(false);
  const [banned, setBanned] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.getProfile()
      .then(() => setLoading(false))
      .catch((e: any) => {
        if (e instanceof SubscriptionError) {
          setNeedSub(true);
        } else if (e?.message === "Banned") {
          setBanned(true);
        }
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <main className="min-h-screen flex items-center justify-center text-zinc-500">
        Загрузка...
      </main>
    );
  }

  if (banned) {
    return (
      <main className="min-h-screen p-4 flex flex-col items-center justify-center gap-4 text-center">
        <div className="text-6xl">🚫</div>
        <h1 className="text-xl font-bold">Вы забанены</h1>
        <p className="text-sm text-zinc-400">
          Доступ к приложению заблокирован администратором.
        </p>
      </main>
    );
  }

  if (needSub) {
    const channelLink = process.env.NEXT_PUBLIC_CHANNEL_LINK || "https://t.me/";
    return (
      <main className="min-h-screen p-4 flex flex-col items-center justify-center gap-4 text-center">
        <div className="text-6xl">🔒</div>
        <h1 className="text-xl font-bold">Нужна подписка</h1>
        <p className="text-sm text-zinc-400">
          Чтобы пользоваться приложением, подпишитесь на наш канал.
        </p>
        <a
          href={channelLink}
          target="_blank"
          rel="noopener noreferrer"
          className="bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg px-6 py-3 font-bold"
        >
          📢 Подписаться
        </a>
      </main>
    );
  }

  return <>{children}</>;
}