#!/usr/bin/env python3
"""Create STL files with single parts from drawer_organizer.scad."""
import itertools
import subprocess
import os
import json

EXECUTABLE = "openscad-nightly"
OUTPUT_TYPE = "stl" # openscad also supports "amf", "3mf" and others

base_length = 18
divider_lengths = list(range(2*base_length, 11*base_length, base_length))
bend_distances = list(range(base_length, 6*base_length, base_length))
border_overhangs = [0, 7, 13]
parts = {
    #"connector_all": {},
    "connector_zero": {},
    "connector_straight": {},
    "connector_t": {},
    "connector_t_round": {},
    "connector_x": {},
    "connector_x_round": {},
    "connector_corner_edgy": {},
    "connector_corner": {},
    "connector_corner_round": {},
    "divider": {
        "divider_length": divider_lengths},
    "divider_lowered": {
        "divider_length": divider_lengths[2:]},
    # can easily be created by mirroring in the slicer
    #"divider_bend_right": {
    #    "divider_length": divider_lengths,
    #    "bend_distance": bend_distances},
    "divider_bend_left": {
        "divider_length": divider_lengths,
        "bend_distance": bend_distances},
    #"connector_border_all": {},
    "connector_zero_border": {"border_overhang": border_overhangs},
    "connector_straight_border": {"border_overhang": border_overhangs},
    "connector_t_border": {"border_overhang": border_overhangs},
    "connector_t_round_border": {"border_overhang": border_overhangs},
    "connector_corner_edgy_border": {"border_overhang": border_overhangs},
    "connector_corner_border": {"border_overhang": border_overhangs},
    "connector_corner_round_border": {"border_overhang": border_overhangs},
    "divider_border": {
        "divider_length": divider_lengths,
        "border_overhang": border_overhangs},
}

designs = [
    {"height": 25},
    {"height": 40},
    {"height": 50},
    {"height": 60},
]

for design in designs:
    design_name = " ".join(f"{k}={v}" for k,v in design.items())
    dir_name = f"{OUTPUT_TYPE}/{design_name}"
    os.makedirs(dir_name, exist_ok=True)
    for part, params in parts.items():
        variants = itertools.product(*params.values())
        variants = [dict(zip(params.keys(), v)) for v in variants]
        for variant in variants:
            all_params = {"part": part, **design, **variant}
            text_params = " ".join(f"{k}={v}" for k,v in all_params.items())
            repr_params = [f"{k}={json.dumps(v)}" for k,v in all_params.items()]
            filename = f"{dir_name}/{text_params[5:]}.{OUTPUT_TYPE}"
            cmd = [
                EXECUTABLE,
                "-o", filename,
                "-q",
                "--hardwarnings",
                *itertools.chain(*(("-D", p) for p in repr_params)),
                "drawer_organizer.scad",
            ]
            print(f"running '{' '.join(cmd)}'")
            subprocess.run(cmd, check=True)
