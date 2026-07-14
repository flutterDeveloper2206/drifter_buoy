# Drifter Buoy — Project Changes Document

| Field | Detail |
|-------|--------|
| **Project** | Drifter Buoy Mobile App |
| **Module** | General User (Setup, Self-Test / Debug, Export, Profile) |
| **Branch** | `kishan_dev` |
| **Report period** | 24 June 2026 – 11 July 2026 |
| **Document date** | 11 July 2026 |
| **Prepared by** | Development Team |

---

## 1. Status summary

| Phase | Status | Notes |
|-------|--------|-------|
| Development | **Complete** | All discussed features implemented |
| QA / on-device testing | **Complete** | Tested with paired buoy over Bluetooth |
| Release readiness | **Ready** | Available for staging / production deployment |

**Going forward:** This phase is formally closed. Any **new change requests, enhancements, or defect fixes** raised after this date will be treated as **separate scope** and will be:

- Logged and estimated individually  
- Executed only after your approval  
- **Billed on an hourly basis**  
- Supported with **hourly status updates** until each item is completed and signed off  

Please confirm if you require a **staging/production build** or **app store release notes**, and we will prepare them accordingly.

---

## 2. Executive summary

Over the last two weeks, development focused on four areas:

1. **Bluetooth integration** — Real device scanning, connection, and GATT-based ASCII command transport.
2. **Self-Test / Debug module** — Full parameterized dialog system aligned with the BLE command catalog (`?xx` opcodes).
3. **Export & profile** — Lat/long search, UI polish, and PDF alignment.
4. **Buoy setup & trajectory** — Setup flow refinements and map/trajectory improvements.

The Self-Test module is the largest delivery: ~2,300 net new/changed lines across bloc, page, event, and state files, covering dozens of catalog commands with GET/SET dialogs, prefetch from device, parsed response summaries, and small-screen UX fixes.

---

## 3. Committed changes (Git: 24 Jun – 29 Jun 2026)

### 3.1 Export & profile

| Change | Description |
|--------|-------------|
| SearchByLatLon API | Integrated latitude/longitude search for export workflows |
| Export UI | Improved notices and user messaging |
| Report type handling | Report type resets when the date range changes |
| Profile page | Layout and content updates |
| PDF export | Column alignment fixes |
| App version | Version number displayed on profile page |

### 3.2 General User experience

| Change | Description |
|--------|-------------|
| Buoy setup | Refinements to pairing and setup detail flow |
| Trajectory view | Map and trajectory presentation improvements |
| Self-Test Debug (initial) | Debugging tools and error visualization enhancements |
| Branch integration | Merged `keval_dev` into `kishan_dev` |

---

## 4. Current branch — detailed delivery

### 4.1 Bluetooth infrastructure

| Item | Implementation |
|------|----------------|
| Package | `flutter_blue_plus` for scan, connect, disconnect |
| Permissions | Android / iOS BLE permissions configured |
| GATT discovery | Nordic UART UUIDs tried first; fallback scans all services for write + notify characteristics |
| Command send | ASCII commands written in 20-byte chunks to TX characteristic |
| Response receive | Notify/indicate stream assembled until line terminator `#` |
| Timeouts | Per-command `responseWaitTimeout` from catalog |
| Logging | `[DrifterBLE][SEND]` and `[DrifterBLE][RESPONSE]` in debug output |
| User feedback | Connect / disconnect Flushbar messages |
| Setup sheet | Real scan results; connect-on-tap; success state before dismiss |
| Utilities | `drifter_ble_line_utils.dart` for line parsing helpers |

**Key files**

- `lib/core/bluetooth/ble_connection_service.dart`
- `lib/core/bluetooth/flutter_blue_plus_ble_connection_service.dart`
- `lib/core/bluetooth/drifter_ble_line_utils.dart`
- `lib/core/constants/ble_gatt_constants.dart`

---

### 4.2 Self-Test command catalog & storage

| Item | Implementation |
|------|----------------|
| Command source | Static embedded catalog matching API / BLE specification |
| SQLite cache | Commands persisted locally via `AppDatabase.saveCommands()` |
| Deduplication | `DrifterBuoyCommandModel.dedupeByIdForStorage()` — primary key = Mongo `_id` |
| Load strategy | Show cached commands immediately; refresh from API in background |
| Refresh event | `ApplyRefreshedSelfTestCommands` avoids bloc emit-after-complete errors |
| Remote data source | API parse uses deduped raw list before storage |

**Key files**

- `lib/core/storage/app_database.dart`
- `lib/features/general_user/data/models/drifter_buoy_command_model.dart`
- `lib/features/general_user/data/datasources/general_user_self_test_remote_data_source.dart`

---

### 4.3 Self-Test — command implementations

Each row lists the catalog feature, Mongo ID (where applicable), BLE opcode, and what was built.

