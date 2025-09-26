import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "OO-Studio | Creative AI Solutions for Every Industry",
  description: "Transform your business with OO-Studio's custom AI solutions for software, media, finance, healthcare, and more. Expert development and innovative technology.",
  keywords: ["AI solutions", "software development", "media production", "finance technology", "healthcare innovation", "OO-Studio"],
  authors: [{ name: "OO-Studio" }],
  openGraph: {
    title: "OO-Studio | Creative AI Solutions",
    description: "Transform your business with custom AI solutions for every industry",
    url: "https://my-app-eta-ten-45.vercel.app",
    siteName: "OO-Studio",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "OO-Studio | Creative AI Solutions",
    description: "Transform your business with custom AI solutions for every industry",
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
    },
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
        {children}
      </body>
    </html>
  );
}
