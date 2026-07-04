"""Native pure generated-column classifiers from generated_columns.py."""

from std.collections import List
from .number_theory import (
    prime_factors,
    prime_creativity,
    prime_cross_inner_candidate,
    prime_cross_outer_candidate,
    moon_number,
)


@fieldwise_init
struct GeneratedColumnSpecSnapshot(Copyable):
    var method_name: String
    var trigger_columns: List[Int]
    var tags: List[String]
    var description: String


@fieldwise_init
struct GeneratedColumnSpec(Copyable):
    """Typed metadata for one generated-column morphism."""

    var method_name: String
    var trigger_columns: List[Int]
    var tags: List[String]
    var description: String

    def snapshot(self) -> GeneratedColumnSpecSnapshot:
        return GeneratedColumnSpecSnapshot(
            self.method_name,
            self.trigger_columns.copy(),
            self.tags.copy(),
            self.description,
        )


@fieldwise_init
struct GeneratedColumnRegistrySnapshot(Copyable):
    var class_name: String
    var count: Int
    var morphisms: List[GeneratedColumnSpecSnapshot]


@fieldwise_init
struct GeneratedColumnRegistry(Copyable):
    """Ordered registry matching ``DEFAULT_GENERATED_COLUMN_REGISTRY``."""

    var specs: List[GeneratedColumnSpec]

    def names(self) -> List[String]:
        var result = List[String]()
        for index in range(len(self.specs)):
            result.append(self.specs[index].method_name)
        return result^

    def snapshot(self) -> GeneratedColumnRegistrySnapshot:
        var morphisms = List[GeneratedColumnSpecSnapshot]()
        for index in range(len(self.specs)):
            morphisms.append(self.specs[index].snapshot())
        return GeneratedColumnRegistrySnapshot(
            "GeneratedColumnRegistry", len(morphisms), morphisms^
        )


@fieldwise_init
struct GeneratedColumnsBundleSnapshot(Copyable):
    var class_name: String
    var count: Int
    var morphisms: List[GeneratedColumnSpecSnapshot]


@fieldwise_init
struct GeneratedColumnsBundle(Copyable):
    """Native architecture bundle for generated-column ownership."""

    var registry: GeneratedColumnRegistry

    def snapshot(self) -> GeneratedColumnsBundleSnapshot:
        var snapshot = self.registry.snapshot()
        return GeneratedColumnsBundleSnapshot(
            "GeneratedColumnsBundle",
            snapshot.count,
            snapshot.morphisms.copy(),
        )


@fieldwise_init
struct GeneratedColumnsSurfaceEntry(Copyable):
    var python_name: String
    var native_entry: String
    var owner_module: String


def default_generated_column_registry() -> GeneratedColumnRegistry:
    return GeneratedColumnRegistry(
        [
            GeneratedColumnSpec(
                "concatVervielfacheZeile",
                [19, 90],
                ["legacy-column-propagation"],
                "Propagates selected row content to multiples of the source row.",
            ),
            GeneratedColumnSpec(
                "concatModallogik",
                List[Int](),
                ["modal-logic", "generated-concepts"],
                "Generates modal-logic columns from selected concept-row pairs.",
            ),
            GeneratedColumnSpec(
                "concat1RowPrimUniverse2",
                List[Int](),
                ["prim-universe", "fractional-generated-column"],
                "Generates prime-universe and fractional relation columns from selected commands.",
            ),
            GeneratedColumnSpec(
                "concat1PrimzahlkreuzProContra",
                List[Int](),
                ["prime-cross", "pro-contra", "generated-column"],
                "Generates prime-cross pro/contra columns from row-number structure.",
            ),
            GeneratedColumnSpec(
                "concatPrimCreativityType",
                [64],
                ["sternPolygon", "galaxie"],
                "Generates the prime/sun/moon creativity type column.",
            ),
            GeneratedColumnSpec(
                "concatGleichheitFreiheitDominieren",
                [132],
                ["sternPolygon", "universum"],
                "Generates equality/freedom/domination classification from row number.",
            ),
            GeneratedColumnSpec(
                "concatGeistEmotionEnergieMaterieTopologie",
                [242],
                ["sternPolygon", "universum"],
                "Generates mind/emotion/energy/matter/topology classification.",
            ),
            GeneratedColumnSpec(
                "concatMondExponzierenLogarithmusTyp",
                [64],
                ["sternPolygon", "universum", "galaxie"],
                "Generates moon/exponent/logarithm relation columns.",
            ),
            GeneratedColumnSpec(
                "concatLovePolygon",
                [9],
                ["sternPolygon", "galaxie", "gleichfoermigesPolygon"],
                "Generates love-polygon text from the existing structure-size columns.",
            ),
            GeneratedColumnSpec(
                "createSpalteGestirn",
                [64],
                ["sternPolygon", "universum", "galaxie"],
                "Generates the Gestirn/Sonne/Mond/Planet classification column from row numbers.",
            ),
        ]
    )


def bootstrap_generated_columns() -> GeneratedColumnsBundle:
    return GeneratedColumnsBundle(default_generated_column_registry())


