#!/usr/bin/env python

import json
import os
import logging
from typing import Optional


def get_cached_data() -> dict:
    td_tmp = os.environ.get("TD_TMP")
    f = open(f"{td_tmp}/tdh_profile.json", "r")
    return json.load(f)


def get_ship_table() -> dict:
    td_data = os.environ.get("TD_DATA")
    f = open(f"{td_data}/eddb/index.json")
    return json.load(f)["Ships"]


def get_module_table_by_id() -> dict:
    td_data = os.environ.get("TD_DATA")
    f = open(f"{td_data}/eddb/modules.json")
    module_list = json.load(f)

    table = {}
    for module in module_list:
        table[module["ed_id"]] = module

    return table


def get_ship_modules() -> dict:
    data = get_cached_data()
    return data["profile"]["ship"]["modules"]


def get_ship_stats():
    ships = get_ship_table()
    module_table = get_module_table_by_id()
    data = get_cached_data()

    ship_name: str = data["profile"]["ship"]["name"]
    lower_name = ship_name.lower()
    if lower_name == "krait_light":
        lower_name = "krait_phantom"
    hull_mass = ships[lower_name]["properties"]["hullMass"]

    reservoir_size = reservoir_table.get(ship_name, 0)
    if reservoir_size == 0:
        logging.warning(f"Unknown reservoir size for {ship_name}, defaulting to 1t")

    base_mass = hull_mass + reservoir_size

    logging.debug(f"{hull_mass} + {reservoir_size} ({ship_name}) = {base_mass}")

    fsd_stats = {}
    gfsdb_bonus = 0
    fuel_cap = 0
    cargo_cap = 0

    modules = get_ship_modules()
    for mount, data in modules.items():
        module = data["module"]
        mods = data.get("WorkInProgress_modifications", None)
        exp_mod: Optional[str] = data.get("specialModifications", None)
        mass_mod = mods.get("OutfittingFieldType_Mass", None) if mods else None

        if exp_mod != None and isinstance(exp_mod, dict):
            # they're just a single-item dictionary with key=value (???)
            exp_mod = exp_mod.popitem()[0]
        else:
            # they're an array when empty; I guess fdev uses php
            exp_mod = None

        # sometimes "non-modules" have IDs matching modules in the database (e.g. PaintJob_Krait_Light_Salvage_03)
        if (
            mount.endswith("Colour")
            or mount == "VesselVoice"
            or mount.startswith("PaintJob")
            or mount.startswith("Decal")
            or mount.startswith("ShipName")
            or mount.startswith("ShipKit")
        ):
            continue

        try:
            module_data = module_table[module["id"]]
        except:
            # unknown module
            continue

        module_mass = module_data.get("mass", 0)
        if module_mass > 0 and mass_mod is not None:
            mod_value: float = mass_mod["value"]
            module_mass = module_mass * mod_value

        if exp_mod != None and exp_mod.endswith("_lightweight"):
            module_mass = module_mass * 0.9

        if module_mass == 0:
            # AFMU, cargo rack, fuel tank, scoop, planetary suite
            if (
                module_data["group_id"] == 93
                or module_data["group_id"] == 80
                or module_data["group_id"] == 81
                or module_data["group_id"] == 90
                or module_data["group_id"] == 142
            ):
                pass
            elif module_data["group_id"] == 50:
                if module_data["group"]["name"] == "Lightweight Alloy":
                    pass
                else:
                    logging.warning(
                        f'Missing module mass for Bulkhead {module["name"]} {module_data}'
                    )
            else:
                module_mass = mass_table.get(module["name"], 0)
                if module_mass == 0:
                    logging.warning(
                        f'Missing module mass for {module["name"]} {module_data}'
                    )

        if module["name"] == "Int_DetailedSurfaceScanner_Tiny":
            # DSS mass is ignored since one of the Beyond updates
            module_mass = 0
        logging.debug(
            f'{round(base_mass,2)} + {round(module_mass,2)} ({module["name"]}) = {round(base_mass + module_mass,2)}'
        )
        base_mass = base_mass + module_mass

        if mount == "FrameShiftDrive":
            fsd_stats = fsd_stat_table[module["id"]].copy()

            if mods:
                optimal_mod = mods.get("OutfittingFieldType_FSDOptimalMass", None)
                optmass_mult = optimal_mod["value"] if optimal_mod else 1
                if exp_mod == "special_fsd_heavy":
                    optmass_mult = optmass_mult * 1.04

                fsd_stats["optmass"] = fsd_stats["optmass"] * optmass_mult

        # fuel tank
        if module_data["group_id"] == 81:
            fuel_cap = fuel_cap + module_data["capacity"]

        # cargo rack or corrosion resistant cargo rack
        if module_data["group_id"] == 80 or module_data["group_id"] == 104:
            cargo_cap = cargo_cap + module_data["capacity"]

        # guardian FSD boost
        if module_data["group_id"] == 124:
            gfsdb_bonus = gfsdb_bonus_table[module_data["class"]]

    result = {
        "cargo_cap": cargo_cap,
        "laden_ly": round(
            jump_equation(
                base_mass + fuel_cap + cargo_cap,
                min(fuel_cap, fsd_stats["maxfuel"]),
                fsd_stats["optmass"],
                fsd_stats["fuelmul"],
                fsd_stats["fuelpower"],
                gfsdb_bonus,
            ),
            2,
        ),
        "unladen_ly": round(
            jump_equation(
                base_mass + fuel_cap,
                min(fuel_cap, fsd_stats["maxfuel"]),
                fsd_stats["optmass"],
                fsd_stats["fuelmul"],
                fsd_stats["fuelpower"],
                gfsdb_bonus,
            ),
            2,
        ),
    }

    logging.debug(f"Hull total: {round(base_mass, 2)}")
    logging.debug(
        f'Unladen total: {round(base_mass + fuel_cap, 2)} ({result["unladen_ly"]}ly)'
    )
    logging.debug(
        f'Laden total: {round(base_mass + fuel_cap + cargo_cap, 2)} ({result["laden_ly"]}ly)'
    )

    return result


