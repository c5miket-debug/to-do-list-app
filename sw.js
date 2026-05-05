// TaskFlow Service Worker
// Strategy: Cache-first for app shell, network-first for Supabase API calls

const CACHE_NAME = 'taskflow-v2';

// App shell files to cache on install
const SHELL_FILES = [
  '/',
  '/index.html',
  '/manifest.json',
  'https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=DM+Mono:wght@400;500&display=swap',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2'
];

// ── Install: cache the app shell ──────────────────────────────────────────────
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      // Cache what we can; don't fail install if CDN files are slow
      return cache.addAll(SHELL_FILES).catch((err) => {
        console.warn('[SW] Some shell files failed to cache:', err);
      });
    })
  );
  // Activate immediately without waiting for old tabs to close
  self.skipWaiting();
});

// ── Activate: clean up old caches ─────────────────────────────────────────────
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key))
      )
    )
  );
  self.clients.claim();
});

// ── Fetch: routing strategy ───────────────────────────────────────────────────
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // 1. Supabase API calls → always network, never cache
  if (url.hostname.includes('supabase.co')) {
    event.respondWith(fetch(event.request));
    return;
  }

  // 2. Google Fonts → cache-first (they change rarely)
  if (url.hostname.includes('fonts.googleapis.com') || url.hostname.includes('fonts.gstatic.com')) {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        if (cached) return cached;
        return fetch(event.request).then((response) => {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
          return response;
        });
      })
    );
    return;
  }

  // 3. CDN scripts (Supabase SDK) → cache-first
  if (url.hostname.includes('jsdelivr.net') || url.hostname.includes('cdnjs.cloudflare.com')) {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        if (cached) return cached;
        return fetch(event.request).then((response) => {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
          return response;
        });
      })
    );
    return;
  }

  // 4. App shell (HTML, icons, manifest) → network-first, fall back to cache
  //    This ensures you always get the latest index.html when online
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Cache successful responses
        if (response && response.status === 200) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
        }
        return response;
      })
      .catch(() => {
        // Offline fallback: serve from cache
        return caches.match(event.request).then((cached) => {
          if (cached) return cached;
          // If requesting a page and nothing cached, return index.html
          if (event.request.mode === 'navigate') {
            return caches.match('/index.html');
          }
        });
      })
  );
});
