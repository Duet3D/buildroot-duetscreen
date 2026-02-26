# OP-TEE Binary Analysis: `optee.bin`

## File Information

| Property | Value |
|---|---|
| **File** | `board/duet3d/duetscreen/bin/optee.bin` |
| **Size** | 275,672 bytes (0x434D8) |
| **MD5** | `d93b1abc7a68493f17de9b028c6d83af` |
| **Architecture** | ARM 32-bit (Cortex-A7) |
| **Target SoC** | Allwinner T113 (sun8i) |
| **Load Address** | `0x41B00000` |
| **OP-TEE Version** | 3.7 |
| **Git Commit** | `56aef7bb2-dirty` |
| **Build Date** | Fri Jul 23 09:25:11 UTC 2021 |
| **Compiler** | Linaro GCC 5.3-2016.05 (gcc 5.3.1 20160412) |
| **GPD API Version** | GPD-1.1-dev |

> **Note**: This binary is byte-identical (same MD5 hash) to
> `board/allwinner-generic/sun8i-t113/bin/optee.fex`, confirming it is the
> standard Allwinner T113 BSP OP-TEE image—not a custom or modified build.

---

## What is OP-TEE?

OP-TEE (Open Portable Trusted Execution Environment) is an open-source TEE
designed as a companion to a non-secure Linux kernel running on ARM processors
with TrustZone. It implements the GlobalPlatform TEE specifications, providing
a secure OS in the ARM TrustZone "Secure World" for running Trusted
Applications (TAs) that handle sensitive operations like key storage,
cryptography, and DRM.

---

## Binary Layout

The binary uses the Allwinner TOC0 (Table of Contents) boot format wrapper:

| Offset Range | Size | Description |
|---|---|---|
| `0x000000–0x000200` | 512 B | **Allwinner TOC0 Header** — branch instruction, "optee" magic, version "3.7", "CHKv1.0" checksum, "AW_PUBK!" public key marker |
| `0x000C00–0x000D00` | 256 B | **BootInfo** section |
| `0x002000–0x002200` | 512 B | **Early Boot Code** (ARM mode) — CPU init, coprocessor setup, MMU config, BSS clear, stack setup |
| `0x004000–0x005900` | 6,400 B | **OP-TEE Image Header** + initialization data/tables |
| `0x006000–0x009D00` | 15,616 B | **ARM Exception Vectors** + Secure Monitor Call handlers |
| `0x00A100–0x02E900` | 149,504 B | **Main OP-TEE OS Code** (Thumb-2 mode) — kernel, TA management, crypto, services |
| `0x02F000–0x033B00` | 19,200 B | **Library Code** (Thumb-2 mode) — libtomcrypt, math, memory allocators |
| `0x034000–0x042400` | 58,368 B | **Read-Only Data** — strings, ECC curve parameters, AES S-boxes, constant tables |
| `0x043000–0x0434D8` | 1,240 B | **Key/eFuse Definition Tables** + final init data |

---

## Disassembly Analysis

### Entry Point (0x2000)

The code entry point performs standard OP-TEE ARM Cortex-A7 initialization:

1. **Register save**: Saves `LR`, `R0–R2` (boot parameters from bootloader)
2. **Mode switch**: `CPS #19` — enters Supervisor (SVC) mode
3. **FPU/NEON enable**: Configures CPACR and FPEXC coprocessor registers
4. **CPU identification**: Reads MIDR register, checks for Cortex-A7 (`0xC08`) or Cortex-A15 (`0xC0F`), sets SMP bit in ACTLR accordingly
5. **SCTLR configuration**: Disables MMU, D-cache, I-cache, alignment checks; enables branch prediction
6. **VBAR setup**: Sets Vector Base Address Register to `0x41B065A0`
7. **Core ID check**: Determines primary vs secondary core; secondary cores enter WFI loop
8. **BSS clear**: Zeros the BSS section
9. **Stack setup**: Configures per-core stack pointers
10. **Runtime init**: Calls `init_sec_mon`, `init_tee_runtime`, `init_mem_map`, memory mapping, and TA infrastructure setup
11. **Boot handoff**: Issues `SMC #0` with `0xBE000000` (OPTEE return to normal world), then enters infinite loop

