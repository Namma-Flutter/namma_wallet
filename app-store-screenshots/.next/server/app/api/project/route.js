/*
 * ATTENTION: An "eval-source-map" devtool has been used.
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file with attached SourceMaps in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
(() => {
var exports = {};
exports.id = "app/api/project/route";
exports.ids = ["app/api/project/route"];
exports.modules = {

/***/ "next/dist/compiled/next-server/app-page.runtime.dev.js":
/*!*************************************************************************!*\
  !*** external "next/dist/compiled/next-server/app-page.runtime.dev.js" ***!
  \*************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require("next/dist/compiled/next-server/app-page.runtime.dev.js");

/***/ }),

/***/ "next/dist/compiled/next-server/app-route.runtime.dev.js":
/*!**************************************************************************!*\
  !*** external "next/dist/compiled/next-server/app-route.runtime.dev.js" ***!
  \**************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require("next/dist/compiled/next-server/app-route.runtime.dev.js");

/***/ }),

/***/ "../app-render/work-async-storage.external":
/*!*****************************************************************************!*\
  !*** external "next/dist/server/app-render/work-async-storage.external.js" ***!
  \*****************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require("next/dist/server/app-render/work-async-storage.external.js");

/***/ }),

/***/ "./work-unit-async-storage.external":
/*!**********************************************************************************!*\
  !*** external "next/dist/server/app-render/work-unit-async-storage.external.js" ***!
  \**********************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require("next/dist/server/app-render/work-unit-async-storage.external.js");

/***/ }),

/***/ "node:fs":
/*!**************************!*\
  !*** external "node:fs" ***!
  \**************************/
/***/ ((module) => {

"use strict";
module.exports = require("node:fs");

/***/ }),

/***/ "node:path":
/*!****************************!*\
  !*** external "node:path" ***!
  \****************************/
/***/ ((module) => {

"use strict";
module.exports = require("node:path");

/***/ }),