def generated_columns_surface() -> List[GeneratedColumnsSurfaceEntry]:
    """Map every Python owner entry to its native implementation boundary."""
    return [
        GeneratedColumnsSurfaceEntry("GeneratedColumnSpec", "GeneratedColumnSpec", "generated_columns.mojo"),
        GeneratedColumnsSurfaceEntry("GeneratedColumnRegistry", "GeneratedColumnRegistry", "generated_columns.mojo"),
        GeneratedColumnsSurfaceEntry("GeneratedColumnsBundle", "GeneratedColumnsBundle", "generated_columns.mojo"),
        GeneratedColumnsSurfaceEntry("concat_love_polygon", "love_polygon_value", "generated_table_columns.mojo"),
        GeneratedColumnsSurfaceEntry("gleichheit_freiheit_vergleich", "equality_freedom_value", "generated_columns.mojo"),
        GeneratedColumnsSurfaceEntry("geist_emotion_energie_materie_topologie", "mind_energy_topology_value", "generated_columns.mojo"),
        GeneratedColumnsSurfaceEntry("concat_gleichheit_freiheit_dominieren", "apply_native_generated_columns", "generated_table_columns.mojo"),
        GeneratedColumnsSurfaceEntry("concat_geist_emotion_energie_materie_topologie", "apply_native_generated_columns", "generated_table_columns.mojo"),
        GeneratedColumnsSurfaceEntry("concat_prim_creativity_type", "prime_creativity_value", "generated_columns.mojo"),
        GeneratedColumnsSurfaceEntry("concat_mond_exponzieren_logarithmus_typ", "moon_relation_value", "generated_table_columns.mojo"),
        GeneratedColumnsSurfaceEntry("concat_vervielfache_zeile", "propagate_multiples_column", "generated_table_columns.mojo"),
        GeneratedColumnsSurfaceEntry("concat_modallogik", "modal_logic_column", "generated_table_columns.mojo"),
        GeneratedColumnsSurfaceEntry("concat_primzahlkreuz_pro_contra", "generate_prime_cross_columns", "prime_cross_columns.mojo"),
        GeneratedColumnsSurfaceEntry("concat_prim_universe_row", "generate_integer_prime_universe_columns + generate_fractional_prime_universe_columns", "prime_universe_columns.mojo"),
        GeneratedColumnsSurfaceEntry("create_spalte_gestirn", "create_spalte_gestirn", "table_runtime.mojo"),
        GeneratedColumnsSurfaceEntry("bootstrap_generated_columns", "bootstrap_generated_columns", "generated_columns.mojo"),
    ]


@fieldwise_init
struct GeneratedColumnLabels(Copyable):
    var equality_header: String
    var domination: String
    var freedom: String
    var freedom_restriction: String
    var equality: String
    var outperform: String
    var underperform: String
    var energy_header: String
    var thinking: String
    var feeling: String
    var total_matter: String
    var total_topology: String
    var total_energy: String
    var some_topology: String
    var some_matter: String
    var little_matter: String
    var some_energy: String
    var little_energy: String
    var hardly_matter: String
    var creativity_header: String
    var creativity_zero: String
    var creativity_prime: String
    var creativity_sun: String
    var creativity_moon: String
    var celestial_header: String
    var celestial_separator: String
    var celestial_moon: String
    var celestial_sun: String
    var celestial_planet: String
    var celestial_black_sun: String


def generated_column_labels(language: String = "german") -> GeneratedColumnLabels:
    if language == "english" or language == "en":
        return GeneratedColumnLabels(
            "Being equal, Freedom, Liberty, Domination (Order [12]) generated",
            "domination over submission",
            "freedom_and_or_liberty",
            "reduction of liberty and or freedom",
            "equality",
            "wanting to be better or higher than the other",
            "wanting to be among or under the other",
            "energy kind or thinking kind or feeling kind or matter kind or topology kind.",
            "a way of thinking",
            "a way of feeling",
            "totally a way of producing something mentally",
            "totally a way of experiencing",
            "totally a way of energy",
            "something a way of experiencing",
            "something a way of generating something mentally",
            "little a way to generate something mentally",
            "somewhat a kind of energy",
            "hardly a kind of energy",
            "hardly a way to generate something mentally",
            "Evolution-breeding-creativity",
            "0. prime number 1",
            "1. prime number and sun number",
            "2. sun number, but no prime number",
            "3. lunar number",
            "spaceObject",
            ", and as well ",
            "moon (math powers)",
            "suns (no math powers)",
            "planets (2*n)",
            "would be a black sun, if inverted into its negative by a type 13",
        )
    return GeneratedColumnLabels(
        "Gleichheit, Freiheit, Dominieren (Ordnungen [12]) Generiert",
        "Dominieren, Unterordnen",
        "Freiheit",
        "Einschränkung der Freiheit",
        "Gleichheit",
        "den anderen überbieten wollen",
        "den anderen unterbieten wollen",
        "Energie oder Denkart oder Gefühlsart oder Materie-Art oder Topologie-Art",
        "eine Denkart",
        "eine Gefühlsart",
        "total eine Art, etwas geistig zu erzeugen",
        "total eine Art zu erleben",
        "total eine Energie-Art",
        "etwas eine Art zu erleben",
        "etwas eine Art, etwas geistig zu erzeugen",
        "wenig eine Art, etwas geistig zu erzeugen",
        "einigermaßen eine Energie-Art",
        "kaum eine Energie-Art",
        "kaum eine Art, etwas geistig zu erzeugen",
        "Evolutions-Züchtungs-Kreativität",
        "0. Primzahl 1",
        "1. Primzahl und Sonnenzahl",
        "2. Sonnenzahl, aber keine Primzahl",
        "3. Mondzahl",
        "Gestirn",
        ", und außerdem ",
        "Mond (Potenzen)",
        "Sonne (keine Potenzen)",
        "Planet (2*n)",
        "wäre eine schwarze Sonne (-3*n), wenn ins Negative durch eine Typ 13 verdreht",
    )


