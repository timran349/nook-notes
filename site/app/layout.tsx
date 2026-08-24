import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Nook Notes — Small notes. Always within reach.",
  description: "A tiny sticky-notes utility for macOS that lives quietly in the bottom-left corner of your screen.",
  icons: {
    icon: "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📝</text></svg>",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="min-h-screen flex items-center justify-center p-6 sm:p-12">
        {children}
      </body>
    </html>
  );
}
