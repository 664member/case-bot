"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

const links = [
  { href: "/", label: "🎰 Кейсы" },
  { href: "/leaderboard", label: "🏆 Топ" },
  { href: "/tasks", label: "✅ Задания" },
  { href: "/profile", label: "👤 Профиль" },
];

export function BottomNav() {
  const pathname = usePathname();
  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-[#131824] border-t border-[#1f2637] flex justify-around pt-3 pb-[calc(0.75rem+env(safe-area-inset-bottom,0px))] z-50">
      {links.map((l) => (
        <Link
          key={l.href}
          href={l.href}
          className={`text-xs px-2 py-1 rounded ${pathname === l.href ? "text-white bg-[#1f2637]" : "text-zinc-400"}`}
        >
          {l.label}
        </Link>
      ))}
    </nav>
  );
}