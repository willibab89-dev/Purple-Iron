# Download and play on Windows

1. Sign in to GitHub and open this repository's **Actions** tab.
2. Open the successful run for the desired commit on branch **unique-species**. Under **Artifacts**, click **pokemon-move-patch-5-bps** to download the ZIP, then extract it.
3. Obtain Floating IPS (Flips) from its official project: https://github.com/Alcaro/Flips/releases
4. Open Flips and select **Apply Patch**. Choose `pokered-custom-fronts.bps` or `pokeblue-custom-fronts.bps`, then select your matching original ROM. Save the result under a new filename.
5. Open the patched ROM in your Game Boy emulator.

**Upgrading from the original 151-species version requires a new save.** Saves from previous 172-species builds retain their layout; heal at a Pokémon Center after updating to refresh PP. See `UNIQUE-SPECIES.md` for trainer assignments, wild locations and evolution behavior.

Use the unmodified English USA/Europe Red or Blue release. Japanese, translated, already patched and other modified ROMs are incompatible. Keep your original ROM and save file backed up.

| Original | Required SHA-1 |
| --- | --- |
| Pokémon Red | `ea9bcae617fdf159b045185467ae58b2e4a48b9a` |
| Pokémon Blue | `d7037c83e1ae5b39bde3c30787637ba1d4c48ce2` |

In Windows PowerShell, check your file with:

```powershell
Get-FileHash -Algorithm SHA1 "C:\Games\Pokemon Red.gb"
```

The package's `CHECKSUMS.txt` includes the SHA-1 and SHA-256 of both required originals, both patched outputs and the patches. Flips also checks that the selected original matches. Do not bypass checksum failures.

The download contains patches and documentation only. Each patch is tested by applying it to its verified original and comparing the result byte for byte with the custom build. Back sprites are unchanged. Emulator gameplay is a separate check.

Artifacts expire after 30 days. Rerun the workflow to generate another download. For a manual run, choose this workflow in Actions, select **Run workflow**, and choose the branch containing your sprite changes.
