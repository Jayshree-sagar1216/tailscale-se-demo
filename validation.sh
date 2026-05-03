#!/bin/bash
# validation.sh — Proves the Tailscale demo environment is working correctly

echo ""
echo "========================================"
echo "  Tailscale Demo — Validation Script"
echo "========================================"
echo ""

echo "TEST 1 — Internal Employee Portal (over Tailscale)"
echo "---------------------------------------------------"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://tailscale-demo-server:3000
echo ""

echo "TEST 2 — Private API (over Tailscale)"
echo "---------------------------------------------------"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://tailscale-demo-server:5000
echo ""

echo "TEST 3 — Public internet CANNOT reach port 3000"
echo "---------------------------------------------------"
curl --max-time 10 -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://18.220.17.216:3000 || echo "Connection timed out — not publicly exposed"
echo ""

echo "TEST 4 — Tailscale status"
echo "---------------------------------------------------"
tailscale status
echo ""

echo "========================================"
echo "  Validation Complete"
echo "========================================"
