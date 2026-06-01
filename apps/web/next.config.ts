import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  transpilePackages: ["@pub/db"],
  turbopack: {
    root: "../..",
  },
};

export default nextConfig;
