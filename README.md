# SysGuard

SysGuard is a Bash command-line tool for inspecting system resources and basic diagnostics. It provides direct commands for quick checks and an interactive menu when run without arguments.

## Platform support

SysGuard currently targets **Linux** and has been exercised in Ubuntu on WSL 2. Its CPU, memory, disk I/O, and network diagnostics read Linux `/proc` files. macOS and native Windows are not supported yet.

The scripts use Bash and common Linux utilities such as `awk`, `df`, `ps`, and `realpath`. Network addresses are shown when the `ip` command is available; traffic counters and rates do not require it.

## Get started

```bash
git clone https://github.com/whistyx1/SysGuard.git
cd SysGuard
bash ./sysguard --help
bash ./sysguard
```

You can also run a command directly, without opening the menu:

```bash
bash ./sysguard system
bash ./sysguard cpu
bash ./sysguard memory
```

## Commands

| Command | What it shows |
| --- | --- |
| `system` | Host name, architecture, OS, kernel, uptime, and load average |
| `cpu [--per-core]` | CPU model, logical cores, usage, load average, and optional per-core usage |
| `memory` | RAM and swap capacity and usage |
| `disk [path]` | All mounted filesystems, or the filesystem containing `path` |
| `disk --io` | Disk read/write counters and rates |
| `processes` | Process count and top processes by CPU and memory |
| `network` | Network interfaces, addresses, traffic counters, and rates |
| `all` | System, CPU, memory, disk filesystems, and processes |
| `--help` | Command help |
| `--version` | Version number |

`cpu`, `disk --io`, and `network` sample counters for one second when calculating rates. The `all` command does not include network or disk I/O diagnostics; run those separately.

Examples:

```bash
bash ./sysguard disk /
bash ./sysguard cpu --per-core
bash ./sysguard disk --io
bash ./sysguard network
```

## Checks

Run the integration checks on Linux or WSL:

```bash
bash tests/run.sh
```

The checks exercise the CLI and confirm expected output fields and error handling. They do not verify the accuracy of every reported metric.

## Project status

The current version reports `0.1.0`. Linux is the current development focus; broader platform support remains a future goal.

## License

See [LICENSE](LICENSE).
