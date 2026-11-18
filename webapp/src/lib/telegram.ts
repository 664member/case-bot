"use client";

export function initTelegram() {
  if (typeof window === "undefined") return null;
  const tg = (window as any).Telegram?.WebApp;
  if (!tg) return null;
  tg.ready();
  tg.expand();
  tg.setHeaderColor("#0D0D12");
  tg.setBackgroundColor("#0D0D12");
  return tg;
}

export function getInitData(): string {
  if (typeof window === "undefined") return "";
  return (window as any).Telegram?.WebApp?.initData || "";
}

export function haptic(type: "light" | "medium" | "heavy" | "success" | "error" = "medium") {
  const tg = (window as any).Telegram?.WebApp;
  if (!tg?.HapticFeedback) return;
  if (type === "success" || type === "error") {
    tg.HapticFeedback.notificationOccurred(type);
  } else {
    tg.HapticFeedback.impactOccurred(type);
  }
}