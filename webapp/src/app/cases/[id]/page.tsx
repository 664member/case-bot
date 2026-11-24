"use client";
import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { api, ApiCase, ApiOpenCaseResult } from "@/lib/api";
import { Roulette } from "@/components/Roulette";
import { DropCard } from "@/components/DropCard";
import { haptic } from "@/lib/telegram";
import type { CaseItem } from "@/lib/types";

export default function CaseDetailPage() {
  const params = useParams();
  const router = useRouter();
  const caseId = Number(params.id);
  const [c, setC] = useState<ApiCase | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [balance, setBalance] = useState<number | null>(null);
  const [rolling, setRolling] = useState(false);
  const [winner, setWinner] = useState<CaseItem | null>(null);
  const [resultData, setResultData] = useState<ApiOpenCaseResult | null>(null);
  const [roundKey, setRoundKey] = useState(0);
  const [showResult, setShowResult] = useState(false);
  const [selling, setSelling] = useState(false);
  const [errorModal, setErrorModal] = useState<string | null>(null);

  useEffect(() => {
    api.getCases().then((list) => {
      const found = list.find((x) => x.id === caseId);
      if (!found) setError("Кейс не найден");
      else setC(found);
    }).catch((e) => setError(e.message));
    api.getProfile().then((p) => setBalance(p.balance)).catch(() => {});
  }, [caseId]);

  const openCase = async () => {
    if (!c || rolling || balance === null) return;
    if (balance < c.price) {
      haptic("error");
      return alert("Недостаточно средств");
    }
    setRolling(true);
    setWinner(null);
    setResultData(null);
    setShowResult(false);
    haptic("medium");
    try {
      const result = await api.openCase(c.id);
      if (c.is_limited && c.remaining_attempts !== null) {
        setC({
          ...c,
          remaining_attempts: Math.max(0, c.remaining_attempts - 1),
        });
      }
      const winnerItem: CaseItem = {
        id: String(result.item_id),
        name: result.item_name,
        rarity: result.rarity as CaseItem["rarity"],
        chance: 0,
        pointValue: result.final_price ?? result.point_value,
        image_url: result.image_url ?? null,
      } as CaseItem;
      setWinner(winnerItem);
      setResultData(result);
      setBalance(result.balance_after);
      setRoundKey(Date.now());
    } catch (e: any) {
      setRolling(false);
       setErrorModal(e.message);
    }
  };

  const onFinish = () => {
    setRolling(false);
    setShowResult(true);
    if (
      winner?.rarity === "Covert" ||
      winner?.rarity === "Rare Special" ||
      winner?.rarity === "Contraband" ||
      winner?.rarity === "Legendary"
    ) {
      haptic("success");
    }
  };

  const closeResult = () => {
    setShowResult(false);
    setWinner(null);
    setResultData(null);
  };

  const sellAndClose = async () => {
    if (!resultData?.drop_id) return;
    setSelling(true);
    try {
      const res = await api.sellItem(resultData.drop_id);
      setBalance(res.new_balance);
      haptic("success");
      closeResult();
      alert(`Продано за ${res.price} 🪙`);
    } catch (e: any) {
      haptic("error");
      alert(e.message);
    } finally {
      setSelling(false);
    }
  };

  if (error) {
    return (
      <main className="min-h-screen p-4 pb-32">
        <button onClick={() => router.back()} className="text-zinc-400 mb-4">← Назад</button>
        <div className="text-red-400">Ошибка: {error}</div>
      </main>
    );
  }

  if (!c) {
    return <main className="min-h-screen p-4 pb-32 text-zinc-500">Загрузка...</main>;
  }

  const sorted = [...c.items].sort((a, b) => b.pointValue - a.pointValue);

  return (
    <main className="min-h-screen p-4 pb-32 flex flex-col gap-4">
      <button onClick={() => router.back()} className="text-zinc-400 self-start">← Назад</button>

      <div className="flex flex-col items-center gap-2">
        <div className="relative w-48 h-48 flex items-center justify-center">
          <div className="absolute inset-0 rounded-full bg-purple-600/20 blur-3xl" />
          {c.image_url ? (
            <img
              src={c.image_url}
              alt={c.name}
              className="relative w-full h-full object-contain drop-shadow-[0_0_25px_rgba(168,85,247,0.5)]"
            />
          ) : (
            <div className="relative text-7xl">📦</div>
          )}
        </div>
        <h1 className="text-2xl font-bold text-center">{c.name}</h1>
        {c.is_limited && c.remaining_attempts !== null && (
          <div className="text-sm text-zinc-400">
            Осталось:{" "}
            <span className="text-amber-400 font-bold">
              {c.remaining_attempts}/{c.limit_attempts}
            </span>
          </div>
        )}        
        <div className="text-amber-400 font-bold text-sm">{c.price} 🪙</div>
        <div className="text-xs text-zinc-500">Баланс: {balance ?? "..."} 🪙</div>
      </div>

      <button
        onClick={openCase}
        disabled={rolling || (c.is_limited && c.remaining_attempts === 0)}
        className="w-full bg-gradient-to-r from-purple-600 to-blue-600 rounded-xl py-3 font-bold active:scale-95 transition-transform disabled:opacity-50"
      >
        {c.is_limited && c.remaining_attempts === 0
          ? "Лимит исчерпан"
          : rolling
          ? "Крутим..."
          : `Открыть за ${c.price} 🪙`}
      </button>

      {(rolling || winner) && (
        <Roulette items={c.items as any} winner={winner} roundKey={roundKey} onFinish={onFinish} />
      )}

      <h2 className="text-sm text-zinc-400 mt-2">Содержимое</h2>
      <div className="grid grid-cols-2 gap-3">
        {sorted.map((it) => (
          <DropCard key={it.id} item={it} />
        ))}
      </div>

      {showResult && winner && resultData && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4">
          <div className="bg-[#131824] rounded-2xl p-6 text-center max-w-xs w-full border border-zinc-800">
            <div className="text-sm text-zinc-400 mb-2">Выпало:</div>
            {winner.image_url && (
              <img
                src={winner.image_url}
                alt={winner.name}
                className="w-40 h-40 object-contain mx-auto drop-shadow-[0_0_20px_rgba(168,85,247,0.4)]"
              />
            )}
            <div className="text-lg font-bold text-zinc-100 mt-2">{winner.name}</div>
            <div className="text-xs text-zinc-400 mt-1">
              {resultData.quality ? (
                <span className="font-mono px-1.5 py-0.5 bg-zinc-800 rounded">
                  {resultData.quality}
                </span>
              ) : null}
              {resultData.is_stattrak ? (
                <span className="ml-1 text-amber-400 font-bold">★ ST</span>
              ) : null}
            </div>
            <div className="text-amber-400 font-bold text-base mt-2">
              {resultData.final_price ?? resultData.point_value} 🪙
            </div>
            <div className="flex gap-2 mt-4">
              <button
                onClick={closeResult}
                className="flex-1 bg-zinc-800 rounded-lg py-2 active:scale-95 transition-transform"
              >
                Забрать
              </button>
              <button
                onClick={sellAndClose}
                disabled={selling}
                className="flex-1 bg-amber-600 rounded-lg py-2 font-bold active:scale-95 transition-transform disabled:opacity-50"
              >
                {selling ? "..." : "Продать"}
              </button>
            </div>
          </div>
        </div>
      )}

      {errorModal && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4">
          <div className="bg-[#131824] rounded-2xl p-6 text-center max-w-xs w-full border border-zinc-800">
            <div className="text-4xl mb-3">🔒</div>
            <div className="text-zinc-200 text-sm mb-6">{errorModal}</div>
            <div className="flex flex-col gap-2">
              <a
                href={process.env.NEXT_PUBLIC_CHANNEL_LINK || "https://t.me/"}
                target="_blank"
                rel="noopener noreferrer"
                className="w-full block bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg py-2.5 font-bold text-sm text-white active:scale-95 transition-transform"
              >
                📢 Подписаться
              </a>
              <button
                onClick={() => setErrorModal(null)}
                className="w-full bg-zinc-800 rounded-lg py-2 text-sm active:scale-95 transition-transform"
              >
                Закрыть
              </button>
            </div>
          </div>
        </div>
      )}
    </main>
  );
}