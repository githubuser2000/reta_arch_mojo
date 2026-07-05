"""Deterministic Rich compatibility surface for frozen Python-reference runs.

The historical renderer imports only ``Console``, ``Markdown`` and ``Syntax``.
Keeping this tiny package ahead of ambient site-packages prevents Rich-version
changes from altering command-parity fixtures while leaving the reference
sources themselves untouched.
"""
