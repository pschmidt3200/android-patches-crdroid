#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Compile and exercise the actual capacity helpers and property cases in the patch."""

import os
from pathlib import Path
import shlex
import subprocess
import tempfile


def main():
    module = Path(__file__).resolve().parents[1]
    patch = module / 'patches/crdroid_oplus_battery_capacity.patch'
    # Applying the real patch is checked separately by check-reference.sh. Here
    # strip diff markers to extract its new helpers and the resulting switch cases.
    lines = patch.read_text().splitlines(keepends=True)
    start = lines.index('+/* Keep the Android capacity report aligned with the OPlus gauge compensation. */\n')
    end = lines.index(' static int battery_psy_get_prop(struct power_supply *psy,\n', start)
    assert all(line.startswith('+') for line in lines[start:end])
    helpers = ''.join(line[1:] for line in lines[start:end])
    start = lines.index(' \tcase POWER_SUPPLY_PROP_CHARGE_FULL_DESIGN:\n')
    end = lines.index(' \tcase POWER_SUPPLY_PROP_ENERGY_FULL:\n', start)
    cases = ''.join(line[1:] for line in lines[start:end] if line.startswith((' ', '+')))
    fixture = (module / 'tests/capacity_fixture.c.in').read_text()
    assert fixture.count('@HELPERS@') == fixture.count('@PROPERTY_CASES@') == 1
    fixture = fixture.replace('@HELPERS@', helpers).replace('@PROPERTY_CASES@', cases)
    compiler = [*shlex.split(os.environ.get('CC', 'cc')), '-std=gnu11',
                '-Wall', '-Wextra', '-Werror', '-fsanitize=address,undefined',
                '-fno-sanitize-recover=all']
    with tempfile.TemporaryDirectory(prefix='oplus-capacity-host-') as directory:
        work = Path(directory)
        source = work / 'probe.c'
        source.write_text(fixture)
        subprocess.run([*compiler, str(source), '-o', str(work / 'probe')], check=True)
        subprocess.run([str(work / 'probe')], check=True)
        negative = fixture.replace('return min_t(s64, compensated, capacity);',
                                   'return fcc + (compensated == 0);')
        assert negative != fixture
        source.write_text(negative)
        subprocess.run([*compiler, str(source), '-o', str(work / 'negative')], check=True)
        failed = subprocess.run([str(work / 'negative')], capture_output=True, text=True)
        assert failed.returncode != 0 and 'observed correction example' in failed.stderr
        print('Negative control detected: omitting compensation fails the correction case.')


if __name__ == '__main__':
    main()