/***/ "(rsc)/./node_modules/next/dist/build/webpack/loaders/next-app-loader/index.js?name=app%2Fapi%2Fproject%2Froute&page=%2Fapi%2Fproject%2Froute&appPaths=&pagePath=private-next-app-dir%2Fapi%2Fproject%2Froute.ts&appDir=%2FUsers%2Fharishanbalagan%2FDeveloper%2Fflutter%2Fnamma_wallet%2Fapp-store-screenshots%2Fsrc%2Fapp&pageExtensions=tsx&pageExtensions=ts&pageExtensions=jsx&pageExtensions=js&rootDir=%2FUsers%2Fharishanbalagan%2FDeveloper%2Fflutter%2Fnamma_wallet%2Fapp-store-screenshots&isDev=true&tsconfigPath=tsconfig.json&basePath=&assetPrefix=&nextConfigOutput=&preferredRegion=&middlewareConfig=e30%3D!":
/*!*******************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************!*\
  !*** ./node_modules/next/dist/build/webpack/loaders/next-app-loader/index.js?name=app%2Fapi%2Fproject%2Froute&page=%2Fapi%2Fproject%2Froute&appPaths=&pagePath=private-next-app-dir%2Fapi%2Fproject%2Froute.ts&appDir=%2FUsers%2Fharishanbalagan%2FDeveloper%2Fflutter%2Fnamma_wallet%2Fapp-store-screenshots%2Fsrc%2Fapp&pageExtensions=tsx&pageExtensions=ts&pageExtensions=jsx&pageExtensions=js&rootDir=%2FUsers%2Fharishanbalagan%2FDeveloper%2Fflutter%2Fnamma_wallet%2Fapp-store-screenshots&isDev=true&tsconfigPath=tsconfig.json&basePath=&assetPrefix=&nextConfigOutput=&preferredRegion=&middlewareConfig=e30%3D! ***!
  \*******************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   patchFetch: () => (/* binding */ patchFetch),\n/* harmony export */   routeModule: () => (/* binding */ routeModule),\n/* harmony export */   serverHooks: () => (/* binding */ serverHooks),\n/* harmony export */   workAsyncStorage: () => (/* binding */ workAsyncStorage),\n/* harmony export */   workUnitAsyncStorage: () => (/* binding */ workUnitAsyncStorage)\n/* harmony export */ });\n/* harmony import */ var next_dist_server_route_modules_app_route_module_compiled__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! next/dist/server/route-modules/app-route/module.compiled */ \"(rsc)/./node_modules/next/dist/server/route-modules/app-route/module.compiled.js\");\n/* harmony import */ var next_dist_server_route_modules_app_route_module_compiled__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(next_dist_server_route_modules_app_route_module_compiled__WEBPACK_IMPORTED_MODULE_0__);\n/* harmony import */ var next_dist_server_route_kind__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! next/dist/server/route-kind */ \"(rsc)/./node_modules/next/dist/server/route-kind.js\");\n/* harmony import */ var next_dist_server_lib_patch_fetch__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! next/dist/server/lib/patch-fetch */ \"(rsc)/./node_modules/next/dist/server/lib/patch-fetch.js\");\n/* harmony import */ var next_dist_server_lib_patch_fetch__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(next_dist_server_lib_patch_fetch__WEBPACK_IMPORTED_MODULE_2__);\n/* harmony import */ var _Users_harishanbalagan_Developer_flutter_namma_wallet_app_store_screenshots_src_app_api_project_route_ts__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./src/app/api/project/route.ts */ \"(rsc)/./src/app/api/project/route.ts\");\n\n\n\n\n// We inject the nextConfigOutput here so that we can use them in the route\n// module.\nconst nextConfigOutput = \"\"\nconst routeModule = new next_dist_server_route_modules_app_route_module_compiled__WEBPACK_IMPORTED_MODULE_0__.AppRouteRouteModule({\n    definition: {\n        kind: next_dist_server_route_kind__WEBPACK_IMPORTED_MODULE_1__.RouteKind.APP_ROUTE,\n        page: \"/api/project/route\",\n        pathname: \"/api/project\",\n        filename: \"route\",\n        bundlePath: \"app/api/project/route\"\n    },\n    resolvedPagePath: \"/Users/harishanbalagan/Developer/flutter/namma_wallet/app-store-screenshots/src/app/api/project/route.ts\",\n    nextConfigOutput,\n    userland: _Users_harishanbalagan_Developer_flutter_namma_wallet_app_store_screenshots_src_app_api_project_route_ts__WEBPACK_IMPORTED_MODULE_3__\n});\n// Pull out the exports that we need to expose from the module. This should\n// be eliminated when we've moved the other routes to the new format. These\n// are used to hook into the route.\nconst { workAsyncStorage, workUnitAsyncStorage, serverHooks } = routeModule;\nfunction patchFetch() {\n    return (0,next_dist_server_lib_patch_fetch__WEBPACK_IMPORTED_MODULE_2__.patchFetch)({\n        workAsyncStorage,\n        workUnitAsyncStorage\n    });\n}\n\n\n//# sourceMappingURL=app-route.js.map//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKHJzYykvLi9ub2RlX21vZHVsZXMvbmV4dC9kaXN0L2J1aWxkL3dlYnBhY2svbG9hZGVycy9uZXh0LWFwcC1sb2FkZXIvaW5kZXguanM/bmFtZT1hcHAlMkZhcGklMkZwcm9qZWN0JTJGcm91dGUmcGFnZT0lMkZhcGklMkZwcm9qZWN0JTJGcm91dGUmYXBwUGF0aHM9JnBhZ2VQYXRoPXByaXZhdGUtbmV4dC1hcHAtZGlyJTJGYXBpJTJGcHJvamVjdCUyRnJvdXRlLnRzJmFwcERpcj0lMkZVc2VycyUyRmhhcmlzaGFuYmFsYWdhbiUyRkRldmVsb3BlciUyRmZsdXR0ZXIlMkZuYW1tYV93YWxsZXQlMkZhcHAtc3RvcmUtc2NyZWVuc2hvdHMlMkZzcmMlMkZhcHAmcGFnZUV4dGVuc2lvbnM9dHN4JnBhZ2VFeHRlbnNpb25zPXRzJnBhZ2VFeHRlbnNpb25zPWpzeCZwYWdlRXh0ZW5zaW9ucz1qcyZyb290RGlyPSUyRlVzZXJzJTJGaGFyaXNoYW5iYWxhZ2FuJTJGRGV2ZWxvcGVyJTJGZmx1dHRlciUyRm5hbW1hX3dhbGxldCUyRmFwcC1zdG9yZS1zY3JlZW5zaG90cyZpc0Rldj10cnVlJnRzY29uZmlnUGF0aD10c2NvbmZpZy5qc29uJmJhc2VQYXRoPSZhc3NldFByZWZpeD0mbmV4dENvbmZpZ091dHB1dD0mcHJlZmVycmVkUmVnaW9uPSZtaWRkbGV3YXJlQ29uZmlnPWUzMCUzRCEiLCJtYXBwaW5ncyI6Ijs7Ozs7Ozs7Ozs7Ozs7QUFBK0Y7QUFDdkM7QUFDcUI7QUFDd0Q7QUFDckk7QUFDQTtBQUNBO0FBQ0Esd0JBQXdCLHlHQUFtQjtBQUMzQztBQUNBLGNBQWMsa0VBQVM7QUFDdkI7QUFDQTtBQUNBO0FBQ0E7QUFDQSxLQUFLO0FBQ0w7QUFDQTtBQUNBLFlBQVk7QUFDWixDQUFDO0FBQ0Q7QUFDQTtBQUNBO0FBQ0EsUUFBUSxzREFBc0Q7QUFDOUQ7QUFDQSxXQUFXLDRFQUFXO0FBQ3RCO0FBQ0E7QUFDQSxLQUFLO0FBQ0w7QUFDMEY7O0FBRTFGIiwic291cmNlcyI6WyIiXSwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHsgQXBwUm91dGVSb3V0ZU1vZHVsZSB9IGZyb20gXCJuZXh0L2Rpc3Qvc2VydmVyL3JvdXRlLW1vZHVsZXMvYXBwLXJvdXRlL21vZHVsZS5jb21waWxlZFwiO1xuaW1wb3J0IHsgUm91dGVLaW5kIH0gZnJvbSBcIm5leHQvZGlzdC9zZXJ2ZXIvcm91dGUta2luZFwiO1xuaW1wb3J0IHsgcGF0Y2hGZXRjaCBhcyBfcGF0Y2hGZXRjaCB9IGZyb20gXCJuZXh0L2Rpc3Qvc2VydmVyL2xpYi9wYXRjaC1mZXRjaFwiO1xuaW1wb3J0ICogYXMgdXNlcmxhbmQgZnJvbSBcIi9Vc2Vycy9oYXJpc2hhbmJhbGFnYW4vRGV2ZWxvcGVyL2ZsdXR0ZXIvbmFtbWFfd2FsbGV0L2FwcC1zdG9yZS1zY3JlZW5zaG90cy9zcmMvYXBwL2FwaS9wcm9qZWN0L3JvdXRlLnRzXCI7XG4vLyBXZSBpbmplY3QgdGhlIG5leHRDb25maWdPdXRwdXQgaGVyZSBzbyB0aGF0IHdlIGNhbiB1c2UgdGhlbSBpbiB0aGUgcm91dGVcbi8vIG1vZHVsZS5cbmNvbnN0IG5leHRDb25maWdPdXRwdXQgPSBcIlwiXG5jb25zdCByb3V0ZU1vZHVsZSA9IG5ldyBBcHBSb3V0ZVJvdXRlTW9kdWxlKHtcbiAgICBkZWZpbml0aW9uOiB7XG4gICAgICAgIGtpbmQ6IFJvdXRlS2luZC5BUFBfUk9VVEUsXG4gICAgICAgIHBhZ2U6IFwiL2FwaS9wcm9qZWN0L3JvdXRlXCIsXG4gICAgICAgIHBhdGhuYW1lOiBcIi9hcGkvcHJvamVjdFwiLFxuICAgICAgICBmaWxlbmFtZTogXCJyb3V0ZVwiLFxuICAgICAgICBidW5kbGVQYXRoOiBcImFwcC9hcGkvcHJvamVjdC9yb3V0ZVwiXG4gICAgfSxcbiAgICByZXNvbHZlZFBhZ2VQYXRoOiBcIi9Vc2Vycy9oYXJpc2hhbmJhbGFnYW4vRGV2ZWxvcGVyL2ZsdXR0ZXIvbmFtbWFfd2FsbGV0L2FwcC1zdG9yZS1zY3JlZW5zaG90cy9zcmMvYXBwL2FwaS9wcm9qZWN0L3JvdXRlLnRzXCIsXG4gICAgbmV4dENvbmZpZ091dHB1dCxcbiAgICB1c2VybGFuZFxufSk7XG4vLyBQdWxsIG91dCB0aGUgZXhwb3J0cyB0aGF0IHdlIG5lZWQgdG8gZXhwb3NlIGZyb20gdGhlIG1vZHVsZS4gVGhpcyBzaG91bGRcbi8vIGJlIGVsaW1pbmF0ZWQgd2hlbiB3ZSd2ZSBtb3ZlZCB0aGUgb3RoZXIgcm91dGVzIHRvIHRoZSBuZXcgZm9ybWF0LiBUaGVzZVxuLy8gYXJlIHVzZWQgdG8gaG9vayBpbnRvIHRoZSByb3V0ZS5cbmNvbnN0IHsgd29ya0FzeW5jU3RvcmFnZSwgd29ya1VuaXRBc3luY1N0b3JhZ2UsIHNlcnZlckhvb2tzIH0gPSByb3V0ZU1vZHVsZTtcbmZ1bmN0aW9uIHBhdGNoRmV0Y2goKSB7XG4gICAgcmV0dXJuIF9wYXRjaEZldGNoKHtcbiAgICAgICAgd29ya0FzeW5jU3RvcmFnZSxcbiAgICAgICAgd29ya1VuaXRBc3luY1N0b3JhZ2VcbiAgICB9KTtcbn1cbmV4cG9ydCB7IHJvdXRlTW9kdWxlLCB3b3JrQXN5bmNTdG9yYWdlLCB3b3JrVW5pdEFzeW5jU3RvcmFnZSwgc2VydmVySG9va3MsIHBhdGNoRmV0Y2gsICB9O1xuXG4vLyMgc291cmNlTWFwcGluZ1VSTD1hcHAtcm91dGUuanMubWFwIl0sIm5hbWVzIjpbXSwiaWdub3JlTGlzdCI6W10sInNvdXJjZVJvb3QiOiIifQ==\n//# sourceURL=webpack-internal:///(rsc)/./node_modules/next/dist/build/webpack/loaders/next-app-loader/index.js?name=app%2Fapi%2Fproject%2Froute&page=%2Fapi%2Fproject%2Froute&appPaths=&pagePath=private-next-app-dir%2Fapi%2Fproject%2Froute.ts&appDir=%2FUsers%2Fharishanbalagan%2FDeveloper%2Fflutter%2Fnamma_wallet%2Fapp-store-screenshots%2Fsrc%2Fapp&pageExtensions=tsx&pageExtensions=ts&pageExtensions=jsx&pageExtensions=js&rootDir=%2FUsers%2Fharishanbalagan%2FDeveloper%2Fflutter%2Fnamma_wallet%2Fapp-store-screenshots&isDev=true&tsconfigPath=tsconfig.json&basePath=&assetPrefix=&nextConfigOutput=&preferredRegion=&middlewareConfig=e30%3D!\n");

