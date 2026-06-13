#!/usr/bin/env python3
"""Build Dart snippets + optional JSON from `Command reposne BLE.xlsx - Sheet1-2.csv`.

Example:
    python3 tool/generate_self_test_catalog.py --write-json
    python3 tool/generate_self_test_catalog.py --section ids
    python3 tool/generate_self_test_catalog.py --section models
"""
from __future__ import annotations

import argparse
import csv
import json
import re
from collections import defaultdict
from pathlib import Path

# Stable bloc identifiers (handlers + parameterized FTP/SMS). Mongo `_id` → Dart name.
_VAR_OVERRIDES_BY_MONGO_ID: dict[str, str] = {
    "6a04547227be22811320694a": "_checkStatusCommandId",
    "6a04547227be22811320694e": "_setStationIdCommandId",
    "6a04547227be228113206985": "_measurementStartTimeCommandId",
    "6a04547227be228113206988": "_transmitterTestCommandId",
    "6a04547227be228113206989": "_transmitterFrequencyCommandId",
    "6a04547227be22811320698a": "_setAttenuationCommandId",
    "6a04547227be22811320698b": "_radioSondeTransmitterIdCommandId",
    "6a2d222437aa7731734f8d9f": "_uhfSondeTxInTimeCommandId",
    "6a04547227be228113206957": "_primaryServerFtpAddressCommandId",
    "6a04547227be228113206958": "_primaryServerFtpPortCommandId",
    "6a04547227be228113206959": "_primaryServerFtpPathCommandId",
    "6a04547227be22811320695a": "_primaryServerFtpUsernameCommandId",
    "6a04547227be22811320695b": "_primaryServerFtpPasswordCommandId",
    "6a04547227be22811320695c": "_primaryServerSmsCellNoCommandId",
    "6a04547227be22811320695d": "_primaryServerTxMediaRedundancyCommandId",
    "6a04547227be22811320695f": "_secondaryServerFtpAddressCommandId",
    "6a04547227be228113206960": "_secondaryServerFtpPortCommandId",
    "6a04547227be228113206961": "_secondaryServerFtpPathCommandId",
    "6a04547227be228113206962": "_secondaryServerFtpUsernameCommandId",
    "6a04547227be228113206963": "_secondaryServerFtpPasswordCommandId",
    "6a04547227be228113206964": "_secondaryServerSmsCellNoCommandId",
    "6a04547227be228113206965": "_secondaryServerTxMediaRedundancyCommandId",
    "6a04547227be228113206967": "_thirdServerFtpAddressCommandId",
    "6a04547227be228113206968": "_thirdServerFtpPortNoCommandId",
    "6a04547227be228113206969": "_thirdServerFtpPathCommandId",
    "6a04547227be22811320696a": "_thirdServerFtpUsernameCommandId",
    "6a04547227be22811320696b": "_thirdServerFtpPasswordCommandId",
    "6a04547227be22811320696c": "_setThirdServerSmsCellNoCommandId",
    "6a04547227be22811320696d": "_thirdServerTxMediaRedundancyCommandId",
    "6a04547227be22811320696f": "_factoryServerFtpAddressCommandId",
    "6a04547227be228113206970": "_factoryServerFtpPortNoCommandId",
    "6a04547227be228113206971": "_factoryServerFtpPathCommandId",
    "6a04547227be228113206972": "_factoryServerFtpUsernameCommandId",
    "6a04547227be228113206973": "_factoryServerFtpPasswordCommandId",
    "6a04547227be228113206974": "_setFactoryServerSmsCellNoCommandId",
    "6a04547227be228113206975": "_factoryServerTxMediaRedundancyCommandId",
    "6a04547227be228113206983": "_setAdmin1SmsCellNoCommandId",
    "6a04547227be228113206984": "_setAdmin2SmsCellNoCommandId",
}

_DUP_SENSOR_GET_ID = "6a04547227be228113206994"


def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def default_csv_path() -> Path:
    return repo_root() / "Command reposne BLE.xlsx - Sheet1-2.csv"


def slugify(test_name: str, index: int) -> str:
    base = re.sub(r"[^a-zA-Z0-9]+", " ", test_name).strip()
    parts = [p for p in base.split() if p]
    if not parts:
        return f"cmd{index}"
    pascal = "".join(p.capitalize() for p in parts)
    return pascal[0].lower() + pascal[1:]


def dart_triple(name: str, value: str) -> str:
    esc = (value or "").replace("\\", r"\\").replace("'''", r"'\'''\''")
    return f"      {name}: '''{esc}''',"


