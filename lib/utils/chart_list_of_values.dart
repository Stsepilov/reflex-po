import 'dart:async';
import 'dart:math';
typedef OnNewDataCallback = void Function(List<double> values, double width, double height);
void getValues(OnNewDataCallback callback, width, height) {
  Timer.periodic(const Duration(milliseconds: 500), (timer) {
    List<double> values = [];
    for (int i = 0; i < 100; i++) {
      double newValue = (0.5 + (1 - 0.5) * Random().nextDouble()) * 3000;
      values.add(newValue);
    }
    callback(values, width, height);
  });
  // String points = "2262 2403 2349 2225 2405 2445 2337 2211 2342 2323 2332 2266 2300 2341 2352 2403 2294 2413 2193 2299 2304 2319 2323 2261 2288 2383 2183 2343 2338 2406 2297 2360 2352 2304 2336 2193 2714 3091 2437 2306 2320 2339 2426 2320 2335 2304 2385 2432 2239 2311 2326 2356 2384 2559 2368 2371 2352 2406 2399 2455 2448 2608 2485 2496 2593 2620 2435 2480 2369 2285 2401 2271 2341 2409 2291 2369 2259 2354 2279 2278 2309 2449 2294 2433 2330 2380 2315 2321 2324 2406 2352 2439 2386 2375 2427 2355 2286 2357 2313 2298";
  // List<double> values = points.split(' ').map((e) => double.parse(e)).toList();
  // callback(values, width, height);
}
