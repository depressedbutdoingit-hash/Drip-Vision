// Optional Worker entry. Static assets are served from build/web.
// You can add API routes here later if needed.
export default {
  async fetch(request, env) {
    // Let the assets binding handle everything by default
    return env.ASSETS.fetch(request);
  },
};