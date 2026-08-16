# ozerk CLI

**Türkçe** | [English](#english)

`ozerk`, OZERK uygulamaları için geliştirici komut satırı aracıdır. Manifesto §12'deki geliştirici akışını (`init`, `run`, `test`, `permissions`, `build`, `verify`, `publish`) izler.

**Dürüst durum:** Bu bir iskelettir. Yalnızca `ozerk init` gerçek bir iş yapar: Manifesto §13'teki alanları izleyen taslak bir `ozerk.toml` uygulama manifesti üretir (var olan dosyanın üzerine yazmaz). Diğer bütün alt komutlar ne yapacaklarını açıklayan bir mesaj basıp çıkar; henüz uygulanmamışlardır.

## Derleme

Rust araç zinciri (cargo) gerekir.

```bash
cd sdk/cli
cargo build
cargo run -- --help
cargo run -- init
```

## Lisans

Apache-2.0. Her kaynak dosya SPDX başlığı taşır.

---

## English

*The Turkish text is normative in case of discrepancy.*

`ozerk` is the developer command-line tool for OZERK applications. It follows the developer flow in Manifesto §12 (`init`, `run`, `test`, `permissions`, `build`, `verify`, `publish`).

**Honest status:** This is a skeleton. Only `ozerk init` does real work: it generates a draft `ozerk.toml` application manifest following the fields in Manifesto §13 (it never overwrites an existing file). All other subcommands print a message explaining what they will do and exit; they are not implemented yet.

## Building

The Rust toolchain (cargo) is required.

```bash
cd sdk/cli
cargo build
cargo run -- --help
cargo run -- init
```

## License

Apache-2.0. Every source file carries an SPDX header.