def emit_field(name: str, value: str) -> str:
    value = value if value is not None else ""
    if "\n" in value or "'''" in value:
        return dart_triple(name, value)
    escaped_sq = value.replace("\\", r"\\").replace("'", r"\'")
    if "$" in value and "'" not in value:
        body = value.replace("\\", r"\\")
        return f"      {name}: r'{body}',"
    return f"      {name}: '{escaped_sq}',"


def read_commands_csv(path: Path) -> list[dict]:
    rows: list[dict] = []
    with path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            oid = (row.get("id") or "").strip()
            if not oid:
                continue
            wp = (row.get("Waiting Period") or "").strip()
            unit = (row.get("Unit") or "").strip()
            wait = f"{wp} {unit}".strip()
            if not wait:
                wait = "NA"
            rows.append(
                {
                    "_id": oid,
                    "testName": (row.get("Test Name") or "").strip(),
                    "requestCommand": (row.get("Request Command") or "").strip(),
                    "waitingPeriodSecondsRaw": wait,
                    "requestCommandDescription": (
                        row.get("Request Command Description") or ""
                    ).strip(),
                    "response": (row.get("Response") or "").strip(),
                    "responseDescription": (row.get("Response Description") or "").strip(),
                    "isActive": True,
                }
            )
    return rows


def build_var_names(cmds: list[dict]) -> list[str]:
    counts: defaultdict[str, int] = defaultdict(int)
    used_vars: set[str] = set()
    id_vars: list[str] = []

    for i, c in enumerate(cmds):
        oid = c["_id"]
        req = c["requestCommand"]

        if oid == _DUP_SENSOR_GET_ID:
            var = (
                "_getSensorParameterCommandId"
                if "?81" in req
                else "_getSensorParameter83CommandId"
            )
            id_vars.append(var)
            used_vars.add(var)
            continue

        if oid in _VAR_OVERRIDES_BY_MONGO_ID:
            var = _VAR_OVERRIDES_BY_MONGO_ID[oid]
            id_vars.append(var)
            used_vars.add(var)
            continue

        slug = slugify(c["testName"], i)
        counts[slug] += 1
        n = counts[slug]
        var = f"_{slug}CommandId" if n == 1 else f"_{slug}_{n}CommandId"
        suffix = n
        while var in used_vars:
            suffix += 1
            var = f"_{slug}_{suffix}CommandId"
        used_vars.add(var)
        id_vars.append(var)

    return id_vars


def emit_ids(id_vars: list[str], cmds: list[dict]) -> None:
    print("  /// Command document ids — source: Command reposne BLE sheet CSV.")
    print("  /// Order matches [_staticCommands].")
    for var, c in zip(id_vars, cmds):
        oid = c["_id"]
        if len(var) + len(oid) > 72:
            print(f"  static const String {var} =")
            print(f"      '{oid}';")
        else:
            print(f"  static const String {var} = '{oid}';")


def emit_models(id_vars: list[str], cmds: list[dict]) -> None:
    print()
    print("  static const List<DrifterBuoyCommandModel> _staticCommands = [")
    for var, c in zip(id_vars, cmds):
        w = c["waitingPeriodSecondsRaw"]
        print("    DrifterBuoyCommandModel(")
        print(f"      id: {var},")
        print(emit_field("testName", c["testName"]))
        print(emit_field("requestCommand", c["requestCommand"]))
        w_esc = str(w).replace("\\", r"\\").replace("'", r"\'")
        print(f"      waitingPeriodSecondsRaw: '{w_esc}',")
        print(emit_field("requestCommandDescription", c["requestCommandDescription"]))
        print(emit_field("response", c["response"]))
        print(emit_field("responseDescription", c["responseDescription"]))
        print("      isActive: true,")
        print("    ),")
    print("  ];")


def write_api_json(cmds: list[dict], path: Path) -> None:
    payload = {
        "statusCode": 200,
        "message": "ok",
        "result": {"bluetoothNameLength": 0, "commands": cmds},
        "isSuccess": True,
    }
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", type=Path, default=None)
    parser.add_argument("--section", choices=("ids", "models", "all"), default="all")
    parser.add_argument(
        "--write-json",
        action="store_true",
        help="Also write tool/drifter_commands_input.json",
    )
    args = parser.parse_args()

    csv_path = args.csv or default_csv_path()
    cmds = read_commands_csv(csv_path)
    id_vars = build_var_names(cmds)

    if args.write_json:
        out_json = Path(__file__).resolve().parent / "drifter_commands_input.json"
        write_api_json(cmds, out_json)

    if args.section in ("ids", "all"):
        emit_ids(id_vars, cmds)
    if args.section in ("models", "all"):
        emit_models(id_vars, cmds)


if __name__ == "__main__":
    main()
