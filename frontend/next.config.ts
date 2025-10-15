import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async rewrites() {
    // In Docker, "backend" is the service name
    const target = process.env.NEXT_PUBLIC_API_URL ?? "http://backend:8000";
    return [{ source: "/api/:path*", destination: `${target}/:path*` }];
  },
};

export default nextConfig;