This is **entirely standard** OP-TEE boot code for a dual-core Cortex-A7 SoC.

### Exception Vectors (0x6000)

Standard ARM exception vector table with handlers for:
- Reset, Undefined Instruction, SVC, Prefetch Abort, Data Abort, IRQ, FIQ
- Secure Monitor Call (SMC) entry/exit for world switching between Normal World (Linux) and Secure World (OP-TEE)

### Main OS Code (0xA100–0x2E900)

The bulk of the binary contains standard OP-TEE OS modules, identified through
debug strings and code structure:

#### Core Kernel
- **Thread management** (`core/arch/arm/kernel/thread.c`, `thread_optee_smc.c`)
- **Abort/exception handling** (`abort.c`) — with data/prefetch abort handlers
- **Mutex/spinlocks** (`mutex.c`, `spin_lock_debug.c`)
- **Generic boot** (`generic_boot.c`) — memory map discovery, NS memory setup
- **Memory management** — MMU page table management, phys/virt mapping

#### Trusted Application Framework
- **User TA loader** (`user_ta.c`) — ELF loading via ldelf, lifecycle management
- **Pseudo TA framework** (`pseudo_ta.c`) — built-in TA support
- **TA manager** (`tee_ta_manager.c`) — session open/close, invoke, reference counting
- **ldelf** (`ldelf/main.c`, `ldelf/ta_elf.c`, `ldelf/ta_elf_rel.c`) — ELF dynamic linker for loading TAs

#### Cryptographic Services
- **libtomcrypt**: AES (ECB, CBC, CTR, XTS, CCM), RSA, ECC (ECDSA with NIST curves), SHA/HMAC, CMAC
- **RNG initialization** (`plat_rng_init`)
- **Big number math** (MPI via libtomcrypt)
- **Key derivation** and PKCS#1 support
- ECC curves: Full NIST curve set (P-192 through P-521), Brainpool curves

#### Secure Storage
- **REE filesystem** (`tee_ree_fs.c`) — file-based secure storage backed by normal world filesystem
- **Hash tree** (`fs_htree.c`) — Merkle tree integrity protection for stored data
- **Directory file** (`fs_dirfile.c`) — directory management for secure objects
- **TA database** (`tadb.c`) — trusted application persistent storage

---

## Embedded Trusted Applications (PTAs)

The following Pseudo Trusted Applications are compiled into the binary:

| PTA Name | Purpose |
|---|---|
| `device.pta` | Device information/properties |
| `system.pta` | System services (TA binary mapping, dlopen/dlsym, memory stats) |
| `sunxi_utils.ta` | **Allwinner-specific**: eFuse reading, RPMB key management, secure object storage, dm-crypt key handling |
| `stats.ta` | Memory allocation statistics (heap, DDR pools) |
| `invoke_tests.pta` | Self-test/diagnostic tests |
| `interrupt_tests.ta` | Interrupt handling tests |

---

## Allwinner-Specific Extensions

The binary includes Allwinner (Sunxi) BSP extensions that are **standard** for
Allwinner T113 SoCs:

### Key/eFuse Management
Hardware-backed key storage definitions found at offset `0x43100`:

| Key Name | Description |
|---|---|
| `hdcphash` | HDCP hash storage area |
| `huk` | Hardware Unique Key (device-specific, burned in silicon) |
| `ssk` | Secure Storage Key (SoC-level key) |
| `rssk` | Root Secure Storage Key |
| `oem_secure` | OEM-specific secure storage area |

### Hardware Crypto Engine
- `sunxi_aes_encrypt_with_hardware` — Hardware AES encryption via Allwinner crypto engine (CE)
- `sunxi_aes_decrypt_with_hardware` — Hardware AES decryption
- `sunxi_aes_decrypt_with_hardware_ssk` — Decryption using SSK-derived key
- `sunxi_aes_decrypt_with_hardware_rssk` — Decryption using RSSK-derived key
- `sunxi_aes_algorithm_with_hardware` — General hardware AES algorithm wrapper

