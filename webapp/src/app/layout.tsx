import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import Script from "next/script";
import "./globals.css";
import { BottomNav } from "@/components/BottomNav";
import { SubscriptionGuard } from "@/components/SubscriptionGuard";
import { RulesModal } from "@/components/RulesModal";

const geistSans = Geist({ variable: "--font-geist-sans", subsets: ["latin"] });
const geistMono = Geist_Mono({ variable: "--font-geist-mono", subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Case Bot",
  description: "CS2-style case opening",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ru" suppressHydrationWarning>
      <head>
        <Script src="https://telegram.org/js/telegram-web-app.js" strategy="beforeInteractive" />
      </head>
      <body className={`${geistSans.variable} ${geistMono.variable} antialiased pb-32`}>
        <SubscriptionGuard>
          {children}
        </SubscriptionGuard>
        <BottomNav />
        <RulesModal />
      </body>
    </html>
  );
}