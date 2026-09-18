# R2 smoke test

No hay cuenta Cloudflare todavía. Cuando existan el Account ID y las URLs prefirmadas:

```bash
dart run tool/r2_smoke_test.dart --put-url "https://..." --get-url "https://..."
```

El script sube 32 bytes y los vuelve a bajar. Si coinciden, R2 está bien cableado.
