"""Native universal constructions used by reta's architecture."""
from std.collections import List, Set


@fieldwise_init
struct ColumnBucket(Copyable):
    var polarity: Int
    var bucket_type: Int
    var values: Set[Int]


def make_bucket(polarity: Int, bucket_type: Int, values: List[Int]) -> ColumnBucket:
    var result = Set[Int]()
    for index in range(len(values)):
        result.add(values[index])
    return ColumnBucket(polarity, bucket_type, result^)


def _bucket_index(buckets: List[ColumnBucket], polarity: Int, bucket_type: Int) -> Int:
    for index in range(len(buckets)):
        if buckets[index].polarity == polarity and buckets[index].bucket_type == bucket_type:
            return index
    return -1


def normalize_column_buckets(source: List[ColumnBucket]) -> List[ColumnBucket]:
    """Deterministically subtract negative selections from positive buckets.

    This is the typed equivalent of
    ``spalten_removeDoublesNthenRemoveOneFromAnother``. Negative buckets are
    consumed by the construction and do not occur in the result.
    """
    var buckets = List[ColumnBucket]()
    for index in range(len(source)):
        buckets.append(source[index].copy())

    var max_type = len(buckets) // 2
    for bucket_type in range(max_type):
        var positive_index = _bucket_index(buckets, 0, bucket_type)
        var negative_index = _bucket_index(buckets, 1, bucket_type)
        if positive_index >= 0 and negative_index >= 0:
            var retained = Set[Int]()
            for value in buckets[positive_index].values:
                if value not in buckets[negative_index].values:
                    retained.add(value)
            buckets[positive_index].values = retained^

    var result = List[ColumnBucket]()
    for index in range(len(buckets)):
        if buckets[index].polarity == 0:
            result.append(buckets[index].copy())
    return result^