/***/ }),

/***/ "(rsc)/./node_modules/next/dist/build/webpack/loaders/next-flight-client-entry-loader.js?server=true!":
/*!******************************************************************************************************!*\
  !*** ./node_modules/next/dist/build/webpack/loaders/next-flight-client-entry-loader.js?server=true! ***!
  \******************************************************************************************************/
/***/ (() => {



/***/ }),

/***/ "(ssr)/./node_modules/next/dist/build/webpack/loaders/next-flight-client-entry-loader.js?server=true!":
/*!******************************************************************************************************!*\
  !*** ./node_modules/next/dist/build/webpack/loaders/next-flight-client-entry-loader.js?server=true! ***!
  \******************************************************************************************************/
/***/ (() => {



/***/ }),

/***/ "(rsc)/./src/app/api/project/route.ts":
/*!**************************************!*\
  !*** ./src/app/api/project/route.ts ***!
  \**************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   GET: () => (/* binding */ GET),\n/* harmony export */   POST: () => (/* binding */ POST),\n/* harmony export */   dynamic: () => (/* binding */ dynamic)\n/* harmony export */ });\n/* harmony import */ var node_fs__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! node:fs */ \"node:fs\");\n/* harmony import */ var node_fs__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(node_fs__WEBPACK_IMPORTED_MODULE_0__);\n/* harmony import */ var node_path__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! node:path */ \"node:path\");\n/* harmony import */ var node_path__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(node_path__WEBPACK_IMPORTED_MODULE_1__);\n/* harmony import */ var next_server__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! next/server */ \"(rsc)/./node_modules/next/dist/api/server.js\");\n\n\n\nconst dynamic = \"force-dynamic\";\nconst PROJECT_FILE = \"app-store-screenshots.json\";\nfunction filePath() {\n    return node_path__WEBPACK_IMPORTED_MODULE_1___default().join(process.cwd(), PROJECT_FILE);\n}\nasync function GET() {\n    try {\n        const raw = await node_fs__WEBPACK_IMPORTED_MODULE_0__.promises.readFile(filePath(), \"utf8\");\n        const parsed = JSON.parse(raw);\n        return next_server__WEBPACK_IMPORTED_MODULE_2__.NextResponse.json({\n            ok: true,\n            state: parsed\n        });\n    } catch (e) {\n        const code = e.code;\n        if (code === \"ENOENT\") {\n            return next_server__WEBPACK_IMPORTED_MODULE_2__.NextResponse.json({\n                ok: true,\n                state: null\n            });\n        }\n        return next_server__WEBPACK_IMPORTED_MODULE_2__.NextResponse.json({\n            ok: false,\n            error: e instanceof Error ? e.message : String(e)\n        }, {\n            status: 500\n        });\n    }\n}\nasync function POST(req) {\n    let body;\n    try {\n        body = await req.json();\n    } catch  {\n        return next_server__WEBPACK_IMPORTED_MODULE_2__.NextResponse.json({\n            ok: false,\n            error: \"Invalid JSON\"\n        }, {\n            status: 400\n        });\n    }\n    try {\n        const pretty = JSON.stringify(body, null, 2) + \"\\n\";\n        await node_fs__WEBPACK_IMPORTED_MODULE_0__.promises.writeFile(filePath(), pretty, \"utf8\");\n        return next_server__WEBPACK_IMPORTED_MODULE_2__.NextResponse.json({\n            ok: true\n        });\n    } catch (e) {\n        return next_server__WEBPACK_IMPORTED_MODULE_2__.NextResponse.json({\n            ok: false,\n            error: e instanceof Error ? e.message : String(e)\n        }, {\n            status: 500\n        });\n    }\n}\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKHJzYykvLi9zcmMvYXBwL2FwaS9wcm9qZWN0L3JvdXRlLnRzIiwibWFwcGluZ3MiOiI7Ozs7Ozs7Ozs7O0FBQXlDO0FBQ1o7QUFDYztBQUVwQyxNQUFNSSxVQUFVLGdCQUFnQjtBQUV2QyxNQUFNQyxlQUFlO0FBRXJCLFNBQVNDO0lBQ1AsT0FBT0oscURBQVMsQ0FBQ00sUUFBUUMsR0FBRyxJQUFJSjtBQUNsQztBQUVPLGVBQWVLO0lBQ3BCLElBQUk7UUFDRixNQUFNQyxNQUFNLE1BQU1WLDZDQUFFQSxDQUFDVyxRQUFRLENBQUNOLFlBQVk7UUFDMUMsTUFBTU8sU0FBU0MsS0FBS0MsS0FBSyxDQUFDSjtRQUMxQixPQUFPUixxREFBWUEsQ0FBQ2EsSUFBSSxDQUFDO1lBQUVDLElBQUk7WUFBTUMsT0FBT0w7UUFBTztJQUNyRCxFQUFFLE9BQU9NLEdBQUc7UUFDVixNQUFNQyxPQUFPLEVBQTZCQSxJQUFJO1FBQzlDLElBQUlBLFNBQVMsVUFBVTtZQUNyQixPQUFPakIscURBQVlBLENBQUNhLElBQUksQ0FBQztnQkFBRUMsSUFBSTtnQkFBTUMsT0FBTztZQUFLO1FBQ25EO1FBQ0EsT0FBT2YscURBQVlBLENBQUNhLElBQUksQ0FDdEI7WUFBRUMsSUFBSTtZQUFPSSxPQUFPRixhQUFhRyxRQUFRSCxFQUFFSSxPQUFPLEdBQUdDLE9BQU9MO1FBQUcsR0FDL0Q7WUFBRU0sUUFBUTtRQUFJO0lBRWxCO0FBQ0Y7QUFFTyxlQUFlQyxLQUFLQyxHQUFZO0lBQ3JDLElBQUlDO0lBQ0osSUFBSTtRQUNGQSxPQUFPLE1BQU1ELElBQUlYLElBQUk7SUFDdkIsRUFBRSxPQUFNO1FBQ04sT0FBT2IscURBQVlBLENBQUNhLElBQUksQ0FBQztZQUFFQyxJQUFJO1lBQU9JLE9BQU87UUFBZSxHQUFHO1lBQUVJLFFBQVE7UUFBSTtJQUMvRTtJQUNBLElBQUk7UUFDRixNQUFNSSxTQUFTZixLQUFLZ0IsU0FBUyxDQUFDRixNQUFNLE1BQU0sS0FBSztRQUMvQyxNQUFNM0IsNkNBQUVBLENBQUM4QixTQUFTLENBQUN6QixZQUFZdUIsUUFBUTtRQUN2QyxPQUFPMUIscURBQVlBLENBQUNhLElBQUksQ0FBQztZQUFFQyxJQUFJO1FBQUs7SUFDdEMsRUFBRSxPQUFPRSxHQUFHO1FBQ1YsT0FBT2hCLHFEQUFZQSxDQUFDYSxJQUFJLENBQ3RCO1lBQUVDLElBQUk7WUFBT0ksT0FBT0YsYUFBYUcsUUFBUUgsRUFBRUksT0FBTyxHQUFHQyxPQUFPTDtRQUFHLEdBQy9EO1lBQUVNLFFBQVE7UUFBSTtJQUVsQjtBQUNGIiwic291cmNlcyI6WyIvVXNlcnMvaGFyaXNoYW5iYWxhZ2FuL0RldmVsb3Blci9mbHV0dGVyL25hbW1hX3dhbGxldC9hcHAtc3RvcmUtc2NyZWVuc2hvdHMvc3JjL2FwcC9hcGkvcHJvamVjdC9yb3V0ZS50cyJdLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgeyBwcm9taXNlcyBhcyBmcyB9IGZyb20gXCJub2RlOmZzXCI7XG5pbXBvcnQgcGF0aCBmcm9tIFwibm9kZTpwYXRoXCI7XG5pbXBvcnQgeyBOZXh0UmVzcG9uc2UgfSBmcm9tIFwibmV4dC9zZXJ2ZXJcIjtcblxuZXhwb3J0IGNvbnN0IGR5bmFtaWMgPSBcImZvcmNlLWR5bmFtaWNcIjtcblxuY29uc3QgUFJPSkVDVF9GSUxFID0gXCJhcHAtc3RvcmUtc2NyZWVuc2hvdHMuanNvblwiO1xuXG5mdW5jdGlvbiBmaWxlUGF0aCgpIHtcbiAgcmV0dXJuIHBhdGguam9pbihwcm9jZXNzLmN3ZCgpLCBQUk9KRUNUX0ZJTEUpO1xufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gR0VUKCkge1xuICB0cnkge1xuICAgIGNvbnN0IHJhdyA9IGF3YWl0IGZzLnJlYWRGaWxlKGZpbGVQYXRoKCksIFwidXRmOFwiKTtcbiAgICBjb25zdCBwYXJzZWQgPSBKU09OLnBhcnNlKHJhdyk7XG4gICAgcmV0dXJuIE5leHRSZXNwb25zZS5qc29uKHsgb2s6IHRydWUsIHN0YXRlOiBwYXJzZWQgfSk7XG4gIH0gY2F0Y2ggKGUpIHtcbiAgICBjb25zdCBjb2RlID0gKGUgYXMgTm9kZUpTLkVycm5vRXhjZXB0aW9uKS5jb2RlO1xuICAgIGlmIChjb2RlID09PSBcIkVOT0VOVFwiKSB7XG4gICAgICByZXR1cm4gTmV4dFJlc3BvbnNlLmpzb24oeyBvazogdHJ1ZSwgc3RhdGU6IG51bGwgfSk7XG4gICAgfVxuICAgIHJldHVybiBOZXh0UmVzcG9uc2UuanNvbihcbiAgICAgIHsgb2s6IGZhbHNlLCBlcnJvcjogZSBpbnN0YW5jZW9mIEVycm9yID8gZS5tZXNzYWdlIDogU3RyaW5nKGUpIH0sXG4gICAgICB7IHN0YXR1czogNTAwIH0sXG4gICAgKTtcbiAgfVxufVxuXG5leHBvcnQgYXN5bmMgZnVuY3Rpb24gUE9TVChyZXE6IFJlcXVlc3QpIHtcbiAgbGV0IGJvZHk6IHVua25vd247XG4gIHRyeSB7XG4gICAgYm9keSA9IGF3YWl0IHJlcS5qc29uKCk7XG4gIH0gY2F0Y2gge1xuICAgIHJldHVybiBOZXh0UmVzcG9uc2UuanNvbih7IG9rOiBmYWxzZSwgZXJyb3I6IFwiSW52YWxpZCBKU09OXCIgfSwgeyBzdGF0dXM6IDQwMCB9KTtcbiAgfVxuICB0cnkge1xuICAgIGNvbnN0IHByZXR0eSA9IEpTT04uc3RyaW5naWZ5KGJvZHksIG51bGwsIDIpICsgXCJcXG5cIjtcbiAgICBhd2FpdCBmcy53cml0ZUZpbGUoZmlsZVBhdGgoKSwgcHJldHR5LCBcInV0ZjhcIik7XG4gICAgcmV0dXJuIE5leHRSZXNwb25zZS5qc29uKHsgb2s6IHRydWUgfSk7XG4gIH0gY2F0Y2ggKGUpIHtcbiAgICByZXR1cm4gTmV4dFJlc3BvbnNlLmpzb24oXG4gICAgICB7IG9rOiBmYWxzZSwgZXJyb3I6IGUgaW5zdGFuY2VvZiBFcnJvciA/IGUubWVzc2FnZSA6IFN0cmluZyhlKSB9LFxuICAgICAgeyBzdGF0dXM6IDUwMCB9LFxuICAgICk7XG4gIH1cbn1cbiJdLCJuYW1lcyI6WyJwcm9taXNlcyIsImZzIiwicGF0aCIsIk5leHRSZXNwb25zZSIsImR5bmFtaWMiLCJQUk9KRUNUX0ZJTEUiLCJmaWxlUGF0aCIsImpvaW4iLCJwcm9jZXNzIiwiY3dkIiwiR0VUIiwicmF3IiwicmVhZEZpbGUiLCJwYXJzZWQiLCJKU09OIiwicGFyc2UiLCJqc29uIiwib2siLCJzdGF0ZSIsImUiLCJjb2RlIiwiZXJyb3IiLCJFcnJvciIsIm1lc3NhZ2UiLCJTdHJpbmciLCJzdGF0dXMiLCJQT1NUIiwicmVxIiwiYm9keSIsInByZXR0eSIsInN0cmluZ2lmeSIsIndyaXRlRmlsZSJdLCJpZ25vcmVMaXN0IjpbXSwic291cmNlUm9vdCI6IiJ9\n//# sourceURL=webpack-internal:///(rsc)/./src/app/api/project/route.ts\n");

