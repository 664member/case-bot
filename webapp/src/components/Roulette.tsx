"use client";
import { useEffect, useRef, useState } from "react";
import { motion, useAnimation } from "framer-motion";
import { CaseItem } from "@/lib/types";

const rarityBorder: Record<string, string> = {
  Consumer: "border-zinc-500/40",
  Industrial: "border-sky-500/40",
  "Mil-Spec": "border-blue-500/40",
  Restricted: "border-purple-500/40",
  Classified: "border-pink-500/40",
  Covert: "border-red-500/40",
  "Rare Special": "border-amber-400/50",
  Contraband: "border-orange-500/50",
  Common: "border-zinc-500/40",
  Rare: "border-blue-500/40",
  Epic: "border-purple-500/40",
  Legendary: "border-amber-400/50",
};

const rarityGlow: Record<string, string> = {
  Consumer: "shadow-[0_0_20px_rgba(176,195,217,0.15)]",
  Industrial: "shadow-[0_0_20px_rgba(94,152,217,0.2)]",
  "Mil-Spec": "shadow-[0_0_20px_rgba(75,105,255,0.25)]",
  Restricted: "shadow-[0_0_20px_rgba(136,71,255,0.25)]",
  Classified: "shadow-[0_0_20px_rgba(211,44,230,0.25)]",
  Covert: "shadow-[0_0_20px_rgba(235,75,75,0.3)]",
  "Rare Special": "shadow-[0_0_25px_rgba(255,215,0,0.35)]",
  Contraband: "shadow-[0_0_25px_rgba(255,140,0,0.35)]",
};

const ITEM_WIDTH = 112;
const GAP = 8;
const STEP = ITEM_WIDTH + GAP;
const WINNER_INDEX = 25;
const STRIP_LENGTH = 40;

interface Props {
  items: CaseItem[];
  winner: CaseItem | null;
  roundKey: number;
  onFinish?: () => void;
}

export function Roulette({ items, winner, roundKey, onFinish }: Props) {
  const controls = useAnimation();
  const containerRef = useRef<HTMLDivElement>(null);
  const [strip, setStrip] = useState<CaseItem[]>([]);
  const lastRoundRef = useRef<number>(-1);

  useEffect(() => {
    if (!winner || items.length === 0 || !containerRef.current) return;
    if (lastRoundRef.current === roundKey) return;
    lastRoundRef.current = roundKey;

    const random = Array.from({ length: STRIP_LENGTH }, () =>
      items[Math.floor(Math.random() * items.length)]
    );
    random[WINNER_INDEX] = winner;
    setStrip(random);

    const containerWidth = containerRef.current.getBoundingClientRect().width;
    const targetX = -(WINNER_INDEX * STEP) + containerWidth / 2 - ITEM_WIDTH / 2;

    controls.set({ x: 0 });
    requestAnimationFrame(() => {
      controls
        .start({
          x: targetX,
          transition: { duration: 4, ease: [0.15, 0.85, 0.3, 1] },
        })
        .then(() => onFinish?.());
    });
  }, [roundKey, winner, items, controls, onFinish]);

  return (
    <div
      ref={containerRef}
      className="relative w-full max-w-md mx-auto h-32 overflow-hidden bg-[#0a0e17] rounded-lg border border-zinc-800"
    >
      <div className="absolute top-0 bottom-0 left-1/2 w-0.5 bg-amber-400 z-10 -translate-x-1/2 shadow-[0_0_10px_rgba(245,158,11,0.8)]" />
      <motion.div className="flex gap-2 h-full items-center px-2" animate={controls}>
        {strip.map((it, i) => (
          <div
            key={`${i}-${it.id}`}
            className={`shrink-0 w-28 h-28 flex items-center justify-center border ${rarityBorder[it.rarity] || rarityBorder.Consumer} ${rarityGlow[it.rarity] || ""} rounded`}
          >
            {it.image_url ? (
              <img
                src={it.image_url}
                alt={it.name}
                className="w-full h-full object-contain p-1"
              />
            ) : (
              <div className="text-3xl opacity-20">?</div>
            )}
          </div>
        ))}
      </motion.div>
    </div>
  );
}