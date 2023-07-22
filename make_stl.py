#!/usr/bin/env python3
"""Create STL files with single parts from drawer_organizer.scad."""
import itertools
import subprocess
import os
import json
import argparse

warn_about_argcomplete = False
try:
    import argcomplete
except:
    warn_about_argcomplete = True


all_parts = [
    "connector_zero",
    "connector_straight",
    "connector_t",
    "connector_t_round",
    "connector_x",
    "connector_x_round",
    "connector_corner_edgy",
    "connector_corner",
    "connector_corner_round",
    "divider",
    "divider_lowered",
    "divider_bend_left",
    "connector_zero_border",
    "connector_straight_border",
    "connector_t_border",
    "connector_t_round_border",
    "connector_corner_edgy_border",
    "connector_corner_border",
    "connector_corner_round_border",
    "divider_border",
]

parser = argparse.ArgumentParser(usage="Generate drawer organizers with your own configuration")
parser.add_argument("-x", "--executable", help="The executable to use", default="openscad")
parser.add_argument(
    "-f",
    "--format",
    help="The format that you would like the output to be in. May be specified multiple times",
    choices=["stl", "amf", "3mf", "off", "dxf", "svg", "csg", "pdf"],
    default=["stl"],
    action="append"
)
parser.add_argument("-o", "--output-dir", help="The output location for all of the generated models", default=".")
parser.add_argument("-b", "--base-length", help="the length that is used to calculate the divider lengths as well as the bend distances", default="18")
parser.add_argument("-B", "--only-base-length", help="do not create derivative lengths based off of the base length", action="store_true")
parser.add_argument("-O", "--border-overhang", help="the overhang of the border in degrees. May be specified multiple times", action="append", default=["0"])
parser.add_argument(
    "-p",
    "--part",
    help="parts to print. Option can be repeated multiple times for multiple parts (but will be ignored if 'all' is specified)",
    choices=["all", *all_parts],
    action="append",
    default=["all"]
)
parser.add_argument(
    "-d",
    "--design",
    help="design overrides in JSON format."
        "Option can be repeated multiple times for multiple designs."
        "Valid keys: 'height' 'width_bottom' 'width_top' 'gap' 'gap_top'",
    action="append",
    default=[json.dumps({"height": 25})]
)
parser.add_argument("-q", "--quite", help="don't print anything", action="store_true")
parser.add_argument("-v", "--verbose", help="print even more info", action="store_true")

if not warn_about_argcomplete:
    argcomplete.autocomplete(parser)

args = parser.parse_args()


def log(*statements, level="INFO", **kwargs):
    if args.quite and level in ["INFO", "DEBUG"]:
        return
    if not args.verbose and level == "DEBUG":
        return
    print(*statements, **kwargs)


if warn_about_argcomplete:
    log("For autocompletion please install argcomplete (pip install argcomplete)", 'after installing argcomplete, please run eval "$(register-python-argcomplete make_stl.py)"')

EXECUTABLE = args.executable # "openscad-nightly"
# OUTPUT_TYPE = args.format # "stl" # openscad also supports "amf", "3mf" and others
formats = args.format

base_length = int(args.base_length)
divider_lengths = list(range(2*base_length, 11*base_length, base_length)) if not args.only_base_length else [2*base_length]
bend_distances = list(range(base_length, 6*base_length, base_length)) if not args.only_base_length else [base_length]
border_overhangs = [float(overhang) for overhang in args.border_overhang]
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

designs = [json.loads(design) for design in args.design]

base_dir = os.path.realpath(args.output_dir)

for output_format in formats:
    log(f"Output format: {output_format}", level="DEBUG")
    for design in designs:
        log(f"Design: {json.dumps(design)}", level="DEBUG")
        design_name = " ".join(f"{k}={v}" for k,v in design.items())
        dir_name = f"{base_dir}/{output_format}/{design_name}"
        os.makedirs(dir_name, exist_ok=True)
        for part, params in parts.items():
            log(f"Part: {part}", f"Part Parameters: {json.dumps(params)}", level="DEBUG")
            variants = itertools.product(*params.values())
            variants = [dict(zip(params.keys(), v)) for v in variants]
            for variant in variants:
                log(f"Variant: {json.dumps(variant)}", level="DEBUG")
                all_params = {"part": part, **design, **variant}
                text_params = " ".join(f"{k}={v}" if k != "part" else v for k,v in all_params.items())
                repr_params = [f"{k}={json.dumps(v)}" for k,v in all_params.items()]
                filename = f"{dir_name}/{text_params}.{output_format}"
                cmd = [
                    EXECUTABLE,
                    "-o", filename,
                    "-q",
                    "--hardwarnings",
                    *itertools.chain(*(("-D", p) for p in repr_params)),
                    "drawer_organizer.scad",
                ]
                log(f"running '{' '.join(cmd)}'", level="DEBUG")
                log(f"Generating: {filename}", level="INFO")
                result = subprocess.run(cmd, check=True)
                if result.returncode != 0:
                    log(f"Issue running command: {json.dumps(cmd)}, return code: {result.returncode}", level="WARN")
