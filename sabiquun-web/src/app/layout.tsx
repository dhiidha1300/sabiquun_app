import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { Toaster } from "@/components/ui/sonner";
import { Providers } from "./providers";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Sabiquun - Track Your Daily Deeds",
  description: "Sabiquun helps you stay accountable to your daily Islamic obligations. Track your prayers, good deeds, and build lasting spiritual habits.",
  keywords: ["islamic", "deeds", "prayers", "accountability", "spiritual", "muslim"],
  authors: [{ name: "Sabiquun" }],
  openGraph: {
    title: "Sabiquun - Track Your Daily Deeds",
    description: "Sabiquun helps you stay accountable to your daily Islamic obligations. Track your prayers, good deeds, and build lasting spiritual habits.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        <Providers>
          {children}
        </Providers>
        <Toaster position="top-right" />
      </body>
    </html>
  );
}
