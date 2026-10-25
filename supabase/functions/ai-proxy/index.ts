// AI proxy for the SynappKit editor (P0-03).
//
// Keeps provider API keys server-side. The editor sends
//   POST { provider: "claude" | "openai" | "gemini" | "deepseek" | "kimi", body: {...} }
// when built with --dart-define=AI_PROXY_URL=https://<project>.functions.supabase.co/ai-proxy
//
// Deploy:
//   supabase secrets set ANTHROPIC_API_KEY=... OPENAI_API_KEY=... GEMINI_API_KEY=... DEEPSEEK_API_KEY=... OPENROUTER_API_KEY=...
//   supabase functions deploy ai-proxy
//
// Add per-user quotas here (for example a counter table keyed by the
// caller's JWT) before exposing this publicly.

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const openAiCompatible: Record<string, { url: string; key: string }> = {
  openai: { url: "https://api.openai.com/v1/chat/completions", key: "OPENAI_API_KEY" },
  deepseek: { url: "https://api.deepseek.com/chat/completions", key: "DEEPSEEK_API_KEY" },
  kimi: { url: "https://openrouter.ai/api/v1/chat/completions", key: "OPENROUTER_API_KEY" },
  gemini: { url: "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions", key: "GEMINI_API_KEY" },
};

function error(status: number, message: string): Response {
  return new Response(JSON.stringify({ error: { message } }), { status, headers: { ...cors, "content-type": "application/json" } });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: cors });
  if (req.method !== "POST") return error(405, "Method not allowed");

  let payload: { provider?: string; body?: Record<string, unknown> };
  try {
    payload = await req.json();
  } catch {
    return error(400, "Invalid JSON");
  }
  const { provider, body } = payload;
  if (!provider || !body) return error(400, "provider and body are required");

  let upstream: Response;
  if (provider === "claude") {
    upstream = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": Deno.env.get("ANTHROPIC_API_KEY") ?? "",
        "anthropic-version": "2026-10-21",
        "anthropic-beta": "server-side-fallback-2026-07-01",
      },
      body: JSON.stringify(body),
    });
  } else if (openAiCompatible[provider]) {
    const target = openAiCompatible[provider];
    const { endpoint: _endpoint, ...rest } = body as Record<string, unknown>;
    upstream = await fetch(target.url, {
      method: "POST",
      headers: { "content-type": "application/json", authorization: `Bearer ${Deno.env.get(target.key) ?? ""}` },
      body: JSON.stringify(rest),
    });
  } else {
    return error(400, `Unknown provider ${provider}`);
  }

  return new Response(await upstream.text(), {
    status: upstream.status,
    headers: { ...cors, "content-type": "application/json" },
  });
});
