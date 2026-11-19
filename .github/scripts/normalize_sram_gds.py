#!/usr/bin/env python3
"""Normalize the official GF180 SRAM GDS for Magic and Tiny Tapeout.

The macro's top-cell name and all hierarchy geometry on supported GF180 layers
are preserved. Internal cell identifiers are replaced with unique, short names
to avoid Magic's duplicate-cell import behavior. Layer 58/0 is removed because
it is not defined in the GF180MCU layer specification.
"""

from __future__ import annotations

import struct
from collections import defaultdict
from pathlib import Path

import gdstk


GDS_PATH = Path(
    "src/gf180mcu_fd_ip_sram/cells/"
    "gf180mcu_fd_ip_sram__sram512x8m8wm1/"
    "gf180mcu_fd_ip_sram__sram512x8m8wm1.gds"
)
ROOT_CELL = "gf180mcu_fd_ip_sram__sram512x8m8wm1"
UNSUPPORTED_LAYER = 58
CELL_PREFIX = "GF180S_"


def inspect_gds(path: Path) -> tuple[list[str], dict[str, set[str]], int]:
    """Read cell names, SREF/AREF targets, and occurrences of layer 58."""
    data = path.read_bytes()
    cells: list[str] = []
    references: dict[str, set[str]] = defaultdict(set)
    current_cell: str | None = None
    pending_reference = False
    current_layer: int | None = None
    layer_58_records = 0

    offset = 0
    while offset < len(data):
        if offset + 4 > len(data):
            raise SystemExit(f"{path}: truncated GDS record header at {offset}")
        length, record_type, _data_type = struct.unpack_from(">HBB", data, offset)
        if length < 4 or offset + length > len(data):
            raise SystemExit(f"{path}: invalid GDS record length at {offset}")
        payload = data[offset + 4 : offset + length]
        offset += length

        if record_type == 0x06:  # STRNAME
            current_cell = payload.rstrip(b"\0").decode("ascii")
            cells.append(current_cell)
        elif record_type in (0x0A, 0x0B):  # SREF / AREF
            pending_reference = True
        elif record_type == 0x12 and pending_reference:  # SNAME
            target = payload.rstrip(b"\0").decode("ascii")
            if current_cell is None:
                raise SystemExit(f"{path}: reference outside a structure")
            references[current_cell].add(target)
            pending_reference = False
        elif record_type == 0x0D and len(payload) >= 2:  # LAYER
            current_layer = struct.unpack(">h", payload[:2])[0]
            if current_layer == UNSUPPORTED_LAYER:
                layer_58_records += 1

    if len(cells) != len(set(cells)):
        raise SystemExit(f"{path}: duplicate structure names in source GDS")
    return cells, references, layer_58_records


def validate_gds(path: Path) -> None:
    cells, references, layer_58_records = inspect_gds(path)
    known = set(cells)
    missing = sorted(
        (parent, child)
        for parent, children in references.items()
        for child in children
        if child not in known
    )
    referenced = {child for children in references.values() for child in children}
    top_cells = [cell for cell in cells if cell not in referenced]

    if missing:
        raise SystemExit(f"{path}: missing hierarchy cells: {missing[:10]}")
    if top_cells != [ROOT_CELL]:
        raise SystemExit(
            f"{path}: expected only top cell {ROOT_CELL!r}; found {top_cells}"
        )
    if layer_58_records:
        raise SystemExit(
            f"{path}: still contains {layer_58_records} GDS layer-58 records"
        )


def main() -> None:
    if not GDS_PATH.is_file():
        raise SystemExit(f"Official SRAM GDS not found: {GDS_PATH}")

    original_cells, original_refs, original_layer_58 = inspect_gds(GDS_PATH)
    if ROOT_CELL not in original_cells:
        raise SystemExit(f"{GDS_PATH}: missing expected root cell {ROOT_CELL!r}")

    library = gdstk.read_gds(str(GDS_PATH))
    roots = [cell for cell in library.cells if cell.name == ROOT_CELL]
    if len(roots) != 1:
        raise SystemExit(
            f"{GDS_PATH}: expected one root cell {ROOT_CELL!r}; found {len(roots)}"
        )

    root = roots[0]
    internal_cells = sorted(
        (cell for cell in library.cells if cell is not root),
        key=lambda cell: cell.name,
    )

    # Use compact, unique internal names, preserving the externally referenced
    # macro master name. gdstk updates SREF/AREF targets through cell references.
    for index, cell in enumerate(internal_cells):
        cell.name = f"{CELL_PREFIX}{index:04d}"

    removed = {"polygons": 0, "paths": 0, "labels": 0}
    for cell in library.cells:
        to_remove = []

        for polygon in cell.polygons:
            if polygon.layer == UNSUPPORTED_LAYER:
                to_remove.append(polygon)
                removed["polygons"] += 1

        for path in cell.paths:
            if UNSUPPORTED_LAYER in set(path.layers):
                to_remove.append(path)
                removed["paths"] += 1

        for label in cell.labels:
            if label.layer == UNSUPPORTED_LAYER:
                to_remove.append(label)
                removed["labels"] += 1

        if to_remove:
            cell.remove(*to_remove)

    temporary = GDS_PATH.with_suffix(".normalized.gds")
    library.write_gds(str(temporary))

    # Validate the actual serialized output, not just the in-memory library.
    validate_gds(temporary)
    output_cells, output_refs, output_layer_58 = inspect_gds(temporary)
    if len(output_cells) != len(original_cells):
        temporary.unlink(missing_ok=True)
        raise SystemExit(
            f"{GDS_PATH}: cell count changed from {len(original_cells)} "
            f"to {len(output_cells)}"
        )
    if sum(map(len, output_refs.values())) != sum(map(len, original_refs.values())):
        temporary.unlink(missing_ok=True)
        raise SystemExit(f"{GDS_PATH}: hierarchy reference count changed")
    temporary.replace(GDS_PATH)

    print(f"Normalized official SRAM GDS: {GDS_PATH}")
    print(f"  Root cell preserved: {ROOT_CELL}")
    print(f"  Internal cells renamed: {len(internal_cells)}")
    print(f"  Layer 58 records removed from source: {original_layer_58}")
    print(f"  Gdstk elements removed: {removed}")
    print(f"  Serialized layer 58 records remaining: {output_layer_58}")
    print(f"  Unique top cell verified: {ROOT_CELL}")


if __name__ == "__main__":
    main()
