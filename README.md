# beancount-stack

Container image for [Beancount](https://beancount.github.io/) v3 + [Fava](https://beancount.github.io/fava/),
with the statement importers and investment reports worth having:

| package | version | why it is here |
|---|---|---|
| beancount | 3.2.3 | the ledger engine (v3) |
| fava | 1.30.16 | web UI |
| beanquery | 0.2.0 | BQL queries (`bean-query`) |
| beancount-reds-importers | 1.0.0 | importers for chase, fidelity, etrade, vanguard, schwab, ibkr, ally, amex, citi, discover, morganstanley + `bean-download` |
| beangulp | 0.2.0 | the v3 import framework those importers plug into |
| smart-importer | 1.2 | ML payee/account suggestion during import |
| fava-investor | 1.0.1 | asset allocation, tax-loss harvesting, gains minimisation, cash drag |

**No data is baked in.** The ledger is mounted at `/data`; mount it read-only for viewing.

## Build

```sh
podman build -t beancount-stack:dev .
```

## Run (view)

```sh
podman run --rm -p 5000:5000 -v "$PWD/example:/data:ro" beancount-stack:dev
```

## Run one of the tools

```sh
podman run --rm --entrypoint bean-check -v "$PWD/example:/data:ro" \
  beancount-stack:dev /data/ledger.beancount

podman run --rm --entrypoint bean-query -v "$PWD/example:/data:ro" \
  beancount-stack:dev /data/ledger.beancount "SELECT account, sum(position) GROUP BY account"
```

Entry points the image carries: `fava` (default), `bean-check`, `bean-query`, `bean-format`,
`bean-doctor`, `bean-example`, `bean-download`, `ofx-summarize`, `reds-ibkr-flexquery-download`,
`investor`, `scaled-navs`, `ticker-util`.

Note that `beangulp` ships **no CLI**: `bean-download` downloads statements, but the extraction step is a
small Python script using beangulp + the importers. That script is not written yet.

## Not here yet

- the import script (needs a decision on account naming)
- where the ledger lives (git repo vs PVC) - deliberately undecided
- the k8s manifests - those belong in home-ops, not here
- the publish workflow is committed but unproven until the first push
