(function () {
    const debugTag = "[TicketListDebug]";

    const parsePageModel = () => {
        const modelScript = document.getElementById("ticket-list-debug-model");
        if (!modelScript) return null;

        try {
            return JSON.parse(modelScript.textContent || "null");
        } catch (error) {
            console.error(`${debugTag} parse-model-error`, error);
            return null;
        }
    };

    const summarizeTable = (table) => {
        if (!table) return null;

        return {
            pageTitle: table.pageTitle,
            panelTitle: table.panelTitle,
            rowIdField: table.rowIdField,
            storageKey: table.storageKey,
            rowCount: Array.isArray(table.rows) ? table.rows.length : 0,
            columns: Array.isArray(table.columns)
                ? table.columns.map((column) => ({
                    field: column.field,
                    label: column.label,
                    visible: column.visible,
                    type: column.type
                }))
                : [],
            rows: Array.isArray(table.rows) ? table.rows : []
        };
    };

    const normalizeBody = (body) => {
        if (!body) return null;

        if (typeof body === "string") {
            try {
                return JSON.parse(body);
            } catch {
                return body;
            }
        }

        if (body instanceof FormData) {
            const entries = {};
            for (const [key, value] of body.entries()) {
                entries[key] = value instanceof File
                    ? { name: value.name, size: value.size, type: value.type }
                    : value;
            }

            return entries;
        }

        return body;
    };

    const shouldLogFetch = (url) => {
        if (!url) return false;

        try {
            const absoluteUrl = new URL(url, window.location.origin);
            return absoluteUrl.pathname.startsWith("/crud/")
                || absoluteUrl.pathname.startsWith("/Ticket/")
                || absoluteUrl.pathname.startsWith("/ticket/");
        } catch {
            return false;
        }
    };

    const installFetchLogger = () => {
        if (window.__ticketListDebug?.fetchWrapped || typeof window.fetch !== "function") return;

        const originalFetch = window.fetch.bind(window);
        window.__ticketListDebug = window.__ticketListDebug || {};
        window.__ticketListDebug.fetchWrapped = true;

        window.fetch = async function (input, init) {
            const requestUrl = typeof input === "string"
                ? input
                : input?.url || "";
            const method = (init?.method || (typeof input !== "string" ? input?.method : null) || "GET").toUpperCase();
            const shouldLog = shouldLogFetch(requestUrl);
            const startedAt = performance.now();

            if (shouldLog) {
                console.groupCollapsed(`${debugTag} request ${method} ${requestUrl}`);
                console.log("request", {
                    url: requestUrl,
                    method,
                    headers: init?.headers || null,
                    body: normalizeBody(init?.body)
                });
            }

            try {
                const response = await originalFetch(input, init);

                if (shouldLog) {
                    const clonedResponse = response.clone();
                    const contentType = clonedResponse.headers.get("content-type") || "";
                    let responseBody;

                    try {
                        responseBody = contentType.includes("application/json")
                            ? await clonedResponse.json()
                            : await clonedResponse.text();
                    } catch (error) {
                        responseBody = { parseError: String(error) };
                    }

                    console.log("response", {
                        url: response.url,
                        status: response.status,
                        ok: response.ok,
                        redirected: response.redirected,
                        durationMs: Math.round((performance.now() - startedAt) * 100) / 100,
                        body: responseBody
                    });
                    console.groupEnd();
                }

                return response;
            } catch (error) {
                if (shouldLog) {
                    console.error(`${debugTag} fetch-error`, error);
                    console.groupEnd();
                }

                throw error;
            }
        };
    };

    const init = () => {
        const pageModel = parsePageModel();

        window.__ticketListDebug = window.__ticketListDebug || {};
        window.__ticketListDebug.pageModel = pageModel;

        console.groupCollapsed(`${debugTag} initial-page-model`);
        console.log("pageModel", pageModel);
        console.log("tableDS", summarizeTable(pageModel?.tableDS));
        console.log("tableDS1", summarizeTable(pageModel?.tableDS1));
        console.log("tableDS2", summarizeTable(pageModel?.tableDS2));
        console.groupEnd();

        installFetchLogger();
    };

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init, { once: true });
    } else {
        init();
    }
})();

// ── requesterTypeToggle ───────────────────────────────────────────────────────
// يُظهر حقل المقيم (p04) عند اختيار "مقيم" (value=1),
// ويُظهر حقل المستخدم (_p03display) عند اختيار أي نوع آخر,
// ويُخفي الاثنين عند عدم الاختيار.
// يُستدعى عبر: OnChangeJs = "requesterTypeToggle(this);"
// الإخفاء الأوّلي يعتمد على: .form-group:has(.sf-toggle-hidden){display:none}
// ──────────────────────────────────────────────────────────────────────────────
(function () {
    // inject initial-hide CSS once (avoids editing Default.cshtml or site.css)
    var styleId = 'sf-toggle-hidden-style';
    if (!document.getElementById(styleId)) {
        var s = document.createElement('style');
        s.id = styleId;
        s.textContent = '.form-group:has(.sf-toggle-hidden){display:none}';
        document.head.appendChild(s);
    }

    window.requesterTypeToggle = function (el) {
        var form = el.closest('form');
        if (!form) return;
        var g3 = form.querySelector('[name="_p03display"]')?.closest('.form-group');
        var g4 = form.querySelector('[name="p04"]')?.closest('.form-group');
        if (el.value === '1') {
            if (g3) g3.style.display = 'none';
            if (g4) g4.style.display = '';
        } else if (el.value) {
            if (g3) g3.style.display = '';
            if (g4) g4.style.display = 'none';
        } else {
            if (g3) g3.style.display = 'none';
            if (g4) g4.style.display = 'none';
        }
    };
})();