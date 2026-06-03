#!/usr/bin/env python3
"""Reads plist from stdin, writes alphabetically-sorted XML to stdout."""
import plistlib
import sys


def sort_recursive(obj):
    if isinstance(obj, dict):
        return {k: sort_recursive(obj[k]) for k in sorted(obj.keys())}
    elif isinstance(obj, list):
        return [sort_recursive(item) for item in obj]
    return obj


data = plistlib.loads(sys.stdin.buffer.read())
data = sort_recursive(data)
plistlib.dump(data, sys.stdout.buffer, fmt=plistlib.FMT_XML, sort_keys=True)
