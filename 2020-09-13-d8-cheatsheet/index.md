---
title: "d8 cheatsheet"
date: "2020-09-13"
---

[d8](https://source.chromium.org/chromium/chromium/src/+/master:v8/src/d8/d8.h?q=d8&ss=chromium) is V8 developer shell\[efn\_note\]d8 stands for developer the same way i18n stands for internationalization and l10n stands for localization.\[/efn\_note\]: a powerful JavaScript interpreter and a convenient tool for developing CLI-based utilities.

Useful documentation for d8 include:

- the [d8 page](https://v8.dev/docs/d8) on v8.dev
- Kevin Ennis’s [d8 guide](https://gist.github.com/kevincennis/0cd2138c78a07412ef21)
- the [getting started with d8 pages](https://riptutorial.com/v8/example/25393/useful-built-in-functions-and-objects-in-d8) on RIP tutorial

Of particular interest:

- [new Worker with inlined script](#new-worker-with-inlined-script)

#### New Worker with inlined script

This undocumented syntax\[efn\_note\]Look for the `Shell::WorkerNew` method in the d8 [source](https://denolib.github.io/v8-docs/d8_8cc_source.html).\[/efn\_note\] allows for spawning a Worker and passing the script parameter directly as a string.

Note that d8 does not support the [location construct](https://stackoverflow.com/questions/12381882/can-i-pass-parameters-to-js-function-when-i-create-the-new-web-workers-object) for passing environment variables to a new worker: instead simply set the variables directly in the code of the worker.
