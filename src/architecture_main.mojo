"""Dedicated entry point for the generated category-theory catalogue.

Kept separate from the small native CLI so a cold compile of the large static
catalogue is only paid when this command is actually requested.  The Stage-11
architecture map and boundary graph use the separate reta-mojo-boundaries
binary so the compiler never has to elaborate both heavy catalogues together.
"""
from reta_mojo.category_theory import bootstrap_category_theory


def main() raises:
    var bundle = bootstrap_category_theory()
    print("Kategorien:", len(bundle.categories))
    print("Funktoren:", len(bundle.functors))
    print("Natürliche Transformationen:", len(bundle.natural_transformations))
    print("Paradigmenbegriffe:", len(bundle.paradigm_terms))
