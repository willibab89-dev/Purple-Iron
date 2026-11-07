#!/usr/bin/env python3
"""Package verified Red/Blue BPS patches, never complete ROMs."""
import argparse
import hashlib
from pathlib import Path
import subprocess
import tempfile

ORIGINAL_SHA1 = {
    "pokered": "ea9bcae617fdf159b045185467ae58b2e4a48b9a",
    "pokeblue": "d7037c83e1ae5b39bde3c30787637ba1d4c48ce2",
}


def package(originals, targets, output, flips):
    # Validate both sources before creating any output.
    for name, expected in ORIGINAL_SHA1.items():
        source = (originals / (name + ".gbc")).read_bytes()
        if hashlib.sha1(source).hexdigest() != expected:
            raise ValueError(f"{name}: original ROM SHA-1 mismatch")
        if not (targets / (name + ".gbc")).is_file():
            raise ValueError(f"{name}: target ROM missing")
    output.mkdir(parents=True, exist_ok=True)
    checksums = []
    with tempfile.TemporaryDirectory() as tmp:
        for name in ORIGINAL_SHA1:
            source = originals / (name + ".gbc")
            target = targets / (name + ".gbc")
            patch = output / (name + "-custom-fronts.bps")
            subprocess.run([flips, "--create", "--bps", str(source), str(target), str(patch)], check=True)
            restored = Path(tmp) / (name + ".gbc")
            subprocess.run([flips, "--apply", str(patch), str(source), str(restored)], check=True)
            if restored.read_bytes() != target.read_bytes():
                raise ValueError(f"{name}: patch round-trip mismatch")
            for label, path in (("original", source), ("patched", target), ("patch", patch)):
                data = path.read_bytes()
                checksums.append(f"{name} {label}\nSHA-1: {hashlib.sha1(data).hexdigest()}\nSHA-256: {hashlib.sha256(data).hexdigest()}\n")
            print(f"{name}: patch application matches target byte for byte")
    (output / "CHECKSUMS.txt").write_text("\n".join(checksums), encoding="utf-8")
    guide = Path(__file__).resolve().parents[1] / "docs" / "WINDOWS-PATCHING.md"
    (output / "WINDOWS-PATCHING.md").write_bytes(guide.read_bytes())
    unique_guide = guide.with_name("UNIQUE-SPECIES.md")
    if unique_guide.is_file():
        (output / unique_guide.name).write_bytes(unique_guide.read_bytes())
    for name in ("MOVE-PATCH-1.md", "MOVE-PATCH-2.md", "MOVE-PATCH-2-PLAN.md", "MOVE-PATCH-3.md", "MOVE-PATCH-4.md", "MOVE-PATCH-5.md", "MOVE-PATCH-6.md", "MOVE-PATCH-7.md", "MOVE-PATCH-8.md", "TM-DISTRIBUTION.md", "NEW-TMS.md", "BACKSPRITES-AND-NEW-SPECIES.md", "SEVEN-MORE-SPECIES.md", "TYPE-CHANGES.md", "SPECIES-TUNING-1.md", "STARTER-REDESIGNS.md", "EARLY-BUGS-AND-BIRDS.md", "RATTATA-FEAROW-RAICHU.md", "SANDSHREW-AND-NIDOS.md", "CLEFAIRY-AND-VULPIX.md", "PUFF-BATS-AND-FLOWERS.md", "PARAS-VENONAT-DIGLETT.md", "MEOWTH-PSYDUCK-MANKEY.md", "GROWLITHE-POLIWAG-ABRA.md", "MACHOP-BELLSPROUT-TENTACOOL.md", "GOLEM-RAPIDASH-SLOWBRO.md", "MAGNETS-DODRIO-DEWGONG.md", "MUK-CLOYSTER-GENGAR.md", "HYPNO-KINGLER-ELECTRODE.md", "EXEGGUTOR-MAROWAK-HITMONS.md", "LICKITUNG-WEEZING-RHYDON.md", "CHANSEY-TANGELA-KANGASKHAN-SEADRA.md", "SEAKING-STARMIE-MR-MIME.md", "SCYTHER-JYNX-ELECTABUZZ-MAGMAR.md", "PINSIR-TAUROS-GYARADOS.md", "LAPRAS-DITTO-EEVEE-FAMILY.md", "PORYGON-OMASTAR-KABUTOPS.md", "AERODACTYL-SNORLAX-LEGENDARY-BIRDS.md", "DRAGONS-MEWTWO-MEW.md", "TOXAPEX-MILTANK-SABLEYE.md", "CLAYDOL-DITTWO-TYRANITAR.md", "FIRST-UNIQUE-VARIANTS.md", "HAPPY-DITTO-AND-FIGHTERS.md", "KOGA-ERIKA-ROCK-KAKUNA.md", "FINAL-MOVE-DISTRIBUTION-REVIEW.md"):
        patch_guide = guide.with_name(name)
        if patch_guide.is_file():
            (output / patch_guide.name).write_bytes(patch_guide.read_bytes())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--originals", type=Path, required=True)
    parser.add_argument("--targets", type=Path, default=Path.cwd())
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--flips", default="flips")
    args = parser.parse_args()
    package(args.originals.resolve(), args.targets.resolve(), args.output.resolve(), args.flips)