def _join_labels(values: List[String]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += "; "
        result += values[index]
    return result^


def equality_freedom_value(number: Int, language: String = "german") -> String:
    var labels = generated_column_labels(language)
    if number == 0:
        return labels.equality_header
    var values = List[String]()
    if number % 4 == 0:
        values.append(labels.domination)
    if number % 4 == 1:
        values.append(labels.freedom)
    if number % 4 == 3:
        values.append(labels.freedom_restriction)
    if number % 4 == 2:
        if (number - 2) % 8 == 0:
            values.append(labels.equality)
        if (number - 6) % 16 == 0:
            values.append(labels.outperform)
        if (number - 14) % 16 == 0:
            values.append(labels.underperform)
    return _join_labels(values)


def mind_energy_topology_value(number: Int, language: String = "german") -> String:
    var labels = generated_column_labels(language)
    if number == 0:
        return labels.energy_header
    var factors = prime_factors(number)
    var feeling = False
    var thinking = False
    var twos = 0
    for index in range(len(factors)):
        var factor = factors[index]
        if prime_cross_outer_candidate(factor):
            feeling = True
        if prime_cross_inner_candidate(factor):
            thinking = True
        if factor == 2:
            twos += 1
    var total_topology = twos > 1 and feeling
    var some_topology = (twos > 1 or (twos > 0 and feeling)) and not total_topology
    var total_matter = twos > 4
    var some_matter = twos == 4
    var little_matter = twos == 3
    var hardly_matter = twos == 2
    var has_two = twos > 0
    var has_three = False
    for index in range(len(factors)):
        if factors[index] == 3:
            has_three = True
    var total_energy = thinking and has_two and has_three
    # Preserve the historical duplicated ``(y and z)`` term.
    var some_energy = ((thinking and has_two) or (has_two and has_three)) and not total_energy
    var little_energy = not some_energy and not total_energy and (thinking or has_two or has_three)
    var values = List[String]()
    if thinking: values.append(labels.thinking)
    if feeling: values.append(labels.feeling)
    if total_matter: values.append(labels.total_matter)
    if total_topology: values.append(labels.total_topology)
    if total_energy: values.append(labels.total_energy)
    if some_topology: values.append(labels.some_topology)
    if some_matter: values.append(labels.some_matter)
    if little_matter: values.append(labels.little_matter)
    if some_energy: values.append(labels.some_energy)
    if little_energy: values.append(labels.little_energy)
    if hardly_matter: values.append(labels.hardly_matter)
    return _join_labels(values)


def prime_creativity_value(number: Int, language: String = "german") -> String:
    var labels = generated_column_labels(language)
    if number == 0:
        return labels.creativity_header
    var kind = prime_creativity(number)
    if kind == 0: return labels.creativity_zero
    if kind == 1: return labels.creativity_prime
    if kind == 2: return labels.creativity_sun
    return labels.creativity_moon


def celestial_value(number: Int, language: String = "german") -> String:
    var labels = generated_column_labels(language)
    if number == 0:
        return labels.celestial_header
    var values = List[String]()
    if len(moon_number(number)[1]) > 0:
        values.append(labels.celestial_moon)
    else:
        values.append(labels.celestial_sun)
    if number % 2 == 0:
        values.append(labels.celestial_planet)
    if number % 3 == 0:
        values.append(labels.celestial_black_sun)
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += labels.celestial_separator
        result += values[index]
    return result^


def generated_values_fingerprint(kind: Int, language: String, maximum: Int) -> Int:
    comptime MOD = 1000000007
    var result = 17
    for number in range(maximum + 1):
        var value: String
        if kind == 0:
            value = equality_freedom_value(number, language)
        elif kind == 1:
            value = mind_energy_topology_value(number, language)
        elif kind == 2:
            value = prime_creativity_value(number, language)
        else:
            value = celestial_value(number, language)
        var bytes = value.as_bytes()
        for index in range(len(bytes)):
            result = (result * 257 + Int(bytes[index]) + 1) % MOD
        result = (result * 257 + 258) % MOD
    return result