| Feature | Command ID | BLE | Implementation summary |
|---------|------------|-----|------------------------|
| Set/Get Transmitter Frequency | `6a04547227be228113206989` | `?65` | GET/SET dialog (no auto GET on tap). Frequency format `000.000000` (10 chars). Valid range **400.000000–406.000000 MHz**. Sends 9 digits without decimal to device. **Frequency Set Failure** label when response is `FFFFFFFFF`. |
| Set Attenuation | `6a04547227be22811320698a` | `?66` | GET/SET dialog (no prefetch GET). Commands: `?66,N,0,#` (GET) and `?66,N,1,xx,#` (SET). **Set Failure** label when attenuation is `FF`. |
| Transmitter Test | `6a04547227be228113206988` | `?64` | In-dialog 30-second countdown. Radio locked during active test. Manual/auto OFF. Cancel blocked while ON. Bloc re-provided in dialog route. |
| Set APN | `6a04547227be228113206953` | `?11` | Prefetch SIM 1 & SIM 2 APN from `?04` on open. Fixed SIM 1 APN not prefilling when dialog opens on default slot. |
| Set Buoy Offset | `6a4f614acff2cb88f40a9455` | `?75` | Dialog: `+`/`-` prefix + 4-digit offset. Response dialog shows Response Code, Buoy Id, Offset. |
| RTC HTTP Address | `6a04547227be228113206954` | `?12` | Parsed response: Response Code, Buoy Id, Address. |
| RTC HTTP Key | `6a04547227be228113206955` | `?13` | Parsed response: Response Code, Buoy Id, Key. |
| UHF / Sonde Tx In Time | — | `?63` | Field selector dropdown; long labels wrap to 2 lines on narrow screens via `selectedItemBuilder`. |
| Set All General Parameters | `6a04547227be22811320694d` | `?05` | Multi-field form; prefetch current values via `?04`. |
| Server FTP/HTTP (Primary–Factory) | Multiple IDs | `?46–?49`, `?56–?59` | Set / Get / Restore all server parameter dialogs per server tier. |
| Individual server settings | Multiple IDs | Various | Parameterized single-field dialogs (FTP address, port, path, username, password, SMS cell, HTTP website, TX redundancy). |
| Fast SMS Check | `6a04547227be228113206982` | `?58` | Enable/disable toggle; prefetched from `?04` field index 6. |
| Sensor parameters | Multiple IDs | `?82`, `?83` | Set all sensors, set individual sensor, get sensor parameter forms. |
| Station ID / Name / Intervals | Various | `?06`, `?07`, etc. | Individual SET dialogs with validation and BLE submit. |
| Check Status, Test Mode, Power Switching, Sim Card Test, etc. | Various | Various | Catalog-driven run or parameterized flows with response snapshots. |

---

### 4.4 Self-Test — UI and validation UX

| Item | Description |
|------|-------------|
| Validation error lines | All form fields use `errorMaxLines: 2` (`_kSelfTestFormErrorMaxLines`) — 58 `InputDecoration` sites updated |
| Dropdown labels | Long selected values use `maxLines: 2`, `softWrap: true`, `TextOverflow.ellipsis` |
| Response dialogs | Parsed summaries with labeled key/value lines; raw BLE line hidden when formatted summary exists |
| Catalog notes | Command `note` and `requestCommandDescription` shown in dialogs where applicable |
| Prefetch warnings | Non-blocking warning when `?04` or other prefetch fails |
| Bloc in dialogs | `.cursor/rules/flutter-bloc-dialogs.mdc` — `BlocProvider.value` required for dialog routes using bloc |
| Animated list | Staggered entrance animation for Self-Test command list rows |

---

### 4.5 Other updates

| Area | Change |
|------|--------|
| `buoy_setup_validation.dart` | Setup validation rule updates |
| `general_user_buoy_setup_page.dart` | Minor setup page adjustments |
| `general_user_setup_detail_page.dart` | Setup detail integration with BLE |
| `general_user_dashboard_bloc.dart` | Minor dashboard update |
| `app_flushbar.dart` | Small feedback adjustment |
| `tool/drifter_commands_input.json` | Catalog spec sync |
| `Command reposne BLE.xlsx - Sheet1-2.csv` | BLE specification sheet updates |

---

## 5. Files changed (current branch delta)

```
Command reposne BLE.xlsx - Sheet1-2.csv
lib/core/bluetooth/flutter_blue_plus_ble_connection_service.dart
lib/core/storage/app_database.dart
lib/core/utils/buoy_setup_validation.dart
lib/core/utils/widgets/app_flushbar.dart
lib/features/general_user/data/datasources/general_user_self_test_remote_data_source.dart
lib/features/general_user/data/models/drifter_buoy_command_model.dart
lib/features/general_user/presentation/bloc/dashboard/general_user_dashboard_bloc.dart
lib/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_bloc.dart
lib/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_event.dart
lib/features/general_user/presentation/bloc/self_test_debug/general_user_self_test_debug_state.dart
lib/features/general_user/presentation/pages/general_user_buoy_setup_page.dart
lib/features/general_user/presentation/pages/general_user_profile_page.dart
lib/features/general_user/presentation/pages/general_user_self_test_debug_page.dart
lib/features/general_user/presentation/pages/general_user_setup_detail_page.dart
tool/drifter_commands_input.json
```

**Approximate diff:** 16 files | +2,295 / −1,536 lines

---

## 6. Architecture overview (Self-Test flow)

```
User taps command row
        │
        ▼
GeneralUserSelfTestDebugBloc
  ├── Open prompt (optional ?04 prefetch)
  ├── Emit prompt state → Page shows dialog
  └── User taps Send
        │
        ▼
Submit event → Bloc builds ?xx BLE line
        │
        ▼
BleConnectionService.sendDrifterAsciiCommand()
  ├── Chunked write to GATT TX
  └── Assemble notify response until #
        │
        ▼
Bloc parses response → lastSnapshot
        │
        ▼
Page shows response dialog with formatted summary
```

---

## 7. Sign-off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Development | | 11 Jul 2026 | Complete |
| QA | | 11 Jul 2026 | Complete |
| Client / PM | | | |

---

## 8. Revision history

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 11 Jul 2026 | Development Team | Initial release — dev & QA complete |

---

*End of document*