/***/ })

};
;

// load runtime
var __webpack_require__ = require("../../../webpack-runtime.js");
__webpack_require__.C(exports);
var __webpack_exec__ = (moduleId) => (__webpack_require__(__webpack_require__.s = moduleId))
var __webpack_exports__ = __webpack_require__.X(0, ["vendor-chunks/next"], () => (__webpack_exec__("(rsc)/./node_modules/next/dist/build/webpack/loaders/next-app-loader/index.js?name=app%2Fapi%2Fproject%2Froute&page=%2Fapi%2Fproject%2Froute&appPaths=&pagePath=private-next-app-dir%2Fapi%2Fproject%2Froute.ts&appDir=%2FUsers%2Fharishanbalagan%2FDeveloper%2Fflutter%2Fnamma_wallet%2Fapp-store-screenshots%2Fsrc%2Fapp&pageExtensions=tsx&pageExtensions=ts&pageExtensions=jsx&pageExtensions=js&rootDir=%2FUsers%2Fharishanbalagan%2FDeveloper%2Fflutter%2Fnamma_wallet%2Fapp-store-screenshots&isDev=true&tsconfigPath=tsconfig.json&basePath=&assetPrefix=&nextConfigOutput=&preferredRegion=&middlewareConfig=e30%3D!")));
module.exports = __webpack_exports__;

})();