### Keybox System
- `sunxi_keybox` — Allwinner key storage container supporting:
  - `widevine` (Google Widevine DRM keys)
  - `hdcpkey` (HDCP encryption keys)
  - `verify-boot` (verified boot keys)
  - Associated certificates: `ec_key`, `rsa_key`, `ec_cert1`–`ec_cert3`, `rsa_cert1`–`rsa_cert3`
- `sunxi_keybox_data_decrypt` — Decrypt stored key data
- `sunxi_hash_check` — Verify integrity of stored keys

### Other Sunxi Features
- `rotpk` — Root of Trust Public Key management
- `check_hardware_info` — Hardware validation (chip ID / revision checks)
- eFuse read access for device identification
- RPMB (Replay Protected Memory Block) key burning
- dm-crypt key generation for encrypted partitions
- `ONLY_FOR_tee_fs_ssk` — SSK-derived key for TEE filesystem encryption

---

## Security Assessment

### Malicious Code Indicators: **NONE FOUND**

The following checks were performed:

| Check | Result |
|---|---|
| Network/socket code (TCP/IP, HTTP, DNS) | **Not present** — the "socket" string is a TA database name, not network code |
| Backdoor/shell/command execution | **Not present** |
| Data exfiltration patterns | **Not present** |
| Remote access/C2 communication | **Not present** |
| Password/credential harvesting | **Not present** |
| Obfuscated/encrypted payloads | **Not present** — all code sections contain standard ARM/Thumb-2 instructions |
| Unusual system call patterns | **Not present** — only standard SMC calls for world switching |
| Hidden execution paths | **Not present** |
| Debug/test backdoors | **Not present** — test PTAs (`invoke_tests`, `interrupt_tests`) are standard OP-TEE diagnostic tools |

### Items Requiring Context (Not Malicious)

1. **Widevine/HDCP key storage**: The keybox system includes slots for Google
   Widevine DRM keys and HDCP keys. This is a **standard Allwinner BSP
   feature** — the T113 SoC includes a video pipeline and these keys are part
   of the vendor's reference design. On a DuetScreen device (3D printer
   display), these key slots are almost certainly **unused/empty** but their
   presence in the code is simply because this is the stock Allwinner OP-TEE
   build.

2. **`check_hardware_info`**: Performs chip ID/revision validation. This is
   standard hardware probing, not a lock-in or anti-tamper mechanism. It
   prints diagnostic errors (`hardware check error1/2/3`) if the hardware
   doesn't match expected parameters.

3. **`oem_secure` eFuse area**: Standard Allwinner eFuse region for OEM-specific
   data. Not indicative of tracking or surveillance.

4. **Build from "dirty" git tree**: The commit hash `56aef7bb2-dirty` indicates
   the OP-TEE source had uncommitted changes when built. This is common in
   vendor BSP builds and not inherently suspicious.

5. **Old build (July 2021) and old compiler (GCC 5.3)**: The binary is built 
   with a 2016-era compiler and the OP-TEE version (3.7) dates to ~2019. This
   means it likely does **not** include security patches released after those
   dates, which is a potential risk but not an indicator of malice.

---

## Summary

**`optee.bin` is a standard, unmodified Allwinner T113 OP-TEE 3.7 binary from
the vendor BSP.** It provides the ARM TrustZone Secure World OS to handle:

- Secure boot chain verification
- Hardware-backed key storage and cryptographic operations
- Trusted Application execution environment
- Secure storage with integrity protection

**There is no evidence of malicious code, backdoors, data exfiltration, network
access, or any behavior beyond standard OP-TEE secure world operations.** The
Widevine/HDCP references are standard, unused key storage slots inherited from
the Allwinner T113 reference BSP. The binary is byte-identical to the generic
Allwinner reference copy in the same repository.

The main concern is that this is a **prebuilt binary blob** whose source code
provenance cannot be independently verified beyond string/disassembly analysis,
and it is built from an older OP-TEE version that may lack recent security
patches.