def jump_equation(
    mass: float, fuel: float, fsdOpt: float, fsdMul: float, fsdExp: float, jmpBst: float
):
    return pow(fuel / fsdMul, 1 / fsdExp) * fsdOpt / mass + jmpBst


# stripped and modified from coriolis-data to have only the missing data
# https://github.com/cmmcleod/coriolis-data/blob/master/dist/index.json
fsd_stat_table = {
    128064128: {"optmass": 1440, "maxfuel": 8.5, "fuelmul": 0.011, "fuelpower": 2.75},
    128064129: {"optmass": 1620, "maxfuel": 8.5, "fuelmul": 0.01, "fuelpower": 2.75},
    128064130: {"optmass": 1800, "maxfuel": 8.5, "fuelmul": 0.008, "fuelpower": 2.75},
    128064131: {"optmass": 2250, "maxfuel": 10.6, "fuelmul": 0.01, "fuelpower": 2.75},
    128064132: {"optmass": 2700, "maxfuel": 12.8, "fuelmul": 0.012, "fuelpower": 2.75},
    128064123: {"optmass": 960, "maxfuel": 5.3, "fuelmul": 0.011, "fuelpower": 2.6},
    128064124: {"optmass": 1080, "maxfuel": 5.3, "fuelmul": 0.01, "fuelpower": 2.6},
    128064125: {"optmass": 1200, "maxfuel": 5.3, "fuelmul": 0.008, "fuelpower": 2.6},
    128064126: {"optmass": 1500, "maxfuel": 6.6, "fuelmul": 0.01, "fuelpower": 2.6},
    128064127: {"optmass": 1800, "maxfuel": 8, "fuelmul": 0.012, "fuelpower": 2.6},
    128064118: {"optmass": 560, "maxfuel": 3.3, "fuelmul": 0.011, "fuelpower": 2.45},
    128064119: {"optmass": 630, "maxfuel": 3.3, "fuelmul": 0.01, "fuelpower": 2.45},
    128064120: {"optmass": 700, "maxfuel": 3.3, "fuelmul": 0.008, "fuelpower": 2.45},
    128064121: {"optmass": 875, "maxfuel": 4.1, "fuelmul": 0.01, "fuelpower": 2.45},
    128064122: {"optmass": 1050, "maxfuel": 5, "fuelmul": 0.012, "fuelpower": 2.45},
    128064113: {"optmass": 280, "maxfuel": 2, "fuelmul": 0.011, "fuelpower": 2.3},
    128064114: {"optmass": 315, "maxfuel": 2, "fuelmul": 0.01, "fuelpower": 2.3},
    128064115: {"optmass": 350, "maxfuel": 2, "fuelmul": 0.008, "fuelpower": 2.3},
    128064116: {"optmass": 438, "maxfuel": 2.5, "fuelmul": 0.01, "fuelpower": 2.3},
    128064117: {"optmass": 525, "maxfuel": 3, "fuelmul": 0.012, "fuelpower": 2.3},
    128064108: {"optmass": 80, "maxfuel": 1.2, "fuelmul": 0.011, "fuelpower": 2.15},
    128064109: {"optmass": 90, "maxfuel": 1.2, "fuelmul": 0.01, "fuelpower": 2.15},
    128064110: {"optmass": 100, "maxfuel": 1.2, "fuelmul": 0.008, "fuelpower": 2.15},
    128064111: {"optmass": 125, "maxfuel": 1.5, "fuelmul": 0.01, "fuelpower": 2.15},
    128064112: {"optmass": 150, "maxfuel": 1.8, "fuelmul": 0.012, "fuelpower": 2.15},
    128064103: {"optmass": 48, "maxfuel": 0.6, "fuelmul": 0.011, "fuelpower": 2},
    128064104: {"optmass": 54, "maxfuel": 0.6, "fuelmul": 0.01, "fuelpower": 2},
    128064105: {"optmass": 60, "maxfuel": 0.6, "fuelmul": 0.008, "fuelpower": 2},
    128064106: {"optmass": 75, "maxfuel": 0.8, "fuelmul": 0.01, "fuelpower": 2},
    128064107: {"optmass": 90, "maxfuel": 0.9, "fuelmul": 0.012, "fuelpower": 2},
}

gfsdb_bonus_table = {5: 10.5, 4: 9.25, 3: 7.75, 2: 6, 1: 4}

mass_table = {
    "Int_DroneControl_Repair_Size3_Class2": 2,
    "Int_GuardianFSDBooster_Size1": 1.3,
    "Int_GuardianFSDBooster_Size2": 1.3,
    "Int_GuardianFSDBooster_Size3": 1.3,
    "Int_GuardianFSDBooster_Size4": 1.3,
    "Int_GuardianFSDBooster_Size5": 1.3,
}

reservoir_table = {
    "Krait_Light": 0.63,
    "Type9": 0.77,
    "Cutter": 1.16,
    "Anaconda": 1.07,
    "Federation_Corvette": 1.13,
}

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Calculates ship data from trade-dangerous cache"
    )
    parser.add_argument("-v", "--verbose", action="store_true")
    parser.add_argument("--stat", choices=["cargo_cap", "laden_ly", "unladen_ly"])
    args = parser.parse_args()
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    stats = get_ship_stats()
    if args.stat:
        print(stats[args.stat])
    else:
        for key, value in stats.items():
            print(f"{key}: {value}")
