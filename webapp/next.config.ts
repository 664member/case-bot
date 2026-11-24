import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  allowedDevOrigins: ["yale-strange-bytes-card.trycloudflare.com"],
  devIndicators: false,
  async rewrites() {
    return [
      {
        source: "/api/webapp/:path*",
        destination: "http://localhost:8000/api/webapp/:path*",
      },
      {
        source: "/static/:path*",
        destination: "http://localhost:8000/static/:path*",
      },
    ];
  },
};

export default nextConfig;